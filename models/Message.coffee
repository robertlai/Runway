mongoose = require('mongoose')

messageSchema = new mongoose.Schema({
    timestamp: Number
    user: String
    content: String
})

module.exports = mongoose.model('message', messageSchema)
