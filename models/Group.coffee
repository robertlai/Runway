mongoose = require('mongoose')
Schema = mongoose.Schema

groupSchema = new Schema({
    name: String
    _owner: { type: Schema.Types.ObjectId, ref: 'user' }
    _members: [{ type: Schema.Types.ObjectId, ref: 'user' }]
})

module.exports = mongoose.model('group', groupSchema)
