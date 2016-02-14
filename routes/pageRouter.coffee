express = require('express')

# User = require('../Models/User')


# isLoggedIn = (req, res, next) ->
#     if req.isAuthenticated()
#         next()
#     else
#         req.session.returnTo = req.originalUrl
#         res.redirect('/login')

module.exports = (passport) ->

    pageRouter = express.Router()
    partialRouter = require('./partialRouter')()
    pageRouter.use('/partials', partialRouter)

    # auth

    pageRouter.post '/isUserLoggedIn', (req, res, next) ->
        res.json({ loggedIn: req.isAuthenticated()})

    pageRouter.post '/login', (req, res, next) ->
        passport.authenticate('login', (err, user, message) ->
            if err?
                res.sendStatus(500).json({err: err})
            else if !user
                res.sendStatus(401).json({err: message})
            else
                req.logIn user, (err) ->
                    if err?
                        res.sendStatus(500).json({err: err})
                    else
                        res.sendStatus(200).json({status: 'Login successful!'})
        )(req, res, next)

    pageRouter.post '/register', (req, res, next) ->
        passport.authenticate('register', (err, user, message) ->
            if err?
                res.sendStatus(500).json({err: err})
            else if !user
                res.sendStatus(409).json({err: message})
            else
                res.sendStatus(200).json({status: 'Registration successful!'})
        )(res, res, next)

    pageRouter.get '/logout', (req, res) ->
        req.logout()
        res.sendStatus(200).json({status: 'Bye!'})
    # end auth

    # pageRouter.get '/login', (req, res) ->
    #     req.logout()
    #     res.render('login', {
    #         title: 'Login'
    #         message: req.flash('loginMessage')
    #     })


    # pageRouter.get '/register', (req, res) ->
    #     req.logout()
    #     res.render('login', {
    #         title: 'Register'
    #         message: req.flash('registerMessage')
    #     })

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
    #     .exec (err, user) ->
    #         if err
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


    return pageRouter
