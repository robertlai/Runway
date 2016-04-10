express = require('express')

fs = require('fs')
multer  = require('multer')
upload = multer({ dest: 'uploads/' })
sizeOf = require('image-size')

Constants = require('../Constants')

Item = require('../models/Item')

module.exports = (io) ->

    return express.Router()

    .post '/text', (req, res) ->
        try
            _group = req.body._group
            item = new Item {
                date: new Date()
                _group: _group
                _owner: req.user._id
                type: 'text'
                x: 0
                y: 0
                width: null
                height: null
                text: req.body.text
            }
            item.save (err, newItem) ->
                throw err if err
                io.sockets.in(_group).emit('newItem', newItem)
                res.sendStatus(201)
        catch err
            res.sendStatus(500)

    .post '/fileUpload', upload.single('file'), (req, res) ->
        date = new Date()
        _group = req.headers._group
        _owner = req.user._id
        type = req.file.mimetype
        x = parseInt(req.headers.x) * 100.0 / parseInt(req.headers.screenwidth)
        y = parseInt(req.headers.y) * 100.0 / parseInt(req.headers.screenheight)
        width = null
        height = null
        fullFilePath = req.file.path
        try
            dimensions = sizeOf(fullFilePath)
            width = dimensions.width * 100.0 / 1280
            height = dimensions.height * 100.0 / 800

        item = new Item {
            date: date
            _group: _group
            _owner: _owner
            type: type
            x: x
            y: y
            width: width
            height: height
            file: fs.readFileSync(fullFilePath)
        }
        item.save (err, newItem) ->
            if not err
                itemToSendBack = {
                    _id: newItem._id
                    date: date
                    type: type
                    x: x
                    y: y
                    width: width
                    height: height
                }
                io.sockets.in(_group).emit('newItem', itemToSendBack)
            res.redirect('back')
            fs.unlinkSync(fullFilePath)

    .get '/file', (req, res) ->
        try
            Item.findById(req.query._file)
            .select('file type')
            .exec (err, file) ->
                throw err if (not file or err)
                res.set('Content-Type': file.type)
                res.send(file.file)
        catch err
            res.sendStatus(500)

    .post '/initialItems', (req, res) ->
        try
            Item.find({ _group: req.body._group })
            .select('date type x y width height text')
            .sort('date')
            .exec (err, itemsInfo) ->
                throw err if err
                res.json(itemsInfo)
        catch err
            res.sendStatus(500)

    .post '/updateItemLocation', (req, res) ->
        try
            _item = req.body._item
            newX = req.body.newX
            newY = req.body.newY

            Item.findById(_item)
            .select('x y _group')
            .exec (err, item) ->
                throw err if err
                item._id = _item
                item.x = newX
                item.y = newY
                item.save()
                io.sockets.in(item._group).emit('updateItem', item)
                res.sendStatus(200)
        catch err
            res.sendStatus(500)
