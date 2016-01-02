// Generated by CoffeeScript 1.9.3
var User, isLoggedIn,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

User = require('../models/User');

isLoggedIn = function(req, res, next) {
  if (req.isAuthenticated()) {
    return next();
  } else {
    req.session.returnTo = req.originalUrl;
    return res.redirect('/login');
  }
};

module.exports = function(app, passport) {
  app.get('/login', function(req, res) {
    req.logout();
    return res.render('login', {
      title: 'Login',
      message: req.flash('loginMessage')
    });
  });
  app.post('/login', passport.authenticate('login', {
    failureRedirect: '/login',
    failureFlash: true
  }), function(req, res, next) {
    var pathToReturnTo;
    pathToReturnTo = '/home';
    if (req.session.returnTo) {
      pathToReturnTo = req.session.returnTo;
    }
    delete req.session.returnTo;
    return res.redirect(pathToReturnTo);
  });
  app.get('/register', function(req, res) {
    req.logout();
    return res.render('login', {
      title: 'Register',
      message: req.flash('registerMessage')
    });
  });
  app.post('/register', passport.authenticate('register', {
    successRedirect: '/login',
    failureRedirect: '/register',
    failureFlash: true
  }));
  app.get('/home', isLoggedIn, function(req, res) {
    return res.render('home', {
      title: 'Home',
      username: req.user.username
    });
  });
  app.get('/workspace', isLoggedIn, function(req, res) {
    var groupRequested, username;
    username = req.user.username;
    groupRequested = req.query.group;
    return User.findOne({
      username: username
    }).select('groups').exec(function(err, user) {
      if (err) {
        return res.sendStatus(500);
      } else {
        if (indexOf.call(user.groups, groupRequested) >= 0) {
          return res.render('workspace', {
            title: 'Workspace: ' + groupRequested,
            username: username,
            groupName: groupRequested
          });
        } else {
          return res.redirect('/home');
        }
      }
    });
  });
  return app.get('*', isLoggedIn, function(req, res) {
    return res.redirect('/home');
  });
};
