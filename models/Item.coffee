mongoose = require('mongoose')

itemSchema = new mongoose.Schema({
    # todo: make filename 'date' and make it a javascript 'Date' object
    fileName: Number
    group: String
    type: String
    x: Number
    y: Number
    file: Buffer
    text: String
})

module.exports = mongoose.model('item', itemSchema)
