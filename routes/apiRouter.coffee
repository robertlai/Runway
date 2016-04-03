express = require('express')

module.exports = (io) ->

    apiRouter = express.Router()

    groupsApiRouter = require('./groupsApiRouter')
    usersApiRouter = require('./usersApiRouter')
    messagesApiRouter = require('./messagesApiRouter')(io)
    itemsApiRouter = require('./itemsApiRouter')(io)

    return apiRouter
        .use('/groups', groupsApiRouter)
        .use('/users', usersApiRouter)
        .use('/messages', messagesApiRouter)
        .use('/items', itemsApiRouter)
