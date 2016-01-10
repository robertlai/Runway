Group = require('../models/Group')
Item = require('../models/Item')

module.exports = (io) ->

    io.on 'connection', (socket) ->

        socket.on 'groupConnect', (user, group) ->
            socket.join(group)
            socket.username = user
            socket.group = group
            socket.emit('setupComplete')


        socket.on 'getInitialMessages', ->
            Group.findOne({name: socket.group})
            .select('messages')
            .sort('timestamp')
            .exec (err, data) ->
                if data and !err
                    socket.emit('initialMessages', data.messages)

        socket.on 'postNewMessage', (messageContent) ->
            newMessage = {
                timestamp: (new Date()).getTime()
                user: socket.username
                content: messageContent
            }
            Group.update { name: socket.group },
            { $push: 'messages': newMessage },
            (err) ->
                if !err
                    io.sockets.in(socket.group).emit('newMessage', newMessage)

        socket.on 'postRemoveMessage', (timestamp) ->
            Group.update {name: socket.group},
            { $pull: 'messages': {timestamp: timestamp}},
            (err) ->
                if !err
                    io.sockets.in(socket.group).emit('removeMessage', timestamp)


        socket.on 'getInitialItems', ->
            Item.find({group: socket.group})
            .select('fileName type x y text')
            .sort('fileName')
            .exec (err, itemsInfo) ->
                if !err
                    socket.emit('newItem', itemInfo) for itemInfo in itemsInfo

        socket.on 'updateItemLocation', (fileName, newX, newY) ->
            Item.findOne({fileName: fileName})
            .select('fileName x y')
            .exec (err, item) ->
                if item and not err
                    item.x = newX
                    item.y = newY
                    item.save()
                    io.sockets.in(socket.group).emit('updateItem', item)
