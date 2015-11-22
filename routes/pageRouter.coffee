User = require('../models/User')


isLoggedIn = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        res.redirect '/login'

module.exports = (app, passport) ->


    app.get '/login', (req, res) ->
        res.render('login', {
            title: 'Login'
            message: req.flash('loginMessage')
        })

    app.post '/login', passport.authenticate('login',
        successRedirect: '/home'
        failureRedirect: '/login'
        failureFlash : true
    )

    app.get '/register', (req, res) ->
        res.render('register', {
            title: 'Register'
            message: req.flash('registerMessage')
        })

    app.post '/register', passport.authenticate('register',
        successRedirect: '/home'
        failureRedirect: '/register'
        failureFlash : true
    )

    app.get '/home', isLoggedIn, (req, res) ->
        res.render('home', {username: req.user.username})

    app.get '/workspace', isLoggedIn, (req, res) ->
        username = req.user.username
        groupRequested = req.query.group
        User.findOne({username: username})
        .select('groups')
        .exec (err, user) ->
            if err
                res.sendStatus(500)
            else
                if user.groups.indexOf(groupRequested) != -1
                    res.render('workspace', {username: username, groupName: groupRequested})
                else
                    res.render('error', {
                        message:'Unauthorized'
                        error: {
                            status: 401
                        }
                    })


    app.get '/logout', (req, res) ->
        req.logout()
        res.redirect '/login'

    app.get '*', (req, res) ->
        res.redirect '/login'
