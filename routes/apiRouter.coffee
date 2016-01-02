fs = require('fs')
multer  = require('multer')
upload = multer({ dest: 'uploads/' })

Item = require('../models/Item')
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
            Group.findOne({name: socket.group})
            .select('messages')
            .sort('timestamp')
            .exec (err, data) ->
                if data and !err
                    socket.emit('initialMessages', data.messages)

        socket.on 'postNewMessage', (messageContent) ->
            newMessage = {
                timestamp: (new Date()).getTime()
                user: socket.username
                content: messageContent
            }
            Group.update { name: socket.group },
            { $push: 'messages': newMessage },
            (err) ->
                if !err
                    io.sockets.in(socket.group).emit('newMessage', newMessage)

        socket.on 'postRemoveMessage', (timestamp) ->
            Group.update {name: socket.group},
            { $pull: 'messages': {timestamp: timestamp}},
            (err) ->
                if !err
                    io.sockets.in(socket.group).emit('removeMessage', timestamp)


        socket.on 'getInitialItems', ->
            Item.find({group: socket.group})
            .select('fileName type x y text')
            .sort('fileName')
            .exec (err, itemsInfo) ->
                if !err
                    socket.emit('newItem', itemInfo) for itemInfo in itemsInfo

        socket.on 'updateItemLocation', (fileName, newX, newY) ->
            Item.findOne({fileName: fileName})
            .select('fileName x y')
            .exec (err, item) ->
                if !err
                    item.x = newX
                    item.y = newY
                    item.save()
                    io.sockets.in(socket.group).emit('updateItem', item)


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

    app.post '/api/text', isLoggedIn, (req, res) ->
        fileName = (new Date()).getTime()
        group = req.query.group
        type = 'text'
        x = 1
        y = 1
        text = req.body.text
        try
            item = new Item {
                group: group
                fileName: fileName
                type: type
                x: x
                y: y
                text: text
            }
            item.save (err1, file) ->
                throw err1 if err1
                newItem = {
                    fileName: fileName
                    type: type
                    x: x
                    y: y
                    text: text
                }
                io.sockets.in(group).emit('newItem', newItem)
                res.sendStatus(201)
        catch err
            res.sendStatus(500)

    app.post '/api/fileUpload', isLoggedIn, upload.single('file'), (req, res) ->
        fileName = (new Date()).getTime()
        group = req.query.group
        type = req.query.type
        x = req.query.x
        y = req.query.y
        fullFilePath = req.file.path
        item = new Item {
            fileName: fileName
            group: group
            type: type
            x: x
            y: y
            file: fs.readFileSync(fullFilePath)
        }
        item.save (err1) ->
            if !err1
                newItem = {
                    fileName: fileName
                    type: type
                    x: x
                    y: y
                }
                io.sockets.in(group).emit('newItem', newItem)
            res.redirect 'back'
            fs.unlinkSync(fullFilePath)

    app.get '/api/picture', isLoggedIn, (req, res) ->
        try
            Item.findOne({fileName: req.query.fileToGet, group: req.query.groupName})
            .select('file type')
            .exec (err, file) ->
                throw err if (not file or err)
                res.set('Content-Type': file.type)
                b = file.file
                res.send(b)
        catch err
            res.sendStatus(500)
