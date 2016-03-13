express = require('express')
passport = require('passport')


pageRouter = express.Router()

pageRouter.post '/getUserStatus', (req, res, next) ->
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

pageRouter.post '/login', (req, res, next) ->
    passport.authenticate('login', (error, user, message) ->
        if error?
            res.sendStatus(500).json({error: error})
        else if !user
            res.sendStatus(401).json({error: message})
        else
            req.logIn user, (error) ->
                if error?
                    res.sendStatus(500).json({error: error})
                else
                    user.password = undefined
                    res.sendStatus(200).json({user: user})
    )(req, res, next)

pageRouter.post '/register', (req, res, next) ->
    passport.authenticate('register', (error, user, message) ->
        if error?
            res.sendStatus(500).json({error: error})
        else if !user
            res.sendStatus(409).json({error: message})
        else
            res.sendStatus(200).json({})
    )(req, res, next)

pageRouter.get '/logout', (req, res) ->
    req.logout()
    res.sendStatus(200).json({})

pageRouter.get '/*', (req, res) ->
    res.render('index')

module.exports = pageRouter
