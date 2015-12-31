fs = require('fs')
mongoose = require('mongoose')

address = null
if process.env.dbAddress
    address = process.env.dbAddress
else
    address = require('../dbcredentials.json').dbAddress

db = mongoose.connect(address)

module.exports = db
