app = angular.module('homeApp', [])


app.controller 'homeController', ($scope, $http) ->

    socket = io()


    $scope.newGroupName = ''
    $scope.error = null

    socket.on 'groupList', (groups) ->
        $scope.groups = groups
        $scope.$apply()

    socket.on 'newGroupError', (error) ->
        $scope.error = error
        $scope.$apply()

    socket.on 'newGroup', (newGroup) ->
        $scope.groups.push(newGroup)
        $scope.error = null
        $scope.$apply()


    $scope.init = (username) ->
        $scope.username = username
        socket.emit('getGroupList', username)

    $scope.addGroup = ->
        if $scope.newGroupName.trim().length > 0
            $http.post('/api/newGroup?newGroupName=test').then ((res) ->
                console.log 'success'
                $scope.groups.push($scope.newGroupName)
                $scope.newGroupName = ''
            ), (err) ->
                console.log 'error'

            # socket.emit('postNewGroup', $scope.newGroupName)
