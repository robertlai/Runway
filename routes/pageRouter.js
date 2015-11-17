// Generated by CoffeeScript 1.9.3
var express, pageRouter;

express = require('express');

pageRouter = express.Router();

pageRouter.get('/workspace', function(req, res, next) {
  return res.render('workspace', {
    title: 'Workspace',
    username: req.query.username
  });
});

pageRouter.get('*', function(req, res, next) {
  return res.render('index', {
    title: "Login"
  });
});

module.exports = pageRouter;
