mongoose = require('mongoose')

pictureFileSchema = new mongoose.Schema({
    fileName: Number
    file: Buffer
})

module.exports = mongoose.model('pictureFile', pictureFileSchema)
