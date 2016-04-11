GroupRepo = require('./data/GroupRepo')

module.exports = (io) ->

    io.on 'connection', (socket) ->

        socket.on 'groupConnect', (user, _group) ->
            GroupRepo.getGroupMembersById _group, (err, _members) ->
                if not err and _members? and _members.indexOf(user._id) isnt -1
                    socket.join(_group)
                    socket.emit('setGroupId', _group)
                else
                    socket.emit('notAllowed')
