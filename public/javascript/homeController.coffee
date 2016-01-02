angular.module('runwayApp').controller 'homeController', ($scope, $http) ->

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


    $scope.addGroup = ->
        if $scope.newGroupName.trim().length > 0
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
