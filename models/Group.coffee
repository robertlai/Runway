mongoose = require('mongoose')

groupSchema = new mongoose.Schema({
    name: String
})

module.exports = mongoose.model('group', groupSchema)
