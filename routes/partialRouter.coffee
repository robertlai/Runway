express = require('express')
fs = require('fs')


module.exports = ->


    partialRouter = express.Router()
    validPartials = (fileName.slice(0, -5) for fileName in fs.readdirSync('./Views/partials'))

    partialRouter.get '/:partialName', (req, res) ->
        name = req.params.partialName
        if name in validPartials
            res.render('partials/' + name)
        else
            res.sendStatus(404)

    return partialRouter
