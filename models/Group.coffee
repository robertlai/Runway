mongoose = require('mongoose')

messageSchema = new mongoose.Schema({
    timestamp: Number
    user: String
    content: String
}, _id: false)

groupSchema = new mongoose.Schema({
    name: String
    messages: [messageSchema]
})

module.exports = mongoose.model('group', groupSchema)
