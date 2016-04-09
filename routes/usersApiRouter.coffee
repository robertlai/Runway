express = require('express')
User = require('../models/User')
mongoose = require('mongoose')


module.exports = express.Router()

.post '/find', (req, res) ->
    _user = req.user._id
    query = req.body.query
    try
        User.find({
            _id: { $ne: _user }
            $and: [
                {
                    $or: [
                        { firstName: { $regex: query, $options: 'i' } }
                        { lastName: { $regex: query, $options: 'i' } }
                        { nickname: { $regex: query, $options: 'i' } }
                    ]
                }
                {
                    $or: [
                        {
                            $and: [
                                searchability: 'friends'
                                $or: [
                                    { _joinedGroups: { $in: req.user._ownedGroups } }
                                    { _ownedGroups: { $in: req.user._joinedGroups } }
                                ]
                            ]
                        }
                        {
                            searchability: 'public'
                        }
                    ]
                }
            ]
        })
        .select('_id firstName lastName username')
        .limit(20)
        .exec (err, users) ->
            throw err if err
            res.json(users)
    catch err
        res.sendStatus(500)

.post '/updateUserSettings', (req, res) ->
    user = req.body
    try
        User.findByIdAndUpdate user._id,
        { $set: user },
        (err) ->
            throw err if err
            res.sendStatus(200)
    catch err
        res.sendStatus(500)
