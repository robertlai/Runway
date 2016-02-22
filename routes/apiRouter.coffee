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
        groupType = req.params.groupType
        if groupType in ['owned', 'joined']
            username = req.user.username
            try
                User.findOne {username: username}, (err1, user) ->
                    throw err1 if err1
                    res.json(user[groupType + 'Groups'])
            catch err
                res.sendStatus(500)
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
                            user.ownedGroups.push(newGroupName)
                            user.save (err4, user2) ->
                                throw err4 if err4
                                res.json(newGroupName)
        catch err
            res.sendStatus(500)

    apiRouter.post '/text', loggedIn, (req, res) ->
        date = new Date()
        group = req.query.group
        type = 'text'
        x = 1
        y = 1
        text = req.body.text
        try
            item = new Item {
                date: date
                group: group
                type: type
                x: x
                y: y
                text: text
            }
            item.save (err1, file) ->
                throw err1 if err1
                newItem = {
                    date: date
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
        date = new Date()
        group = req.query.group
        type = req.file.mimetype
        x = req.query.x
        y = req.query.y
        fullFilePath = req.file.path
        item = new Item {
            date: date
            group: group
            type: type
            x: x
            y: y
            file: fs.readFileSync(fullFilePath)
        }
        item.save (err1) ->
            if !err1
                newItem = {
                    date: date
                    type: type
                    x: x
                    y: y
                }
                io.sockets.in(group).emit('newItem', newItem)
            res.redirect 'back'
            fs.unlinkSync(fullFilePath)

    apiRouter.get '/file', loggedIn, (req, res) ->
        try
            Item.findOne({date: req.query.date, group: req.query.groupName})
            .select('file type')
            .exec (err, file) ->
                throw err if (not file or err)
                res.set('Content-Type': file.type)
                b = file.file
                res.send(b)
        catch err
            res.sendStatus(500)


    return apiRouter
