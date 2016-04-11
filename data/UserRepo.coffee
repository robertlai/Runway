User = require('./models/User')


createNewUser = (options, next) ->
    newUser = new User(options)
        .encryptPassword()
        .save next

getUserById = (_user, next) ->
    User.findById _user, next

getUserByUserName = (username, next) ->
    User.findOne { username: username },
    next

getGroupsOfTypeFromUserWithId = (_user, groupField, next) ->
    User.findById(_user)
    .select(groupField)
    .populate(groupField, 'name description colour _members _owner')
    .exec next

getUserDisplayInfoByUsername = (username, next) ->
    User.findOne({ username: username })
    .select('firstName lastName username')
    .exec next

addOwnedGroupIdToUserWithId = (_user, _group, next) ->
    User.findByIdAndUpdate _user,
    { $push: { _ownedGroups: _group } },
    next

removeGroupByIdFromAllUsers = (_group, next) ->
    User.update {},
    { $pull: { _ownedGroups: _group, _joinedGroups: _group } },
    { multi: true },
    next

addJoinedGroupToUser = (_user, _joinedGroup, next) ->
    User.findByIdAndUpdate _user,
    { $push: { _joinedGroups: _joinedGroup } },
    next

removeJoinedGroupToUser = (_user, _joinedGroup, next) ->
    User.findByIdAndUpdate _user,
    { $pull: { _joinedGroups: _joinedGroup } },
    next

getAssociatedUsersDisplayInfoToUserNotInGroupWithId = (user, _group, query, next) ->
    User.find({
        _id: { $ne: user._id }
        _joinedGroups: { $nin: [_group] }
        $and: [
            {
                $or: [
                    { firstName: { $regex: query, $options: 'i' } }
                    { lastName: { $regex: query, $options: 'i' } }
                    { username: { $regex: query, $options: 'i' } }
                ]
            }
            {
                $or: [
                    {
                        $and: [
                            searchability: 'friends'
                            $or: [
                                { _joinedGroups: { $in: user._ownedGroups } }
                                { _ownedGroups: { $in: user._joinedGroups } }
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
    .select('firstName lastName username')
    .exec next


module.exports = {
    createNewUser: createNewUser
    getUserById: getUserById
    getUserByUserName: getUserByUserName
    getGroupsOfTypeFromUserWithId: getGroupsOfTypeFromUserWithId
    getUserDisplayInfoByUsername: getUserDisplayInfoByUsername
    addOwnedGroupIdToUserWithId: addOwnedGroupIdToUserWithId
    removeGroupByIdFromAllUsers: removeGroupByIdFromAllUsers
    addJoinedGroupToUser: addJoinedGroupToUser
    removeJoinedGroupToUser: removeJoinedGroupToUser
    getAssociatedUsersDisplayInfoToUserNotInGroupWithId: getAssociatedUsersDisplayInfoToUserNotInGroupWithId
}
