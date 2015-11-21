fs = require('fs')
Message = require('../models/Message')
PictureMetadata = require('../models/pictureMetadata')
PictureFile = require('../models/PictureFile')
User = require('../models/User')
Group = require('../models/Group')


isLoggedIn = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        res.sendStatus(500)

module.exports = (app, passport) ->

    io = app.io

    io.on 'connection', (socket) ->

        socket.on 'getInitialMessages', ->
            Message.find({}).sort('timestamp').exec (err, messages) ->
                if !err
                    socket.emit('initialMessages', messages)

        socket.on 'postNewMessage', (data) ->
            newMessage = new Message {
                timestamp: (new Date()).getTime()
                user: data.user
                content: data.content
            }
            newMessage.save (err, message) ->
                if !err
                    io.emit('newMessage', message)

        socket.on 'postRemoveMessage', (timestamp) ->
            Message.find({timestamp: timestamp}).remove (err, removedMessage) ->
                if !err
                    io.emit('removeMessage', timestamp)


        socket.on 'getInitialPictures', ->
            PictureMetadata.find({}).sort('fileName').exec (err, picturesInfo) ->
                if !err
                    socket.emit('initialPictures', picturesInfo)

        socket.on 'updatePictureLocation', (fileName, newX, newY) ->
            PictureMetadata.findOne {fileName: fileName}, (err, picture) ->
                if !err
                    picture.x = newX
                    picture.y = newY
                    picture.save();
                    io.emit('updatePicture', picture);

        socket.on 'getGroupList', (username) ->
            User.findOne {username: username}, (err, user) ->
                if !err
                    socket.emit('groupList', user.groups)



    app.get '/api/groups', isLoggedIn, (req, res) ->
        username = req.user.username
        User.findOne {username: username}, (err, user) ->
            if err
                res.sendStatus(500)
            else
                res.json(user.groups)


    app.post '/api/newGroup', (req, res) ->
        username = req.user.username
        newGroupName = req.query.newGroupName
        Group.find {name: newGroupName}, (err1, groups) ->
            if err1
                res.sendStatus(500)
            else
                if groups.length > 0
                    res.sendStatus(500)
                else
                    newGroup = new Group {
                        name: newGroupName
                    }
                    newGroup.save (err2, group) ->
                        if err2
                            res.sendStatus(500)
                        else
                            User.findOne {username: username}, (err3, user) ->
                                if err3
                                    res.sendStatus(500)
                                else
                                    user.groups.push(newGroupName)
                                    user.save()
                                    res.json(newGroupName)

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
                            pictureInfo = {
                                fileName: fileName
                                x: x
                                y: y
                            }
                            io.emit('newPicture', pictureInfo)
            .then ->
                fs.unlinkSync(fullFilePath)

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
