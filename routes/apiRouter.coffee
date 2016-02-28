express = require('express')

fs = require('fs')
multer  = require('multer')
upload = multer({ dest: 'uploads/' })

Item = require('../models/Item')
User = require('../models/User')
Group = require('../models/Group')

passport = require('passport')


module.exports = (io) ->

    apiRouter = express.Router()

    apiRouter.get '/groups/:groupType', (req, res) ->
        groupType = req.params.groupType
        if groupType in ['owned', 'joined']
            _user = req.user._id
            try
                groupField = '_' + groupType + 'Groups'
                User.findById(_user)
                .select(groupField)
                .populate(groupField, 'name description colour')
                .exec (err, user) ->
                    throw err if err
                    res.json(user[groupField])
            catch err
                res.sendStatus(500)
        else
            res.sendStatus(404)

    apiRouter.post '/newGroup', (req, res) ->
        newGroup = req.body
        _user = req.user._id
        try
            Group.find {name: newGroup.name}, (err, groups) ->
                throw err if err
                if groups.length > 0
                    res.sendStatus(409)
                else
                    newGroup = new Group {
                        name: newGroup.name
                        description: newGroup.description
                        colour: newGroup.colour
                        _owner: req.user._id
                        _members: [req.user._id]
                        numberOfMessagesToLoad: 30
                    }
                    newGroup.save (err, savedGroup) ->
                        throw err if err
                        User.findById(_user)
                        .exec (err, user) ->
                            throw err if err
                            user._ownedGroups.push(savedGroup._id)
                            user.save (err) ->
                                throw err if err
                                res.json(savedGroup)
        catch err
            res.sendStatus(500)

    apiRouter.post '/text', (req, res) ->
        date = new Date()
        _group = req.query._group
        _owner = req.user._id
        type = 'text'
        x = 1
        y = 1
        text = req.body.text
        try
            item = new Item {
                date: date
                _group: _group
                _owner: _owner
                type: type
                x: x
                y: y
                text: text
            }
            item.save (err, newItem) ->
                throw err if err
                io.sockets.in(_group).emit('newItem', newItem)
                res.sendStatus(201)
        catch err
            res.sendStatus(500)

    apiRouter.post '/fileUpload', upload.single('file'), (req, res) ->
        date = new Date()
        _group = req.query._group
        _owner = req.user._id
        type = req.file.mimetype
        x = req.query.x
        y = req.query.y
        fullFilePath = req.file.path
        item = new Item {
            date: date
            _group: _group
            _owner: _owner
            type: type
            x: x
            y: y
            file: fs.readFileSync(fullFilePath)
        }
        item.save (err, newItem) ->
            if !err
                itemToSendBack = {
                    _id: newItem._id
                    date: date
                    type: type
                    x: x
                    y: y
                }
                io.sockets.in(_group).emit('newItem', itemToSendBack)
            res.redirect 'back'
            fs.unlinkSync(fullFilePath)

    apiRouter.get '/file', (req, res) ->
        try
            Item.findById(req.query._file)
            .select('file type')
            .exec (err, file) ->
                throw err if (not file or err)
                res.set('Content-Type': file.type)
                res.send(file.file)
        catch err
            res.sendStatus(500)


    return apiRouter
