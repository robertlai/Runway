fs = require('fs')
Message = require('../models/Message')
PictureMetadata = require('../models/pictureMetadata')
PictureFile = require('../models/PictureFile')


isLoggedIn = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        res.sendStatus(500)

module.exports = (app, passport) ->

    io = app.io

    io.on 'connection', (socket) ->
        Message.find({}).sort('timestamp').exec (err, messages) ->
            if !err
                socket.emit('initialMessages', messages)


        socket.on 'newMessage', (data) ->
            newMessage = new Message {
                timestamp: (new Date()).getTime()
                user: data.user
                content: data.content
            }
            newMessage.save (err, message) ->
                if !err
                    io.emit('newMessage', message)

        socket.on 'removeMessage', (timestamp) ->
            Message.find({timestamp: timestamp}).remove (err, removedMessage) ->
                if !err
                    io.emit('removeMessage', timestamp)


    app.post '/api/picture', isLoggedIn, (req, res) ->
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

    app.get '/api/pictures', isLoggedIn, (req, res) ->
        PictureMetadata.find({}).sort('fileName').exec (err, picturesInfo) ->
            if err
                res.sendStatus(500)
            else
                res.json(picturesInfo)

    app.get '/api/picture', isLoggedIn, (req, res) ->
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

    app.put '/api/picture', isLoggedIn, (req, res) ->
        PictureMetadata.findOne {fileName: req.query.fileName}, (err, picture) ->
            if err
                res.sendStatus(500)
            else
                picture.x = req.query.x
                picture.y = req.query.y
                picture.save();
                res.sendStatus(200)

    app.delete '/api/picture', isLoggedIn, (req, res) ->
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
