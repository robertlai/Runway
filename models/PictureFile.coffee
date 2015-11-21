mongoose = require('mongoose')

pictureFileSchema = new mongoose.Schema({
    fileName: Number
    file: Buffer
    group: String
})

module.exports = mongoose.model('pictureFile', pictureFileSchema)
