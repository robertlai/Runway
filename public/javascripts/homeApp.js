// Generated by CoffeeScript 1.9.3
var app;

app = angular.module('homeApp', []);

app.controller('homeController', function($scope, $http) {
  var socket;
  socket = io();
  $scope.newGroupName = '';
  $scope.error = null;
  socket.on('groupList', function(groups) {
    $scope.groups = groups;
    return $scope.$apply();
  });
  socket.on('newGroup', function(newGroup) {
    $scope.groups.push(newGroup);
    $scope.error = null;
    return $scope.$apply();
  });
  $scope.init = function(username) {
    $scope.username = username;
    return $http.get('/api/groups').then((function(groups) {
      return $scope.groups = groups.data;
    }), function(err) {
      return console.log('error1');
    });
  };
  return $scope.addGroup = function() {
    if ($scope.newGroupName.trim().length > 0) {
      return $http.post('/api/newGroup?newGroupName=' + $scope.newGroupName).then((function(addedGroupName) {
        $scope.groups.push(addedGroupName.data);
        return $scope.newGroupName = '';
      }), function(err) {
        return console.log('error2');
      });
    }
  };
});
