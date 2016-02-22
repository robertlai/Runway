mongoose = require('mongoose')
Schema = mongoose.Schema

messageSchema = new Schema({
    date: Date
    user: String
    content: String
}, _id: false)

groupSchema = new mongoose.Schema({
    name: String
    messages: [messageSchema]
})

module.exports = mongoose.model('group', groupSchema)
