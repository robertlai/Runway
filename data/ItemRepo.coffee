Item = require('./models/Item')


createNewItem = (options, next) ->
    new Item(options).save next

deleteByGroupId = (_group, next) ->
    Item.remove { _group: _group },
    next

getFileContentById = (_file, next) ->
    Item.findById(_file)
    .select('file type')
    .exec next

getItemInfoByGroupIdSortedByDate = (_group, next) ->
    Item.find({ _group: _group })
    .select('date type x y width height text')
    .sort('date')
    .exec next

# todo: use update and find other way to get group
updateItemAndReturnWithGroup = (itemToUpdate, next) ->
    Item.findById(itemToUpdate._id)
    .select('x y _group')
    .exec (err, item) ->
        return next(err) if err
        item.x = itemToUpdate.newX
        item.y = itemToUpdate.newY
        item.save (err) ->
            next(err, item)


module.exports = {
    createNewItem: createNewItem
    deleteByGroupId: deleteByGroupId
    getFileContentById: getFileContentById
    getItemInfoByGroupIdSortedByDate: getItemInfoByGroupIdSortedByDate
    updateItemAndReturnWithGroup: updateItemAndReturnWithGroup
}
