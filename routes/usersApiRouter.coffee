express = require('express')
User = require('../models/User')
mongoose = require('mongoose')


module.exports = express.Router()

.post '/find', (req, res) ->
    try
        _user = req.user._id
        query = req.body.query
        _group = req.body._group
        User.find({
            _id: { $ne: _user }
            _joinedGroups: { $nin: [_group] }
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
    try
        user = req.user
        newUserSettings = req.body

        User.findById(user._id)
        .exec (err, editingUser) ->
            throw err if err
            User.findOne({ username: newUserSettings.username })
            .exec (err, possibleOverlapUser) ->
                throw err if err
                if possibleOverlapUser?._id? and possibleOverlapUser._id.toString() isnt user._id.toString()
                    res.sendStatus(409)
                else
                    editingUser[key] = value for key, value of newUserSettings
                    editingUser.save (err) ->
                        throw err if err
                        res.sendStatus(200)
    catch err
        res.sendStatus(500)
