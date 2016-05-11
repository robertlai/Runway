Group = require('./models/Group')


createNewGroup = (options, next) ->
    new Group(options)
        .save next

populateGroupMembersDisplayInfo = (groups, next) ->
    Group.populate groups, {
        path: '_members'
        select: 'firstName lastName username'
    }, next

getGroupByName = (groupName, next) ->
    Group.findOne { name: groupName }, next

updateGroupProperties = (group, next) ->
    Group.findByIdAndUpdate group._id,
    { $set: group },
    next

getOwnerOfGroupById = (_group, next) ->
    Group.findById(_group)
    .select('_owner')
    .exec (err, groupToDelete) ->
        next(err, groupToDelete?._owner)

deleteGroupById = (_group, next) ->
    Group.findByIdAndRemove _group, next

addMemberToGroup = (_group, _member, next) ->
    Group.findByIdAndUpdate _group,
    { $addToSet: { _members: _member } },
    next

removeMemberFromGroup = (_group, _member, next) ->
    Group.findByIdAndUpdate _group,
    { $pull: { _members: _member } },
    next

getGroupMembersById = (_group, next) ->
    Group.findById(_group)
    .select('_members')
    .exec (err, group) ->
        next(err, group?._members)


module.exports = {
    createNewGroup: createNewGroup
    populateGroupMembersDisplayInfo: populateGroupMembersDisplayInfo
    getGroupByName: getGroupByName
    updateGroupProperties: updateGroupProperties
    getOwnerOfGroupById: getOwnerOfGroupById
    deleteGroupById: deleteGroupById
    addMemberToGroup: addMemberToGroup
    removeMemberFromGroup: removeMemberFromGroup
    getGroupMembersById: getGroupMembersById
}
