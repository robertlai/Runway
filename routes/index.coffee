express = require('express')
router = express.Router()
api = require('./api')

router.use(api)

DB = require('../Utilities/DB')

<<<<<<< HEAD
router.get '/workspace',(req,res,next)->
    res.render('workspace',title:'Workspace')

router.get '/letters', (req, res, next) ->
    res.sendfile('./public/letters.json')
=======
router.get '/messages', (req, res, next) ->
    res.render('messages', title: "Messages")
>>>>>>> 23108b5eb97e7f09000f46696f089d0abfad40b2

router.get '*', (req, res, next) ->
    res.render('index', title: 'Runway')


module.exports = router
