// Generated by CoffeeScript 1.9.3
var app;

app = angular.module('workspaceApp', []);

app.controller('workspaceController', function($scope) {});

app.controller('messagesController', function($scope, $http, $interval) {
  var fetchNewMessages, lastMessageId;
  lastMessageId = -1;
  $scope.messages = [];
  fetchNewMessages = function() {
    return $http.get('/api/messages').success(function(messages) {
      return $scope.messages = messages;
    }).error(function(error, status) {
      return console.log("no new messages");
    });
  };
  $interval(fetchNewMessages, 500);
  return $scope.addComment = function() {
    return $http.post('/api/message?user=Test User&content=' + $scope.newComment).then(function() {
      return $scope.newComment = '';
    });
  };
});
