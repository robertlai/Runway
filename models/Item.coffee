mongoose = require('mongoose')
Schema = mongoose.Schema

itemSchema = new Schema({
    date: Date
    group: String
    type: String
    x: Number
    y: Number
    file: Buffer
    text: String
})

module.exports = mongoose.model('item', itemSchema)
