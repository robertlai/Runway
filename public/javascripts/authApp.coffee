app = angular.module('authApp', [])

# app.controller 'authController', ($scope, $http) ->
#     $scope.user =
#       username: ''
#       password: ''
#     $scope.error_message = ''

#     $scope.login = ->
#       #placeholder until authentication is implemented
#       #$scope.error_message = 'Login request for ' + $scope.user.username
#       $http.post('/api/login');
#       return

#     $scope.register = ->
#       #placeholder until authentication is implemented
#       $http.post('/api/login');
#       return

#     return

app.controller 'authController', ($scope, $http, $rootScope, $location) ->
  $scope.user =
  username: ''
  password: ''
  $scope.error_message = ''

  $scope.login = ->
    $http.post('/auth/login', $scope.user).success (data) ->
      if data.state == 'success'
        $rootScope.authenticated = true
        $rootScope.current_user = data.user.username
        $location.path '/workspace'
      else
        $scope.error_message = data.message
      return
    return

  $scope.register = ->
    $http.post('/auth/register', $scope.user).success (data) ->
      if data.state == 'success'
        $rootScope.authenticated = true
        $rootScope.current_user = data.user.username
        $location.path '/index'
      else
        $scope.error_message = data.message
      return
    return