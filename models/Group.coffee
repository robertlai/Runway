mongoose = require('mongoose')
Schema = mongoose.Schema

groupSchema = new Schema({
    name: String
    description: String
    colour: String
    _owner: { type: Schema.Types.ObjectId, ref: 'user' }
    _members: [{ type: Schema.Types.ObjectId, ref: 'user' }]
    numberOfMessagesToLoad: Number
})

module.exports = mongoose.model('group', groupSchema)
