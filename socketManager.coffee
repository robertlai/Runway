Group = require('./models/Group')

module.exports = (io) ->

    io.on 'connection', (socket) ->

        socket.on 'groupConnect', (user, groupId) ->
            Group.findById(groupId)
            .select('_id _members')
            .exec (err, group) ->
                if group and not err and group._members.indexOf(user._id) isnt -1
                    socket.join(group._id)
                    socket.emit('setGroupId', group._id)
                else
                    socket.emit('notAllowed')
