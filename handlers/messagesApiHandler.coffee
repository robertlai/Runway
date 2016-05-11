Constants = require('../Constants')

MessageRepo = require('../data/MessageRepo')

numberOfMessagesToLoad = 30


module.exports = (io) ->

    addNewMessage = (req, res, next) ->
        _group = req.body._group

        MessageRepo.createNewMessage {
            date: new Date()
            _user: req.user._id
            _group: _group
            content: req.body.messageContent
        }, (err, newMessage) ->
            return next(err) if err
            MessageRepo.populateMessagesWithUsername newMessage, (err, populatedMessage) ->
                return next(err) if err
                io.sockets.in(_group).emit('newMessage', populatedMessage)
                res.sendStatus(201)

    deleteMessage = (req, res, next) ->
        _message = req.body._message

        MessageRepo.getGroupOfMessageById _message, (err, _group) ->
            return next(err) if err
            MessageRepo.deleteMessageById _message, (err) ->
                return next(err) if err
                io.sockets.in(_group).emit('removeMessage', _message)
                res.sendStatus(200)

    getInitialMessages = (req, res, next) ->
        MessageRepo.getMessagesForGroupIdLimitToNum req.body._group, numberOfMessagesToLoad, (err, messages) ->
            return next(err) if err
            res.json(messages)

    getMoreMessages = (req, res, next) ->
        MessageRepo.getMessagesForGroupIdLimitToNumBeforeDate req.body._group, numberOfMessagesToLoad, req.body.lastDate, (err, messages) ->
            return next(err) if err
            res.json(messages)

    {
        addNewMessage: addNewMessage
        deleteMessage: deleteMessage
        getInitialMessages: getInitialMessages
        getMoreMessages: getMoreMessages
    }
