express = require('express')

fs = require('fs')
multer  = require('multer')
upload = multer({ dest: 'uploads/' })
sizeOf = require('image-size')

Constants = require('../Constants')

ItemRepo = require('../data/ItemRepo')

module.exports = (io) ->

    return express.Router()

    .post '/text', (req, res, next) ->
        _group = req.body._group
        ItemRepo.createNewItem {
            date: new Date()
            _group: _group
            _owner: req.user._id
            type: 'text'
            x: 50
            y: 50
            width: null
            height: null
            text: req.body.text
        }, (err, newItem) ->
            return next(err) if err
            io.sockets.in(_group).emit('newItem', newItem)
            res.sendStatus(201)

    .post '/fileUpload', upload.single('file'), (req, res, next) ->
        _group = req.headers._group
        width = null
        height = null
        fullFilePath = req.file.path
        try
            dimensions = sizeOf(fullFilePath)
            width = dimensions.width * 100.0 / 1280
            height = dimensions.height * 100.0 / 800

        ItemRepo.createNewItem {
            date: new Date()
            _group: _group
            _owner: req.user._id
            type: req.file.mimetype
            x: parseInt(req.headers.x) * 100.0 / parseInt(req.headers.screenwidth)
            y: parseInt(req.headers.y) * 100.0 / parseInt(req.headers.screenheight)
            width: width
            height: height
            file: fs.readFileSync(fullFilePath)
        }, (err, newItem) ->
            if not err
                delete newItem.file
                newItem.file = undefined
                io.sockets.in(_group).emit('newItem', newItem)
            fs.unlinkSync(fullFilePath)
            res.redirect('back')

    .get '/file', (req, res, next) ->
        ItemRepo.getFileContentById req.query._file, (err, file) ->
            return next(err) if not file? or err
            res.set('Content-Type': file.type)
            res.send(file.file)

    .post '/initialItems', (req, res, next) ->
        ItemRepo.getItemInfoByGroupIdSortedByDate req.body._group, (err, itemsInfo) ->
            return next(err) if err
            res.json(itemsInfo)

    .post '/updateItemLocation', (req, res, next) ->
        _item = req.body._item
        newX = req.body.newX
        newY = req.body.newY
        item = {
            _id: req.body._item
            newX: req.body.newX
            newY: req.body.newY
        }
        ItemRepo.updateItemAndReturnWithGroup item, (err, item) ->
            io.sockets.in(item._group).emit('updateItem', item)
            res.sendStatus(200)
