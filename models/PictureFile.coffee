mongoose = require('mongoose')

pictureFileSchema = new mongoose.Schema({
    group: String
    fileName: Number
    x: Number
    y: Number
    file: Buffer
})

module.exports = mongoose.model('pictureFile', pictureFileSchema)
