fs = require('fs')
express = require('express')
api = express.Router()
mongoose = require('mongoose')
db = require('../Utilities/DB')


messageSchema = new mongoose.Schema({
    timestamp: Number
    user: String
    content: String
})
Message = mongoose.model('message', messageSchema)


pictureSchema = new mongoose.Schema({
    file: Buffer
    fileName: Number
})
Picture = mongoose.model('picture', pictureSchema)


api.post '/api/message', (req, res) ->
    timestamp = (new Date()).getTime()
    user = req.query.user;
    content = req.query.content;
    message = new Message {
        timestamp: timestamp
        user: user
        content: content
    }
    message.save (err, message) ->
        if err
            res.sendStatus(500)
            throw err
        else
            res.sendStatus(200)


api.get '/api/messages', (req, res) ->
    Message.find({}).sort('timestamp').exec (err, messages) ->
        if err
            res.sendStatus(500)
        else
            res.json(messages)

api.post '/api/picture', (req, res) ->
    fileName = (new Date()).getTime()
    fullFilePath = __dirname + '/' + fileName + Math.floor(Math.random() * 20000)

    req.pipe(fs.createWriteStream(fullFilePath)).on 'finish', ->
        picture = new Picture {
            fileName: fileName
            file: fs.readFileSync(fullFilePath)
        }
        picture.save (err, picture) ->
            if err
                res.sendStatus(500)
                throw err
            else
                res.sendStatus(201)
        .then ->
            fs.unlinkSync(fullFilePath)


api.get '/api/picture', (req, res) ->
    lastFile = if req.query.lastFile then req.query.lastFile else -1

    Picture.find({}).sort('fileName').exec (err, files) ->
        if err
            res.sendStatus(500)
            throw err
        else
            (
                if file.fileName > lastFile
                    res.set('Content-Type': 'image/jpeg')
                    res.set('fileName': file.fileName)
                    res.send(file.file)
                    return
            ) for file in files
            res.sendStatus(404)


module.exports = api
