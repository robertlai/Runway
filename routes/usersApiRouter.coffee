express = require('express')
User = require('../models/User')
mongoose = require('mongoose')


module.exports = express.Router()

.post '/find', (req, res, next) ->
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
        return next(err) if err
        res.json(users)

.post '/updateUserSettings', (req, res, next) ->
    user = req.user
    newUserSettings = req.body

    User.findById(user._id)
    .exec (err, editingUser) ->
        return next(err) if err
        User.findOne({ username: newUserSettings.username })
        .exec (err, possibleOverlapUser) ->
            return next(err) if err
            if possibleOverlapUser?._id? and possibleOverlapUser._id.toString() isnt user._id.toString()
                res.sendStatus(409)
            else
                editingUser[key] = value for key, value of newUserSettings
                editingUser.save (err) ->
                    return next(err) if err
                    res.sendStatus(200)
