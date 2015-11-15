app = angular.module('workspaceApp', [])

app.controller 'workspaceController', ($scope) ->



app.controller 'messagesController', ($scope, $http, $interval) ->

    lastMessageId = -1

    $scope.messages = []


    fetchNewMessages = ->
        $http.get('/api/messages')
            .success (messages) ->
                $scope.messages = messages;
            .error (error, status) ->
                console.log "no new messages"


    $interval(fetchNewMessages, 500)

    $scope.addComment = ->
        $http.post('/api/message?user=Test User&content=' + $scope.newComment).then ->
            $scope.newComment = ''
