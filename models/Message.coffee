mongoose = require('mongoose')
Schema = mongoose.Schema

messageSchema = new Schema({
    date: { type: Date, index: true }
    _group: { type: Schema.Types.ObjectId, ref: 'group' }
    _user: { type: Schema.Types.ObjectId, ref: 'user' }
    content: String
})

module.exports = mongoose.model('message', messageSchema)
