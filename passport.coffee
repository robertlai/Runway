LocalStrategy = require('passport-local').Strategy
mongoose = require('mongoose')
bcrypt = require('bcrypt-nodejs')

userSchema = mongoose.Schema({
    local: {
        email: String
        password: String
    }
})

userSchema.methods.generateHash = (password) ->
    bcrypt.hashSync(password, bcrypt.genSaltSync(8), null)

userSchema.methods.validPassword = (password) ->
    bcrypt.compareSync(password, this.local.password)

User = mongoose.model('User', userSchema)


module.exports = (passport) ->
    passport.serializeUser (user, done) ->
        done(null, user.id)

    passport.deserializeUser (id, done) ->
        User.findById id, (err, user) ->
            done(err, user)


    passport.use 'local-register', new LocalStrategy({
        usernameField: 'email'
        passwordField: 'password'
        passReqToCallback: true
    }, (req, email, password, done) ->
        process.nextTick ->
            User.findOne { 'local.email': email }, (err, user) ->
                if err
                    return done(err)
                if user
                    return done(null, false)
                else
                    newUser = new User
                    newUser.local.email = email
                    newUser.local.password = newUser.generateHash(password)
                    newUser.save (err) ->
                        if err
                            throw err
                        done(null, newUser)
    )

    passport.use 'local-login', new LocalStrategy({
        usernameField: 'email'
        passwordField: 'password'
        passReqToCallback: true
    }, (req, email, password, done) ->
        User.findOne { 'local.email': email }, (err, user) ->
            if err
                return done(err)
            if !user
                return done(null, false)
            if !user.validPassword(password)
                return done(null, false)
            done(null, user)
    )
