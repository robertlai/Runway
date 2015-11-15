fs = require('fs')
express = require('express')
api = express.Router()
mongoose = require('mongoose')
db = require('../Utilities/DB')


messageSchema = new mongoose.Schema({
    timestamp: Number
    user: String
    content: String
})
Message = mongoose.model('message', messageSchema)


api.post '/api/message', (req, res) ->
    timestamp = (new Date()).getTime()
    user = req.query.user;
    content = req.query.content;
    message = new Message {
        timestamp: timestamp
        user: user
        content: content
    }
    message.save (err, message) ->
        if err
            res.sendStatus(500)
            throw err
        else
            res.sendStatus(200)

api.get '/api/messages', (req, res) ->

    Message.find({}).sort('timestamp').exec (err, messages) ->
        if err
            res.sendStatus(500)
        else
            res.json(messages)


module.exports = api
