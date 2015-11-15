var express = require('express');
var router = express.Router();

module.exports = function(passport){
	//sends successful login state back to angular
	router.get('/success', function(req, res){
		res.send({state: 'success', user: req.user ? req.user : null});
	});

	//sends failure login state back to angular
	router.get('/failure', function(req, res){
		res.send({state: 'failure', user: null, message: "Invalid username or password"});
	});

	//log in
	router.post('/login', passport.authenticate('login', {
		successRedirect: '/auth/success',
		failureRedirect: '/auth/failure'
	}));

	//register
	router.post('/register', passport.authenticate('register', {
		successRedirect: '/auth/success',
		failureRedirect: '/auth/failure'
	}));

	//log out
	router.get('/logout', function(req, res){
		req.logout();
		res.writeHead(200, {'Location': 'login'});
		res.end();
	});

	return router;
}