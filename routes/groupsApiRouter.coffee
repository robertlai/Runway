express = require('express')
Constants = require('../Constants')
Group = require('../models/Group')
Item = require('../models/Item')
User = require('../models/User')
Message = require('../models/Message')
mongoose = require('mongoose')


module.exports = express.Router()

.get '/:groupType', (req, res, next) ->
    groupType = req.params.groupType
    if groupType in Constants.GROUP_TYPES
        _user = req.user._id
        groupField = '_' + groupType + 'Groups'
        User.findById(_user)
        .select(groupField)
        .populate(groupField, 'name description colour _members _owner')
        .exec (err, user) ->
            return next(err) if err
            Group.populate user[groupField], {
                path: '_members'
                select: 'firstName lastName username'
            }, (err, populatedMembers) ->
                return next(err) if err
                res.json(user[groupField])
    else
        next(404)

.post '/new', (req, res, next) ->
    newGroup = req.body
    _user = req.user._id
    Group.findOne { name: newGroup.name }, (err, group) ->
        if err
            return next(err)
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
                return next(err) if err
                User.findByIdAndUpdate _user,
                { $push: { _ownedGroups: savedGroup._id } },
                (err) ->
                    return next(err) if err
                    Group.populate newGroup, {
                        path: '_members'
                        select: 'firstName lastName username'
                    }, (err, populatedGroup) ->
                        return next(err) if err
                        res.json(populatedGroup)

.post '/edit', (req, res, next) ->
    groupToEdit = req.body
    _user = req.user._id
    Group.findOne { name: groupToEdit.name }, (err, group) ->
        if err
            return next(err)
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
                return next(err) if err
                editedGroup._id = groupToEdit._id
                res.json(editedGroup)

.post '/delete', (req, res, next) ->
    _groupToDelete = mongoose.Types.ObjectId(req.body._id)
    _user = req.user._id
    Group.findById(_groupToDelete)
    .select('_owner _members')
    .populate('_members', '_joinedGroups')
    .exec (err, groupToDelete) ->
        return next(err) if err
        if groupToDelete._owner.toString() isnt _user.toString()
            res.sendStatus(403)
        else
            Message.remove { _group: _groupToDelete },
            (err) ->
                return next(err) if err
                Item.remove { _group: _groupToDelete },
                (err) ->
                    return next(err) if err
                    User.update {},
                        { $pull: { _ownedGroups: _groupToDelete, _joinedGroups: _groupToDelete } },
                        { multi: true },
                        (err) ->
                            return next(err) if err
                            Group.remove { _id: _groupToDelete }, (err) ->
                                return next(err) if err
                                res.sendStatus(200)

.post '/addMember', (req, res, next) ->
    _user = req.user._id
    _group = mongoose.Types.ObjectId(req.body._group)
    addMemberFunc = (memberToAdd) ->
        _memberToAdd = memberToAdd._id
        Group.findByIdAndUpdate _group,
        { $addToSet: { _members: _memberToAdd } },
        (err) ->
            return next(err) if err
            User.findByIdAndUpdate _memberToAdd,
            { $push: { _joinedGroups: _group } },
            (err) ->
                return next(err) if err
                res.json(memberToAdd)

    if req.body.memberToAdd._id?
        addMemberFunc(req.body.memberToAdd)
    else
        User.findOne({ username: req.body.memberToAdd })
        .select('_id firstName lastName username')
        .exec (err, member) ->
            return next(err) if err
            if member?
                addMemberFunc(member)
            else
                res.sendStatus(400)

# todo: dont remove the owner
.post '/removeMember', (req, res, next) ->
    _user = req.user._id
    _group = req.body._group
    _memberToRemove = mongoose.Types.ObjectId(req.body._memberToRemove)
    User.findByIdAndUpdate _memberToRemove,
    { $pull: { _joinedGroups: _group } },
    (err) ->
        return next(err) if err
        Group.findByIdAndUpdate _group,
        { $pull: { _members: _memberToRemove } },
        (err) ->
            return next(err) if err
            res.sendStatus(200)
