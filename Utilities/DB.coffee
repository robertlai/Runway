fs = require('fs')
mongoose = require('mongoose')

userName = if process.env.userName  then process.env.userName else null
passWord = if process.env.passWord  then process.env.passWord else null
if not (userName and passWord)
    dbcredentials = require('../dbcredentials.json')
    userName = dbcredentials.userName
    passWord = dbcredentials.passWord

db = mongoose.connect('mongodb://' + userName + ':' + passWord + '@ds053894.mongolab.com:53894/runway')

module.exports = db
