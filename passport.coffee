LocalStrategy = require('passport-local').Strategy
passport = require('passport')

UserRepo = require('./data/UserRepo')

passport.serializeUser (user, done) ->
    done(null, user.id)

passport.deserializeUser (_user, done) ->
    UserRepo.getUserById _user, done

passport.use 'register', new LocalStrategy({
    usernameField: 'username'
    passwordField: 'password'
    passReqToCallback: true
}, (req, username, password, done) ->
    UserRepo.getUserByUserName username, (err, user) ->
        if err
            done(err)
        else if user?
            done(null, false, 'That username is already taken.')
        else
            UserRepo.createNewUser {
                firstName: req.body.firstName
                lastName: req.body.lastName
                email: req.body.email
                username: username
                password: password
            }, (err) ->
                if err
                    done(err)
                else
                    done(null, true)
)

passport.use 'login', new LocalStrategy({
    usernameField: 'username'
    passwordField: 'password'
}, (username, password, done) ->
    UserRepo.getUserByUserName username, (err, user) ->
        if err
            done(err)
        else if not user?
            done(null, false, 'This user was not found! Check your spelling.')
        else if not user.validPassword(password)
            done(null, false, 'Oops! Wrong password.')
        else
            done(null, user)
)
