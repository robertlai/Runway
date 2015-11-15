var mongoose = require('mongoose');

var userSchema = new mongoose.Schema({
	username: String,
	password: String, //hash created from password
	create_date: {type: Date, default: Date.now}
});

var postSchema = new mongoose.Schema({
	text: String,
	user: String,
	timestamp: {type: Date, default: Date.now}
});

//declare models
mongoose.model("User", userSchema);
mongoose.model("Post", postSchema)