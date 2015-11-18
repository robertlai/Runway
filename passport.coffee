LocalStrategy = require('passport-local').Strategy
mongoose = require('mongoose')
bcrypt = require('bcrypt-nodejs')

userSchema = mongoose.Schema({
    local: {
        username: String
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
        usernameField: 'username'
        passwordField: 'password'
        passReqToCallback: true
    }, (req, username, password, done) ->
        process.nextTick ->
            User.findOne { 'local.username': username }, (err, user) ->
                if err
                    return done(err)
                if user
                    return done(null, false, req.flash('registerMessage', 'That username is already taken.'))
                else
                    newUser = new User
                    newUser.local.username = username
                    newUser.local.password = newUser.generateHash(password)
                    newUser.save (err) ->
                        if err
                            throw err
                        done(null, newUser)
    )

    passport.use 'local-login', new LocalStrategy({
        usernameField: 'username'
        passwordField: 'password'
        passReqToCallback: true
    }, (req, username, password, done) ->
        User.findOne { 'local.username': username }, (err, user) ->
            if err
                return done(err)
            if !user
                return done(null, false, req.flash('loginMessage', 'No user found.'))
            if !user.validPassword(password)
                return done(null, false, req.flash('loginMessage', 'Oops! Wrong password.'))
            done(null, user)
    )
