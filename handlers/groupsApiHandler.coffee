mongoose = require('mongoose') #todo: remove mongoose dep from all files except repo files

Constants = require('../Constants')

GroupRepo = require('../data/GroupRepo')
ItemRepo = require('../data/ItemRepo')
MessageRepo = require('../data/MessageRepo')
UserRepo = require('../data/UserRepo')


getGroups = (req, res, next) ->
    groupType = req.params.groupType
    if groupType in Constants.GROUP_TYPES
        _user = req.user._id
        groupField = '_' + groupType + 'Groups'
        UserRepo.getGroupsOfTypeFromUserWithId _user, groupField, (err, user) ->
            return next(err) if err
            requestedGroups = user[groupField]
            GroupRepo.populateGroupMembersDisplayInfo requestedGroups, (err, populatedGroups) ->
                return next(err) if err
                res.json(populatedGroups)
    else
        next(404)

addNewGroup = (req, res, next) ->
    _user = req.user._id
    newGroup = {
        name: req.body.name
        description: req.body.description
        colour: req.body.colour
        _owner: _user
        _members: [_user]
    }
    GroupRepo.getGroupByName newGroup.name, (err, group) ->
        if err
            return next(err)
        else if group?
            res.sendStatus(409)
        else
            GroupRepo.createNewGroup newGroup, (err, savedGroup) ->
                return next(err) if err
                UserRepo.addOwnedGroupIdToUserWithId _user, savedGroup._id, (err) ->
                    return next(err) if err
                    GroupRepo.populateGroupMembersDisplayInfo savedGroup, (err, populatedGroup) ->
                        return next(err) if err
                        res.json(populatedGroup)

editGroup = (req, res, next) ->
    groupToEdit = {
        _id: req.body._id
        name: req.body.name
        description: req.body.description
        colour: req.body.colour
    }
    _user = req.user._id
    GroupRepo.getGroupByName groupToEdit.name, (err, group) ->
        if err
            return next(err)
        else if group? and group._id.toString() isnt groupToEdit._id.toString()
            res.sendStatus(409)
        else
            GroupRepo.updateGroupProperties groupToEdit, (err) ->
                return next(err) if err
                res.json(groupToEdit)

deleteGroup = (req, res, next) ->
    _groupToDelete = mongoose.Types.ObjectId(req.body._id)
    _user = req.user._id
    GroupRepo.getOwnerOfGroupById _groupToDelete, (err, _onwerOfGroup) ->
        return next(err) if err
        if _onwerOfGroup.toString() isnt _user.toString()
            res.sendStatus(403)
        else
            MessageRepo.deleteByGroupId _groupToDelete, (err) ->
                return next(err) if err
                ItemRepo.deleteByGroupId _groupToDelete, (err) ->
                    return next(err) if err
                    UserRepo.removeGroupByIdFromAllUsers _groupToDelete, (err) ->
                        return next(err) if err
                        GroupRepo.deleteGroupById _groupToDelete, (err) ->
                            return next(err) if err
                            res.sendStatus(200)

addMemberToGroup = (req, res, next) ->
    _user = req.user._id
    _group = mongoose.Types.ObjectId(req.body._group)
    addMemberFunc = (memberToAdd) ->
        _memberToAdd = memberToAdd._id
        GroupRepo.addMemberToGroup _group, _memberToAdd, (err) ->
            return next(err) if err
            UserRepo.addJoinedGroupToUser _memberToAdd, _group, (err) ->
                return next(err) if err
                res.json(memberToAdd)

    if req.body.memberToAdd._id?
        addMemberFunc(req.body.memberToAdd)
    else
        UserRepo.getUserDisplayInfoByUsername req.body.memberToAdd, (err, member) ->
            return next(err) if err
            if member?
                addMemberFunc(member)
            else
                res.sendStatus(400)

# todo: dont remove the owner
removeMemberFromGroup = (req, res, next) ->
    _user = req.user._id
    _group = req.body._group
    _memberToRemove = mongoose.Types.ObjectId(req.body._memberToRemove)
    UserRepo.removeJoinedGroupToUser _memberToRemove, _group, (err) ->
        return next(err) if err
        GroupRepo.removeMemberFromGroup _group, _memberToRemove, (err) ->
            return next(err) if err
            res.sendStatus(200)



module.exports = {
    getGroups: getGroups
    addNewGroup: addNewGroup
    editGroup: editGroup
    deleteGroup: deleteGroup
    addMemberToGroup: addMemberToGroup
    removeMemberFromGroup: removeMemberFromGroup
}
