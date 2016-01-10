// Generated by CoffeeScript 1.9.3
var homeApp;

homeApp = angular.module('homeApp', ['ui.router']);

homeApp.config(function($stateProvider, $urlRouterProvider, $locationProvider) {
  $locationProvider.html5Mode({
    enabled: true
  });
  $urlRouterProvider.otherwise('/groups');
  return $stateProvider.state('groups', {
    url: '/groups',
    templateUrl: '/partials/groups',
    controller: 'groupsController'
  }).state('manage', {
    url: '/manage',
    templateUrl: '/partials/manage',
    controller: 'groupsController'
  });
});

homeApp.controller('groupsController', function($scope, $http) {
  $scope.addGroup = function() {
    if ($scope.newGroupName && $scope.newGroupName.trim().length > 0) {
      return $http.post('/api/newGroup?newGroupName=' + $scope.newGroupName).then(function(addedGroupName) {
        $scope.groups.push(addedGroupName.data);
        $scope.newGroupName = '';
        return $scope.newGroupError = null;
      }, function(err) {
        if (err.status === 409) {
          return $scope.newGroupError = 'This group already exists.';
        } else {
          return $scope.newGroupError = 'Server Error.  Please contact support.';
        }
      });
    }
  };
  return $http.get('/api/groups').then(function(groups) {
    $scope.groups = groups.data;
    return $scope.error = null;
  }, function(err) {
    return $scope.error = 'Server Error.  Please contact support.';
  });
});
