express = require('express')

multer  = require('multer')
upload = multer({ dest: 'uploads/' })


module.exports = (io) ->

    itemsApiHandler = require('../handlers/itemsApiHandler')(io)

    express.Router()
        .post '/text', itemsApiHandler.addText
        .post '/fileUpload', upload.single('file'), itemsApiHandler.uploadFile
        .get '/file', itemsApiHandler.getFile
        .post '/initialItems', itemsApiHandler.getInitialItems
        .post '/updateItemLocation', itemsApiHandler.updateItemLocation
