app = angular.module('homeApp', [])


app.controller 'homeController', ($scope) ->

    socket = io()

    socket.on 'groupList', (groups) ->
        $scope.groups = groups
        $scope.$apply()


    $scope.init = (username) ->
        $scope.username = username
        socket.emit('getGroupList', username)
