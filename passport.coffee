LocalStrategy = require('passport-local').Strategy
User = require('./models/User')



module.exports = (passport) ->
    passport.serializeUser (user, done) ->
        done(null, user.id)

    passport.deserializeUser (id, done) ->
        User.findById id, (err, user) ->
            done(err, user)


    passport.use 'register', new LocalStrategy({
        usernameField: 'username'
        passwordField: 'password'
        passReqToCallback: true
    }, (req, username, password, done) ->
        process.nextTick ->
            User.findOne { 'username': username }, (err, user) ->
                if err
                    return done(err)
                if user
                    return done(null, false, req.flash('registerMessage', 'That username is already taken.'))
                else
                    newUser = new User
                    newUser.username = username
                    newUser.password = newUser.generateHash(password)
                    newUser.save (err) ->
                        if err
                            throw err
                        done(null, newUser)
    )

    passport.use 'login', new LocalStrategy({
        usernameField: 'username'
        passwordField: 'password'
        passReqToCallback: true
    }, (req, username, password, done) ->
        User.findOne { 'username': username }, (err, user) ->
            if err
                return done(err)
            if !user
                return done(null, false, req.flash('loginMessage', 'No user found.'))
            if !user.validPassword(password)
                return done(null, false, req.flash('loginMessage', 'Oops! Wrong password.'))
            done(null, user)
    )
