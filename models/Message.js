// Generated by CoffeeScript 1.9.3
var messageSchema, mongoose;

mongoose = require('mongoose');

messageSchema = new mongoose.Schema({
  timestamp: Number,
  user: String,
  content: String
});

module.exports = mongoose.model('message', messageSchema);