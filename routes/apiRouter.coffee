fs = require('fs')
express = require('express')
api = express.Router()
Message = require('../models/Message')
PictureMetadata = require('../models/pictureMetadata')
PictureFile = require('../models/PictureFile')


api.post '/message', (req, res) ->
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

api.get '/messages', (req, res) ->
    Message.find({}).sort('timestamp').exec (err, messages) ->
        if err
            res.sendStatus(500)
        else
            res.json(messages)

api.get '/message', (req, res) ->
    lastMessageId = if req.query.lastMessageId then req.query.lastMessageId else -1

    Message.find({}).sort('timestamp').exec (err, messages) ->
        if err
            res.sendStatus(500)
            throw err
        else
            (
                if message.timestamp > lastMessageId
                    res.json(message)
                    return
            ) for message in messages
            res.sendStatus(404)

api.post '/picture', (req, res) ->
    fileName = (new Date()).getTime()
    x = req.query.x
    y = req.query.y
    fullFilePath = __dirname + '/' + fileName + Math.floor(Math.random() * 20000)

    req.pipe(fs.createWriteStream(fullFilePath)).on 'finish', ->
        picture = new PictureMetadata {
            fileName: fileName
            x: x
            y: y
        }
        file = new PictureFile {
            fileName: fileName
            file: fs.readFileSync(fullFilePath)
        }
        file.save (err1, file) ->
            if err1
                res.sendStatus(500)
            else
                picture.save (err2, picture) ->
                    if err2
                        res.sendStatus(500)
                    else
                        res.sendStatus(201)
        .then ->
            fs.unlinkSync(fullFilePath)

api.get '/pictures', (req, res) ->
    PictureMetadata.find({}).sort('fileName').exec (err, picturesInfo) ->
        if err
            res.sendStatus(500)
        else
            res.json(picturesInfo)

api.get '/picture', (req, res) ->
    PictureFile.find({}).sort('fileName').exec (err, files) ->
        if err
            res.sendStatus(500)
        else
            (
                if file.fileName.toString() == req.query.fileToGet
                    res.set('Content-Type': 'image/jpeg')
                    res.set('lastFile': file.fileName)
                    res.send(file.file)
                    return
            ) for file in files
            res.sendStatus(500)

api.put '/picture', (req, res) ->
    PictureMetadata.findOne {fileName: req.query.fileName}, (err, picture) ->
        if err
            res.sendStatus(500)
        else
            picture.x = req.query.x
            picture.y = req.query.y
            picture.save();
            res.sendStatus(200)

api.delete '/picture', (req, res) ->
    fileNameToDelete = req.query.fileName
    PictureMetadata.find({fileName: fileNameToDelete}).remove (err1, removedPicture) ->
        if err1
            res.sendStatus(500)
        else
            PictureFile.find({fileName: fileNameToDelete}).remove (err2, removedFile) ->
                if err2
                    res.sendStatus(500)
                else
                    res.sendStatus(200)


module.exports = api
