app = angular.module('homeApp', [])


app.controller 'homeController', ($scope, $http) ->

    socket = io()


    $scope.newGroupName = ''
    $scope.error = null

    socket.on 'groupList', (groups) ->
        $scope.groups = groups
        $scope.$apply()

    socket.on 'newGroup', (newGroup) ->
        $scope.groups.push(newGroup)
        $scope.error = null
        $scope.$apply()


    $scope.init = (username) ->
        $scope.username = username
        $http.get('/api/groups').then ((groups) ->
            $scope.groups = groups.data
        ), (err) ->
            console.log 'error1'

    $scope.addGroup = ->
        if $scope.newGroupName.trim().length > 0
            $http.post('/api/newGroup?newGroupName=' + $scope.newGroupName).then ((addedGroupName) ->
                $scope.groups.push(addedGroupName.data)
                $scope.newGroupName = ''
            ), (err) ->
                console.log 'error2'
