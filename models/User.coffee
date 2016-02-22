mongoose = require('mongoose')
Schema = mongoose.Schema
bcrypt = require('bcrypt-nodejs')


userSchema = new Schema({
    username: String
    password: String
    ownedGroups: [String]
    joinedGroups: [String]
})

userSchema.methods.generateHash = (password) ->
    bcrypt.hashSync(password, bcrypt.genSaltSync(8), null)

userSchema.methods.validPassword = (password) ->
    bcrypt.compareSync(password, this.password)

module.exports = mongoose.model('user', userSchema)
