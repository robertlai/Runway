// Generated by CoffeeScript 1.9.3
var mongoose, pictureFileSchema;

mongoose = require('mongoose');

pictureFileSchema = new mongoose.Schema({
  fileName: Number,
  file: Buffer
});

module.exports = mongoose.model('pictureFile', pictureFileSchema);
