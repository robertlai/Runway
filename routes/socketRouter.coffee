Group = require('../models/Group')
Item = require('../models/Item')
Message = require('../models/Message')

module.exports = (io) ->

    io.on 'connection', (socket) ->


        socket.on 'groupConnect', (user, groupId) ->
            socket.leave(room) for room of socket.rooms
            delete socket.group
            delete socket.user
            Group.findById(groupId)
            .select('_id numberOfMessagesToLoad _members')
            .exec (err, group) ->
                if group and !err and group._members.indexOf(user._id) != -1
                    socket.join(group._id)
                    socket.user = user
                    socket.group = group
                    socket.emit('setGroup', group)
                else
                    socket.emit('notAllowed')

        socket.on 'getInitialMessages', ->
            Message.find({_group: socket.group._id})
            .select('date content _user')
            .populate('_user', 'username')
            .sort({date: -1})
            .limit(socket.group.numberOfMessagesToLoad)
            .exec (err, messages) ->
                if messages and !err
                    socket.emit('initialMessages', messages)

        socket.on 'getInitialItems', ->
            Item.find({_group: socket.group._id})
            .select('date type x y width height text')
            .sort('date')
            .exec (err, itemsInfo) ->
                if !err
                    socket.emit('newItem', itemInfo) for itemInfo in itemsInfo

        socket.on 'getMoreMessages', (lastDate) ->
            Message.find({_group: socket.group._id})
            .select('date content _user')
            .populate('_user', 'username')
            .where('date').lt(lastDate)
            .sort({date: -1})
            .limit(socket.group.numberOfMessagesToLoad)
            .exec (err, messages) ->
                if messages and !err
                    socket.emit('moreMessages', messages)

        socket.on 'postNewMessage', (messageContent) ->
            newMessage = new Message {
                date: new Date()
                _user: socket.user._id
                _group: socket.group._id
                content: messageContent
            }
            newMessage.save (err, message) ->
                if !err
                    Message.populate newMessage, {
                        path: '_user'
                        select: 'username'
                    }, (err, populatedMessage) ->
                        if populatedMessage and !err
                            io.sockets.in(socket.group._id).emit('newMessage', populatedMessage)

        socket.on 'postRemoveMessage', (_message) ->
            Message.findById(_message).remove().exec (err) ->
                if !err
                    io.sockets.in(socket.group._id).emit('removeMessage', _message)

        socket.on 'updateItemLocation', (_item, newX, newY) ->
            Item.findById(_item)
            .select('x y')
            .exec (err, item) ->
                if item and not err
                    item._Id = _item
                    item.x = newX
                    item.y = newY
                    item.save()
                    io.sockets.in(socket.group._id).emit('updateItem', item)
