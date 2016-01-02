mongoose = require('mongoose')

itemSchema = new mongoose.Schema({
    fileName: Number
    group: String
    type: String
    x: Number
    y: Number
    file: Buffer
    text: String
})

module.exports = mongoose.model('item', itemSchema)
