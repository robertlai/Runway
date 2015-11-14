mongoose = require('mongoose')
dbcredentials = require('../dbcredentials.json')

db = mongoose.connect('mongodb://' + dbcredentials.userName + ':' + dbcredentials.passWord + '@ds053894.mongolab.com:53894/runway')


module.exports = db
