express = require('express')


module.exports = (passport) ->

    router = express.Router()

    apiRouter = require('./apiRouter')(passport)
    pageRouter = require('./pageRouter')(passport)

    router.use('/api', apiRouter)
    router.use(pageRouter)

    return router
