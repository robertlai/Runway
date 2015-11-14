express = require('express')
router = express.Router()

DB = require('../Utilities/DB')

router.get '/workspace',(req,res,next)->
    res.render('workspace',title:'Workspace')

router.get '/letters', (req, res, next) ->
    res.sendfile('./public/letters.json')

router.get '*', (req, res, next) ->
    res.render('index', title: 'Runway')


module.exports = router
