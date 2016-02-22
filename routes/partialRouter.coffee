express = require('express')
fs = require('fs')

partialRouter = express.Router()
validPartials = (date.slice(0, -5) for date in fs.readdirSync('./views/partials'))

partialRouter.get '/:partialName', (req, res) ->
    name = req.params.partialName
    if name in validPartials
        res.render('partials/' + name)
    else
        res.sendStatus(404)

module.exports = partialRouter
