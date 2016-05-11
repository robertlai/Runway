express = require('express')

groupsApiHandler = require('../handlers/groupsApiHandler')

module.exports = express.Router()
    .get '/:groupType', groupsApiHandler.getGroups
    .post '/new', groupsApiHandler.addNewGroup
    .post '/edit', groupsApiHandler.editGroup
    .post '/delete', groupsApiHandler.deleteGroup
    .post '/addMember', groupsApiHandler.addMemberToGroup
    .post '/removeMember', groupsApiHandler.removeMemberFromGroup
