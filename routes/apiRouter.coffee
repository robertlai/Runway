express = require('express')

fs = require('fs')
multer  = require('multer')
upload = multer({ dest: 'uploads/' })

Item = require('../models/Item')
User = require('../models/User')
Group = require('../models/Group')

passport = require('passport')


loggedIn = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        res.sendStatus(401)

module.exports = (io) ->

    apiRouter = express.Router()

    apiRouter.get '/groups/:groupType', loggedIn, (req, res) ->
        # todo: use the req.params.groupType to get the correct group types for return
        if req.params.groupType is 'owned'
            username = req.user.username
            try
                User.findOne {username: username}, (err1, user) ->
                    throw err1 if err1
                    res.json(user.groups)
            catch err
                res.sendStatus(500)
        else if req.params.groupType is 'joined'
            res.json([
                    'joined group 1'
                    'joined group 2'
                    'joined group 3'
                    'joined group 4'
                    'joined group 5'
                    'joined group 6'
                    'joined group 7'
                ])
        else
            res.sendStatus(404)

    apiRouter.post '/newGroup', loggedIn, (req, res) ->
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

    apiRouter.post '/text', loggedIn, (req, res) ->
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

    apiRouter.post '/fileUpload', loggedIn, upload.single('file'), (req, res) ->
        fileName = (new Date()).getTime()
        group = req.query.group
        type = req.file.mimetype
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

    apiRouter.get '/picture', loggedIn, (req, res) ->
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


    return apiRouter
