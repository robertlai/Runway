// Generated by CoffeeScript 1.9.3
var db, dbcredentials, fs, mongoose, passWord, userName;

fs = require('fs');

mongoose = require('mongoose');

userName = process.env.userName ? process.env.userName : null;

passWord = process.env.passWord ? process.env.passWord : null;

if (!(userName && passWord)) {
  dbcredentials = require('../dbcredentials.json');
  userName = dbcredentials.userName;
  passWord = dbcredentials.passWord;
}

db = mongoose.connect('mongodb://' + userName + ':' + passWord + '@ds053894.mongolab.com:53894/runway');

module.exports = db;
