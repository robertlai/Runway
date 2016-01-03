homeApp = angular.module('homeApp', [ 'ngRoute' ])


homeApp.config ($routeProvider) ->
    $routeProvider.when '/groups',
        templateUrl: '/groups'
        controller: 'groupsController'
    # $routeProvider.when '/test',
    #     templateUrl: '/test'
    #     controller: 'groupsController'
    .otherwise
        redirectTo: '/groups'


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
