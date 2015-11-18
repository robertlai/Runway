
isLoggedIn = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        res.redirect '/login'

module.exports = (app, passport) ->


    app.get '/login', (req, res) ->
        res.render('login', {title: 'Login'})

    app.post '/login', passport.authenticate('local-login',
        successRedirect: '/workspace'
        failureRedirect: '/login'
    )

    app.get '/register', (req, res) ->
        res.render('register', {title: 'Register'})

    app.post '/register', passport.authenticate('local-register',
        successRedirect: '/workspace'
        failureRedirect: '/register'
    )

    app.get '/workspace', isLoggedIn, (req, res) ->
        res.render('workspace')

    app.get '/logout', (req, res) ->
        req.logout()
        res.redirect '/login'

    app.get '*', (req, res) ->
        res.redirect '/login'
