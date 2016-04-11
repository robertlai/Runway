Message = require('./models/Message')


createNewMessage = (options, next) ->
    new Message(options)
        .save next

getGroupOfMessageById = (_message, next) ->
    Message.findById(_message)
    .select('_group')
    .exec (err, message) ->
        next(err, message?._group)

# todo: combine these somehow
getMessagesForGroupIdLimitToNumBeforeDate = (_group, limitNum, date, next) ->
    Message.find({ _group: _group })
    .select('date content _user')
    .populate('_user', 'username')
    .where('date').lt(date)
    .sort({ date: -1 })
    .limit(limitNum)
    .exec next

getMessagesForGroupIdLimitToNum = (_group, limitNum, next) ->
    Message.find({ _group: _group })
    .select('date content _user')
    .populate('_user', 'username')
    .sort({ date: -1 })
    .limit(limitNum)
    .exec next

deleteByGroupId = (_group, next) ->
    Message.remove { _group: _group },
    next

deleteMessageById = (_message, next) ->
    Message.findByIdAndRemove _message, next

populateMessagesWithUsername = (messages, next) ->
    Message.populate messages, {
        path: '_user'
        select: 'username'
    }, next


module.exports = {
    createNewMessage: createNewMessage
    getGroupOfMessageById: getGroupOfMessageById
    getMessagesForGroupIdLimitToNumBeforeDate: getMessagesForGroupIdLimitToNumBeforeDate
    getMessagesForGroupIdLimitToNum: getMessagesForGroupIdLimitToNum
    deleteByGroupId: deleteByGroupId
    deleteMessageById: deleteMessageById
    populateMessagesWithUsername: populateMessagesWithUsername
}
