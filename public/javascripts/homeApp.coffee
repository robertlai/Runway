homeApp = angular.module('homeApp', ['ui.router'])


homeApp.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
    $locationProvider.html5Mode({ enabled: true, requireBase: false });
    $urlRouterProvider.otherwise('/home')
    $stateProvider.state 'home',
        url: '/home'
        templateUrl: '/groups'
        controller: 'groupsController'

homeApp.controller 'groupsController', ($scope, $http) ->

    $scope.addGroup = ->
        if $scope.newGroupName and $scope.newGroupName.trim().length > 0
            $http.post('/api/newGroup?newGroupName=' + $scope.newGroupName).then (addedGroupName) ->
                $scope.groups.push(addedGroupName.data)
                $scope.newGroupName = ''
                $scope.newGroupError = null
            , (err) ->
                if err.status == 409
                    $scope.newGroupError = 'This group already exists.'
                else
                    $scope.newGroupError = 'Server Error.  Please contact support.'

    $http.get('/api/groups').then (groups) ->
        $scope.groups = groups.data
        $scope.error = null
    , (err) ->
        $scope.error = 'Server Error.  Please contact support.'
