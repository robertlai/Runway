app = angular.module('authApp', [])

app.controller 'authController', ($scope, $http, $window) ->
    $scope.user =
      username: ''
      password: ''
    $scope.error_message = ''

    $scope.login = ->
      #placeholder until authentication is implemented
      #$scope.error_message = 'Login request for ' + $scope.user.username
      $window.location.href = '/workspace?username=' + $scope.user.username;
      return

    $scope.register = ->
      #placeholder until authentication is implemented
      $scope.error_message = 'Registration request for ' + $scope.user.username
      return

    return