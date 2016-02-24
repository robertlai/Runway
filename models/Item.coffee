mongoose = require('mongoose')
Schema = mongoose.Schema

itemSchema = new Schema({
    date: Date
    _group: { type: Schema.Types.ObjectId, ref: 'group' }
    _owner: { type: Schema.Types.ObjectId, ref: 'user' }
    type: String
    x: Number
    y: Number
    file: Buffer
    text: String
})

module.exports = mongoose.model('item', itemSchema)
