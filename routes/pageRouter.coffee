express = require('express')
passport = require('passport')

# User = require('../Models/User')


# isLoggedIn = (req, res, next) ->
#     if req.isAuthenticated()
#         next()
#     else
#         req.session.returnTo = req.originalUrl
#         res.redirect('/login')


pageRouter = express.Router()
partialRouter = require('./partialRouter')
pageRouter.use('/partials', partialRouter)

# auth
pageRouter.post '/getUserStatus', (req, res, next) ->
    res.json({ loggedIn: req.isAuthenticated(), user: req.user})

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
                    res.sendStatus(200).json({status: 'Login successful!', user: req.user})
    )(req, res, next)

pageRouter.post '/register', (req, res, next) ->
    passport.authenticate('register', (error, user, message) ->
        if error?
            res.sendStatus(500).json({error: error})
        else if !user
            res.sendStatus(409).json({error: message})
        else
            res.sendStatus(200).json({status: 'Registration successful!'})
    )(req, res, next)

pageRouter.get '/logout', (req, res) ->
    req.logout()
    res.sendStatus(200).json({status: 'Bye!'})
# end auth

pageRouter.get '/*', (req, res) ->
    res.render('index')

# pageRouter.get '/*', (req, res) ->
#     res.render('home', {
#         title: 'Home'
#         # username: req.user.username
#     })

# pageRouter.get '/workspace', isLoggedIn, (req, res) ->
#     username = req.user.username
#     groupRequested = req.query.group
#     User.findOne({username: username})
#     .select('groups')
#     .exec (error, user) ->
#         if error
#             res.sendStatus(500)
#         else
#             if groupRequested in user.groups
#                 res.render('workspace', {
#                     title: 'Workspace: ' + groupRequested
#                     username: username
#                     groupName: groupRequested
#                 })
#             else
#                 res.redirect('/home')

# pageRouter.get '*', isLoggedIn, (req, res) ->
#     res.redirect('/home')


module.exports = pageRouter
