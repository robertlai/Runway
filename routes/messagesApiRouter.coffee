express = require('express')
Constants = require('../Constants')
Message = require('../models/Message')

numberOfMessagesToLoad = 30


module.exports = (io) ->

    return express.Router()

    .post '/new', (req, res, next) ->
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
            return next(err) if err
            Message.populate newMessage, {
                path: '_user'
                select: 'username'
            }, (err, populatedMessage) ->
                return next(err) if err
                io.sockets.in(_group).emit('newMessage', populatedMessage)
                res.sendStatus(201)

    .post '/delete', (req, res, next) ->
        _message = req.body._message

        Message.findById(_message)
        .select('_group')
        .exec (err, message) ->
            return next(err) if err
            message.remove().then (message, err) ->
                return next(err) if err
                io.sockets.in(message._group).emit('removeMessage', _message)
                res.sendStatus(200)

    .post '/getInitial', (req, res, next) ->
        _group = req.body._group

        Message.find({ _group: _group })
        .select('date content _user')
        .populate('_user', 'username')
        .sort({ date: -1 })
        .limit(numberOfMessagesToLoad)
        .exec (err, messages) ->
            return next(err) if err
            res.json(messages)

    .post '/getMore', (req, res, next) ->
        _group = req.body._group

        Message.find({ _group: _group })
        .select('date content _user')
        .populate('_user', 'username')
        .where('date').lt(req.body.lastDate)
        .sort({ date: -1 })
        .limit(numberOfMessagesToLoad)
        .exec (err, messages) ->
            return next(err) if err
            res.json(messages)
