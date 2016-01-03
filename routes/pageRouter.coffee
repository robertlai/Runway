User = require('../models/User')


isLoggedIn = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        req.session.returnTo = req.originalUrl
        res.redirect('/login')

module.exports = (app, passport) ->


    app.get '/login', (req, res) ->
        req.logout()
        res.render('login', {
            title: 'Login'
            message: req.flash('loginMessage')
        })

    app.post '/login', passport.authenticate('login',
        failureRedirect: '/login'
        failureFlash : true
    ), (req, res, next) ->
        pathToReturnTo = '/home'
        if req.session.returnTo
            pathToReturnTo = req.session.returnTo
            delete req.session.returnTo
        res.redirect pathToReturnTo

    app.get '/register', (req, res) ->
        req.logout()
        res.render('login', {
            title: 'Register'
            message: req.flash('registerMessage')
        })

    app.post '/register', passport.authenticate('register',
        successRedirect: '/login'
        failureRedirect: '/register'
        failureFlash : true
    )

    app.get '/', isLoggedIn, (req, res) ->
        res.render('home', {
            title: 'Home'
            username: req.user.username
        })

    app.get '/groups', isLoggedIn, (req, res) ->
        res.render('groups')

    app.get '/test', isLoggedIn, (req, res) ->
        res.render('test')

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
                    res.redirect('/')

    app.get '*', isLoggedIn, (req, res) ->
        res.redirect('/')

# todo: implement logout function
    # app.get '/logout', (req, res) ->
    #     req.logout()
    #     res.redirect '/login'
