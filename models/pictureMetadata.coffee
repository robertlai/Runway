mongoose = require('mongoose')

pictureMetadataSchema = new mongoose.Schema({
    fileName: Number
    x: Number
    y: Number
    group: String
})

module.exports = mongoose.model('pictureMetadata', pictureMetadataSchema)
