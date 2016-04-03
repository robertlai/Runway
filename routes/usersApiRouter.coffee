express = require('express')
User = require('../models/User')


module.exports = express.Router()

.post '/find', (req, res) ->
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
