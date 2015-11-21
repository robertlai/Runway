
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
        successRedirect: '/workspace'
        failureRedirect: '/login'
        failureFlash : true
    )

    app.get '/register', (req, res) ->
        res.render('register', {
            title: 'Register'
            message: req.flash('registerMessage')
        })

    app.post '/register', passport.authenticate('register',
        successRedirect: '/workspace'
        failureRedirect: '/register'
        failureFlash : true
    )

    app.get '/workspace', isLoggedIn, (req, res) ->
        res.render('workspace', {username: req.user.username})

    app.get '/logout', (req, res) ->
        req.logout()
        res.redirect '/login'

    app.get '*', (req, res) ->
        res.redirect '/login'
