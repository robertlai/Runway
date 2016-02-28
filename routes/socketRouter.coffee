Group = require('../models/Group')
Item = require('../models/Item')
Message = require('../models/Message')

module.exports = (io) ->

    io.on 'connection', (socket) ->

        socket.on 'groupConnect', (user, groupId) ->
            # todo: valide here that the user has access to the group before adding them to the socket group
            Group.findById(groupId) # select whole group object for later user checking if user is allowed
            .exec (err, group) ->
                if group and !err
                    socket.join(group._id)
                    socket.user = user
                    socket.group = group
                    socket.emit('setupComplete', group)

        socket.on 'getInitialMessages', ->
            Message.find({_group: socket.group._id})
            .select('date content _user')
            .populate('_user', 'username') # only populate username of user
            .sort({date: -1})
            .limit(socket.group.numberOfMessagesToLoad)
            .exec (err, messages) ->
                if messages and !err
                    socket.emit('initialMessages', messages)

        socket.on 'getMoreMessages', (lastDate) ->
            Message.find({_group: socket.group._id})
            .select('date content _user')
            .populate('_user', 'username') # only populate username of user
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
                        select: 'username' # only populate username
                    }, (err, populatedMessage) ->
                        if populatedMessage and !err
                            io.sockets.in(socket.group._id).emit('newMessage', populatedMessage)

        socket.on 'postRemoveMessage', (_message) ->
            Message.findById(_message).remove().exec (err) ->
                if !err
                    io.sockets.in(socket.group._id).emit('removeMessage', _message)


        socket.on 'getInitialItems', ->
            Item.find({_group: socket.group._id})
            .select('date type x y text')
            .sort('date')
            .exec (err, itemsInfo) ->
                if !err
                    socket.emit('newItem', itemInfo) for itemInfo in itemsInfo

        socket.on 'updateItemLocation', (date, newX, newY) ->
            Item.findOne({date: date})
            .select('date x y')
            .exec (err, item) ->
                if item and not err
                    item.x = newX
                    item.y = newY
                    item.save()
                    io.sockets.in(socket.group._id).emit('updateItem', item)
