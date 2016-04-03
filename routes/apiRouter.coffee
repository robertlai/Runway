express = require('express')

fs = require('fs')
multer  = require('multer')
upload = multer({ dest: 'uploads/' })
sizeOf = require('image-size')

Constants = require('../Constants')

Group = require('../models/Group')
Item = require('../models/Item')
Message = require('../models/Message')
User = require('../models/User')

passport = require('passport')

numberOfMessagesToLoad = 30


module.exports = (io) ->

    apiRouter = express.Router()

    apiRouter.get '/groups/:groupType', (req, res) ->
        groupType = req.params.groupType
        if groupType in Constants.GROUP_TYPES
            _user = req.user._id
            try
                groupField = '_' + groupType + 'Groups'
                User.findById(_user)
                .select(groupField)
                .populate(groupField, 'name description colour _members')
                .exec (err, user) ->
                    throw err if err
                    Group.populate user[groupField], {
                        path: '_members'
                        select: 'firstName lastName username'
                    }, (err, populatedMembers) ->
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
            Group.findOne { name: newGroup.name }, (err, group) ->
                if err
                    throw err
                else if group
                    res.sendStatus(409)
                else
                    newGroup = new Group {
                        name: newGroup.name
                        description: newGroup.description
                        colour: newGroup.colour
                        _owner: req.user._id
                        _members: [req.user._id]
                    }
                    newGroup.save (err, savedGroup) ->
                        throw err if err
                        User.findById(_user)
                        .exec (err, user) ->
                            throw err if err
                            user._ownedGroups.push(savedGroup._id)
                            user.save (err) ->
                                throw err if err
                                Group.populate newGroup, {
                                    path: '_members'
                                    select: 'firstName lastName username'
                                }, (err, populatedGroup) ->
                                    throw err if err
                                    res.json(populatedGroup)
        catch err
            res.sendStatus(500)

    apiRouter.post '/editGroup', (req, res) ->
        groupToEdit = req.body
        _user = req.user._id
        try
            Group.findOne { name: groupToEdit.name }, (err, group) ->
                if err
                    throw err
                else if group and group._id.toString() isnt groupToEdit._id.toString()
                    res.sendStatus(409)
                else
                    editedGroup = {
                        name: groupToEdit.name
                        description: groupToEdit.description
                        colour: groupToEdit.colour
                    }
                    Group.findByIdAndUpdate groupToEdit._id,
                    { $set: editedGroup },
                    (err) ->
                        throw err if err
                        editedGroup._id = groupToEdit._id
                        res.json(editedGroup)
        catch err
            res.sendStatus(500)

    apiRouter.post '/deleteGroup', (req, res) ->
        _groupToDelete = req.body._id
        _user = req.user._id
        try
            Group.findById(_groupToDelete)
            .select('_owner _members')
            .populate('_members', '_joinedGroups')
            .exec (err, groupToDelete) ->
                throw err if err
                if groupToDelete._owner.toString() isnt _user.toString()
                    res.sendStatus(401)
                else
                    # todo: finish deleting stuff
                    res.sendStatus(200) # hack
        catch err
            res.sendStatus(500)


    apiRouter.post '/getUsers', (req, res) ->
        _user = req.user._id
        query = req.body.query
        try
            # todo: check if user is a publicly findable user
            User.find({
                $or: [
                    { 'firstName': { '$regex': query, '$options': 'i' } }
                    { 'lastName': { '$regex': query, '$options': 'i' } }
                    { 'nickname': { '$regex': query, '$options': 'i' } }
                ]
                '_id': { $ne: _user }
            })
            .select('_id firstName lastName username')
            .exec (err, users) ->
                throw err if err
                res.json(users)
        catch err
            res.sendStatus(500)

    apiRouter.post '/addGroupMember', (req, res) ->
        # todo: verify that the memberToAdd is valid and also have it possiby look for username if not fully valid
        _user = req.user._id
        _group = req.body._group
        _memberToAdd = req.body.memberToAdd._id
        try
            Group.findById(_group)
            .select('_members')
            .exec (err, group) ->
                throw err if err
                if group._members.indexOf(_memberToAdd) isnt -1
                    res.sendStatus(409)
                else
                    group._members.push(_memberToAdd)
                    group.save (err) ->
                        throw err if err
                        User.findById(_memberToAdd)
                        .select('_joinedGroups')
                        .populate('_joinedGroups')
                        .exec (err, userBeingAdded) ->
                            throw err if err
                            userBeingAdded._joinedGroups.push(_group)
                            userBeingAdded.save (err) ->
                                throw err if err
                                res.sendStatus(200)
        catch err
            res.sendStatus(500)

    apiRouter.post '/text', (req, res) ->
        _group = req.body._group
        try
            item = new Item {
                date: new Date()
                _group: _group
                _owner: req.user._id
                type: 'text'
                x: 0
                y: 0
                width: null
                height: null
                text: req.body.text
            }
            item.save (err, newItem) ->
                throw err if err
                io.sockets.in(_group).emit('newItem', newItem)
                res.sendStatus(201)
        catch err
            res.sendStatus(500)

    apiRouter.post '/fileUpload', upload.single('file'), (req, res) ->
        date = new Date()
        _group = req.headers._group
        _owner = req.user._id
        type = req.file.mimetype
        x = parseInt(req.headers.x) * 100.0 / parseInt(req.headers.screenwidth)
        y = parseInt(req.headers.y) * 100.0 / parseInt(req.headers.screenheight)
        width = null
        height = null
        fullFilePath = req.file.path
        try
            dimensions = sizeOf(fullFilePath)
            width = dimensions.width * 100.0 / 1280
            height = dimensions.height * 100.0 / 800

        item = new Item {
            date: date
            _group: _group
            _owner: _owner
            type: type
            x: x
            y: y
            width: width
            height: height
            file: fs.readFileSync(fullFilePath)
        }
        item.save (err, newItem) ->
            if not err
                itemToSendBack = {
                    _id: newItem._id
                    date: date
                    type: type
                    x: x
                    y: y
                    width: width
                    height: height
                }
                io.sockets.in(_group).emit('newItem', itemToSendBack)
            res.redirect('back')
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

    apiRouter.post '/newMessage', (req, res) ->
        try
            _user = req.user._id
            _group = req.body._group
            messageContent = req.body.messageContent

            newMessage = new Message {
                date: new Date()
                _user: _user
                _group: _group
                content: messageContent
            }
            newMessage.save (err, message) ->
                throw err if err
                Message.populate newMessage, {
                    path: '_user'
                    select: 'username'
                }, (err, populatedMessage) ->
                    throw err if err
                    io.sockets.in(_group).emit('newMessage', populatedMessage)
                    res.sendStatus(201)
        catch err
            res.sendStatus(500)

    apiRouter.post '/removeMessage', (req, res) ->
        try
            _message = req.body._message

            Message.findById(_message)
            .select('_group')
            .exec (err, message) ->
                throw err if err
                message.remove().then (message, err) ->
                    throw err if err
                    io.sockets.in(message._group).emit('removeMessage', _message)
                    res.sendStatus(200)
        catch err
            res.sendStatus(500)

    apiRouter.post '/initialMessages', (req, res) ->
        try
            Message.find({ _group: req.body._group })
            .select('date content _user')
            .populate('_user', 'username')
            .sort({ date: -1 })
            .limit(numberOfMessagesToLoad)
            .exec (err, messages) ->
                throw err if err
                res.json(messages)
        catch err
            res.sendStatus(500)

    apiRouter.post '/moreMessages', (req, res) ->
        try
            Message.find({ _group: req.body._group })
            .select('date content _user')
            .populate('_user', 'username')
            .where('date').lt(req.body.lastDate)
            .sort({ date: -1 })
            .limit(numberOfMessagesToLoad)
            .exec (err, messages) ->
                throw err if err
                res.json(messages)
        catch err
            res.sendStatus(500)

    apiRouter.post '/initialItems', (req, res) ->
        try
            Item.find({ _group: req.body._group })
            .select('date type x y width height text')
            .sort('date')
            .exec (err, itemsInfo) ->
                throw err if err
                res.json(itemsInfo)
        catch err
            res.sendStatus(500)

    apiRouter.post '/updateItemLocation', (req, res) ->
        try
            _item = req.body._item
            newX = req.body.newX
            newY = req.body.newY

            Item.findById(_item)
            .select('x y _group')
            .exec (err, item) ->
                throw err if err
                item._id = _item
                item.x = newX
                item.y = newY
                item.save()
                io.sockets.in(item._group).emit('updateItem', item)
                res.sendStatus(200)
        catch err
            res.sendStatus(500)


    return apiRouter
