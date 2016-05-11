express = require('express')

usersApiHandler = require('../handlers/usersApiHandler')

module.exports = express.Router()
    .post '/find', usersApiHandler.findUsers
    .post '/updateUserSettings', usersApiHandler.updateUserSettings
