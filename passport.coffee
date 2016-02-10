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
        User.findOne { 'username': username }, (err, user) ->
            if err
                done(err)
            else if user
                done(null, false, 'That username is already taken.')
            else
                newUser = new User
                newUser.username = username
                newUser.password = newUser.generateHash(password)
                newUser.save (err) ->
                    if err
                        done(err)
                    else
                        done(null, newUser)
    )

    passport.use 'login', new LocalStrategy({
        passReqToCallback: true # todo: find out what exactly this does
    }, (req, username, password, done) ->
        User.findOne { 'username': username }, (err, user) ->
            if err
                done(err)
            else if !user
                done(null, false, 'This user was not found! Check your spelling.')
            else if !user.validPassword(password)
                done(null, false, 'Oops! Wrong password.')
            else
                done(null, user)
    )
