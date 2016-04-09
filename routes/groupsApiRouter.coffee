express = require('express')
Constants = require('../Constants')
Group = require('../models/Group')
Item = require('../models/Item')
User = require('../models/User')
Message = require('../models/Message')
mongoose = require('mongoose')


module.exports = express.Router()

.get '/:groupType', (req, res) ->
    groupType = req.params.groupType
    if groupType in Constants.GROUP_TYPES
        _user = req.user._id
        try
            groupField = '_' + groupType + 'Groups'
            User.findById(_user)
            .select(groupField)
            .populate(groupField, 'name description colour _members')
            .exec (err, user) ->
                throw err if err
                Group.populate user[groupField], {
                    path: '_members'
                    select: 'firstName lastName username'
                }, (err, populatedMembers) ->
                    throw err if err
                    res.json(user[groupField])
        catch err
            res.sendStatus(500)
    else
        res.sendStatus(404)

.post '/new', (req, res) ->
    newGroup = req.body
    _user = req.user._id
    try
        Group.findOne { name: newGroup.name }, (err, group) ->
            if err
                throw err
            else if group
                res.sendStatus(409)
            else
                newGroup = new Group {
                    name: newGroup.name
                    description: newGroup.description
                    colour: newGroup.colour
                    _owner: req.user._id
                    _members: [req.user._id]
                }
                newGroup.save (err, savedGroup) ->
                    throw err if err
                    User.findById(_user)
                    .exec (err, user) ->
                        throw err if err
                        user._ownedGroups.push(savedGroup._id)
                        user.save (err) ->
                            throw err if err
                            Group.populate newGroup, {
                                path: '_members'
                                select: 'firstName lastName username'
                            }, (err, populatedGroup) ->
                                throw err if err
                                res.json(populatedGroup)
    catch err
        res.sendStatus(500)

.post '/edit', (req, res) ->
    groupToEdit = req.body
    _user = req.user._id
    try
        Group.findOne { name: groupToEdit.name }, (err, group) ->
            if err
                throw err
            else if group and group._id.toString() isnt groupToEdit._id.toString()
                res.sendStatus(409)
            else
                editedGroup = {
                    name: groupToEdit.name
                    description: groupToEdit.description
                    colour: groupToEdit.colour
                }
                Group.findByIdAndUpdate groupToEdit._id,
                { $set: editedGroup },
                (err) ->
                    throw err if err
                    editedGroup._id = groupToEdit._id
                    res.json(editedGroup)
    catch err
        res.sendStatus(500)

.post '/delete', (req, res) ->
    _groupToDelete = mongoose.Types.ObjectId(req.body._id)
    _user = req.user._id
    try
        Group.findById(_groupToDelete)
        .select('_owner _members')
        .populate('_members', '_joinedGroups')
        .exec (err, groupToDelete) ->
            throw err if err
            if groupToDelete._owner.toString() isnt _user.toString()
                res.sendStatus(403)
            else
                Message.remove { _group: _groupToDelete },
                (err) ->
                    throw err if err
                    Item.remove { _group: _groupToDelete },
                    (err) ->
                        throw err if err
                        User.update {},
                            { $pull: { _ownedGroups: _groupToDelete, _joinedGroups: _groupToDelete } },
                            { multi: true },
                            (err) ->
                                throw err if err
                                Group.remove { _id: _groupToDelete }, (err) ->
                                    throw err if err
                                    res.sendStatus(200)
    catch err
        res.sendStatus(500)


.post '/addMember', (req, res) ->
    # todo: verify that the memberToAdd is valid and also have it possiby look for username if not fully valid
    _user = req.user._id
    _group = req.body._group
    _memberToAdd = req.body.memberToAdd._id
    try
        Group.findById(_group)
        .select('_members')
        .exec (err, group) ->
            throw err if err
            if group._members.indexOf(_memberToAdd) isnt -1
                res.sendStatus(409)
            else
                group._members.push(_memberToAdd)
                group.save (err) ->
                    throw err if err
                    User.findById(_memberToAdd)
                    .select('_joinedGroups')
                    .populate('_joinedGroups')
                    .exec (err, userBeingAdded) ->
                        throw err if err
                        userBeingAdded._joinedGroups.push(_group)
                        userBeingAdded.save (err) ->
                            throw err if err
                            res.sendStatus(200)
    catch err
        res.sendStatus(500)
