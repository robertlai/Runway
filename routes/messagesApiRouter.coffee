express = require('express')
Constants = require('../Constants')
Message = require('../models/Message')

numberOfMessagesToLoad = 30


module.exports = (io) ->

    return express.Router()

    .post '/new', (req, res) ->
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

    .post '/delete', (req, res) ->
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

    .post '/getInitial', (req, res) ->
        try
            _group = req.body._group

            Message.find({ _group: _group })
            .select('date content _user')
            .populate('_user', 'username')
            .sort({ date: -1 })
            .limit(numberOfMessagesToLoad)
            .exec (err, messages) ->
                throw err if err
                res.json(messages)
        catch err
            res.sendStatus(500)

    .post '/getMore', (req, res) ->
        try
            _group = req.body._group

            Message.find({ _group: _group })
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
