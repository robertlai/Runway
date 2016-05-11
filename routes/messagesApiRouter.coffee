express = require('express')
Constants = require('../Constants')

MessageRepo = require('../data/MessageRepo')

numberOfMessagesToLoad = 30


module.exports = (io) ->

    messagesApiHandler = require('../handlers/messagesApiHandler')(io)

    express.Router()
        .post '/new', messagesApiHandler.addNewMessage
        .post '/delete', messagesApiHandler.deleteMessage
        .post '/getInitial', messagesApiHandler.getInitialMessages
        .post '/getMore', messagesApiHandler.getMoreMessages
