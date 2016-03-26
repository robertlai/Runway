mongoose = require('mongoose')
Schema = mongoose.Schema

itemSchema = new Schema({
    date: { type: Date, index: true }
    _group: { type: Schema.Types.ObjectId, ref: 'group' }
    _owner: { type: Schema.Types.ObjectId, ref: 'user' }
    type: String
    x: Number
    y: Number
    width: Number
    height: Number
    file: Buffer
    text: String
})

module.exports = mongoose.model('item', itemSchema)
