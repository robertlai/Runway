mongoose = require('mongoose')
bcrypt = require('bcrypt-nodejs')


userSchema = new mongoose.Schema({
    username: String
    password: String
    groups: []
})

userSchema.methods.generateHash = (password) ->
    bcrypt.hashSync(password, bcrypt.genSaltSync(8), null)

userSchema.methods.validPassword = (password) ->
    bcrypt.compareSync(password, this.password)

module.exports = mongoose.model('user', userSchema)
