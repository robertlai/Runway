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
        res.render('login', {
            title: 'Register'
            message: req.flash('registerMessage')
        })

    app.post '/register', passport.authenticate('register',
        successRedirect: '/login'
        failureRedirect: '/register'
        failureFlash : true
    )

    app.get '/home', isLoggedIn, (req, res) ->
        res.render('home', {
            title: 'Home'
            username: req.user.username
        })

    app.get '/workspace', isLoggedIn, (req, res) ->
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
                    res.render('error', {
                        title: 'Error'
                        message:'Unauthorized.  You do not have access to this group.'
                        error: {
                            status: 401
                        }
                    })

    app.get '*', isLoggedIn, (req, res) ->
        res.redirect '/home'

# todo: implement logout function
    # app.get '/logout', (req, res) ->
    #     req.logout()
    #     res.redirect '/login'
