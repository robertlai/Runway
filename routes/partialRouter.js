// Generated by CoffeeScript 1.10.0
(function() {
  var express, fs,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  express = require('express');

  fs = require('fs');

  module.exports = function() {
    var fileName, partialRouter, validPartials;
    partialRouter = express.Router();
    validPartials = (function() {
      var i, len, ref, results;
      ref = fs.readdirSync('./views/partials');
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        fileName = ref[i];
        results.push(fileName.slice(0, -5));
      }
      return results;
    })();
    partialRouter.get('/:partialName', function(req, res) {
      var name;
      name = req.params.partialName;
      if (indexOf.call(validPartials, name) >= 0) {
        return res.render('partials/' + name);
      } else {
        return res.sendStatus(404);
      }
    });
    return partialRouter;
  };

}).call(this);
