express = require('express')

module.exports = (io) ->

    groupsApiRouter = require('./groupsApiRouter')
    usersApiRouter = require('./usersApiRouter')
    messagesApiRouter = require('./messagesApiRouter')(io)
    itemsApiRouter = require('./itemsApiRouter')(io)

    return express.Router()
        .use('/groups', groupsApiRouter)
        .use('/users', usersApiRouter)
        .use('/messages', messagesApiRouter)
        .use('/items', itemsApiRouter)
