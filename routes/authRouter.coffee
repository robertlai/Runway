express = require('express')
passport = require('passport')


module.exports = express.Router()

.post '/getUserStatus', (req, res, next) ->
    currentUser = req.user
    user = if currentUser
        currentUser.password = undefined
        user = currentUser
    else
        null
    res.json({
        loggedIn: req.isAuthenticated()
        user: user
    })

.post '/login', (req, res, next) ->
    passport.authenticate('login', (error, user, message) ->
        if error?
            res.sendStatus(500).json({ error: error })
        else if not user
            res.sendStatus(403).json({ error: message })
        else
            req.logIn user, (error) ->
                if error?
                    res.sendStatus(500).json({ error: error })
                else
                    delete user.password
                    user.password = undefined
                    res.sendStatus(200).json({ user: user })
    )(req, res, next)

#todo: double password matching
.post '/register', (req, res, next) ->
    passport.authenticate('register', (error, user, message) ->
        if error?
            res.sendStatus(500).json({ error: error })
        else if not user
            res.sendStatus(409).json({ error: message })
        else
            res.sendStatus(200).json({})
    )(req, res, next)

.get '/logout', (req, res) ->
    req.logout()
    res.sendStatus(200).json({})

.get '/*', (req, res) ->
    res.render('index')
