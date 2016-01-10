express = require('express')

User = require('../models/User')


isLoggedIn = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        req.session.returnTo = req.originalUrl
        res.redirect('/login')

module.exports = (passport) ->

    pageRouter = express.Router()
    partialRouter = require('./partialRouter')(isLoggedIn)
    pageRouter.use('/partials', partialRouter)

    pageRouter.get '/login', (req, res) ->
        req.logout()
        res.render('login', {
            title: 'Login'
            message: req.flash('loginMessage')
        })

    pageRouter.post '/login', passport.authenticate('login',
        failureRedirect: '/login'
        failureFlash : true
    ), (req, res, next) ->
        pathToReturnTo = '/'
        if req.session.returnTo
            pathToReturnTo = req.session.returnTo
            delete req.session.returnTo
        res.redirect pathToReturnTo

    pageRouter.get '/register', (req, res) ->
        req.logout()
        res.render('login', {
            title: 'Register'
            message: req.flash('registerMessage')
        })

    pageRouter.post '/register', passport.authenticate('register',
        successRedirect: '/login'
        failureRedirect: '/register'
        failureFlash : true
    )

    pageRouter.get '/home*', isLoggedIn, (req, res) ->
        res.render('home', {
            title: 'Home'
            username: req.user.username
        })

    pageRouter.get '/workspace', isLoggedIn, (req, res) ->
        username = req.user.username
        groupRequested = req.query.group
        User.findOne({username: username})
        .select('groups')
        .exec (err, user) ->
            if err
                res.sendStatus(500)
            else
                if groupRequested in user.groups
                    res.render('workspace', {
                        title: 'Workspace: ' + groupRequested
                        username: username
                        groupName: groupRequested
                    })
                else
                    res.redirect('/home')

    pageRouter.get '/logout', (req, res) ->
        req.logout()
        res.redirect '/login'

    pageRouter.get '*', isLoggedIn, (req, res) ->
        res.redirect('/home')


    return pageRouter
