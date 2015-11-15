var LocalStrategy = require('passport-local').Strategy;
var bCrypt = require('bcrypt-nodejs');
var mongoose = require('mongoose');
var db = require('./Utilities/DB')

var User = mongoose.model('User');
var Post = mongoose.model('Post');

module.exports = function(passport){
	//Passport needs to be able to serialize and deserialize users
	passport.serializeUser(function(user, done){
		//tell passport which id to use for user
		console.log('Serializing user: ', user._id);
		return done(null, user._id);
	});

	passport.deserializeUser(function(id, done){
		//return user object back
		User.findById(id, function(err, user){
			if (err){
				return done(err, false);
			}
			if(!user){
				return done('User not found', false);
			}
			return done(user, true);
		});
	});

	passport.use('login', new LocalStrategy({
			passReqToCallback : true
		},
		function(req, username, password, done) {
			User.findOne({username: username}, function(err, user){
				if (err){
					return done(err, false);
				}
				if (!user){
					return done('User ' + username + ' not found', false);
				}
				if(!isValidPassword(user, password)){
					return done('Incorrect password', false)
				}
				console.log("Successfully signed in");
				return done(null, user);
			})
		}
	));

	passport.use('register', new LocalStrategy({
			passReqToCallback : true
		},
		function(req, username, password, done) {
			//check if user already exists
			User.findOne({username: username}, function(err, user){
				if (err){
					return done(err, false);
				}
				if (user){
					return done('Username already taken', false);
				}

				var user = new User();

				user.username = username;
				user.password = createHash(password);
				user.save(function(err, user){
					if(err){
						return done(err, false);
					}
					console.log('Successfully registered user ' + username);
					return done(null, user);
				});
			});
		}
	));

	var isValidPassword = function(user, password){
		return bCrypt.compareSync(password, user.password);
	}

	//generate hash using bCrypt
	var createHash = function(password){
		return bCrypt.hashSync(password, bCrypt.genSaltSync(10), null);
	};
};