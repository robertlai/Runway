// Generated by CoffeeScript 1.9.3
var mongoose, pictureMetadataSchema;

mongoose = require('mongoose');

pictureMetadataSchema = new mongoose.Schema({
  fileName: Number,
  x: Number,
  y: Number,
  group: String
});

module.exports = mongoose.model('pictureMetadata', pictureMetadataSchema);
