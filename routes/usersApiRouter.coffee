express = require('express')
mongoose = require('mongoose')

UserRepo = require('../data/UserRepo')

module.exports = express.Router()

.post '/find', (req, res, next) ->
    UserRepo.getAssociatedUsersDisplayInfoToUserNotInGroupWithId req.user, req.body._group, req.body.query, (err, users) ->
        return next(err) if err
        res.json(users)

.post '/updateUserSettings', (req, res, next) ->
    user = req.user
    newUserSettings = req.body

    UserRepo.getUserById user._id, (err, editingUser) ->
        return next(err) if err
        UserRepo.getUserByUserName newUserSettings.username, (Err, possibleOverlapUser) ->
            return next(err) if err
            if possibleOverlapUser?._id? and possibleOverlapUser._id.toString() isnt user._id.toString()
                res.sendStatus(409)
            else
                editingUser[key] = value for key, value of newUserSettings
                editingUser.save (err) ->
                    return next(err) if err
                    res.sendStatus(200)
