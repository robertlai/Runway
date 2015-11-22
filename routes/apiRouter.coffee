fs = require('fs')
multer  = require('multer')
upload = multer({ dest: 'uploads/' })

Message = require('../models/Message')
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

        socket.on 'groupConnect', (user, group) ->
            socket.join(group)
            socket.username = user
            socket.group = group
            socket.emit('setupComplete')


        socket.on 'getInitialMessages', ->
            Message.find({group: socket.group}).sort('timestamp').exec (err, messages) ->
                # todo: add error responce
                if !err
                    socket.emit('initialMessages', messages)

        socket.on 'postNewMessage', (messageContent) ->
            newMessage = new Message {
                timestamp: (new Date()).getTime()
                user: socket.username
                group: socket.group
                content: messageContent
            }
            newMessage.save (err, message) ->
                # todo: add error responce
                if !err
                    io.sockets.in(socket.group).emit('newMessage', message)

        socket.on 'postRemoveMessage', (timestamp) ->
            Message.remove {timestamp: timestamp, group: socket.group}, (err) ->
                # todo: add err responce
                if !err
                    io.sockets.in(socket.group).emit('removeMessage', timestamp)


        socket.on 'getInitialPictures', ->
            PictureFile.find({group: socket.group})
            .select('fileName x y')
            .sort('fileName')
            .exec (err, picturesInfo) ->
                # todo: add error responce
                if !err
                    socket.emit('initialPictures', picturesInfo)

        socket.on 'updatePictureLocation', (fileName, newX, newY) ->
            # todo: use groups
            PictureFile.findOne({fileName: fileName})
            .select('fileName x y')
            .exec (err, picture) ->
                # todo: add error responce
                if !err
                    picture.x = newX
                    picture.y = newY
                    picture.save()
                    io.sockets.in(socket.group).emit('updatePicture', picture)


    app.get '/api/groups', isLoggedIn, (req, res) ->
        username = req.user.username
        try
            User.findOne {username: username}, (err1, user) ->
                throw err1 if err1
                res.json(user.groups)
        catch err
            res.sendStatus(500)

    app.post '/api/newGroup', isLoggedIn, (req, res) ->
        username = req.user.username
        newGroupName = req.query.newGroupName
        try
            Group.find {name: newGroupName}, (err1, groups) ->
                throw err1 if err1
                if groups.length > 0
                    res.sendStatus(409)
                else
                    newGroup = new Group {
                        name: newGroupName
                    }
                    newGroup.save (err2, group) ->
                        throw err2 if err2
                        User.findOne {username: username}, (err3, user) ->
                            throw err3 if err3
                            user.groups.push(newGroupName)
                            user.save (err4, user2) ->
                                throw err4 if err4
                                res.json(newGroupName)
        catch err
            res.sendStatus(500)


    app.post '/api/picture', isLoggedIn, (req, res) ->
        fileName = (new Date()).getTime()
        # todo: don't pass through query
        x = req.query.x
        y = req.query.y
        fullFilePath = __dirname + '/' + fileName + Math.floor(Math.random() * 20000)
        try
            req.pipe(fs.createWriteStream(fullFilePath)).on 'finish', ->
                pictureFile = new PictureFile {
                    group: req.query.group
                    fileName: fileName
                    x: x
                    y: y
                    file: fs.readFileSync(fullFilePath)
                }
                pictureFile.save (err1, file) ->
                    throw err1 if err1
                    newPicture = {
                        fileName: fileName
                        x: x
                        y: y
                    }
                    io.sockets.in(req.query.group).emit('newPicture', newPicture)
                    res.sendStatus(201)
                .then ->
                    fs.unlinkSync(fullFilePath)
        catch err
            res.sendStatus(500)

    app.post '/api/fileUpload', isLoggedIn, upload.single('file'), (req, res) ->
        fileName = (new Date()).getTime()
        group = req.query.group
        x = req.query.x
        y = req.query.y
        fullFilePath = req.file.path
        pictureFile = new PictureFile {
            # todo: don't pass through query
            fileName: fileName
            group: group
            x: x
            y: y
            file: fs.readFileSync(fullFilePath)
        }
        pictureFile.save (err1, file) ->
            if !err1
                newPicture = {
                    fileName: fileName
                    x: x
                    y: y
                }
                io.sockets.in(group).emit('newPicture', newPicture)
            res.redirect 'back'
            fs.unlinkSync(fullFilePath)

    app.get '/api/picture', isLoggedIn, (req, res) ->
        try
            # todo: not checking groups yet
            PictureFile.findOne({fileName: req.query.fileToGet})
            .select('file')
            .exec (err, file) ->
                throw err if err
                res.set('Content-Type': 'image/jpeg')
                res.send(file.file)
        catch err
            res.sendStatus(500)
