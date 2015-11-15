app = angular.module('workspaceApp', [])

app.controller 'workspaceController', ($scope) ->



app.controller 'messagesController', ($scope, $http, $interval) ->


    $scope.chatVisible = true
    $scope.newCommentNotValide = false

    lastMessageId = -1

    $scope.messages = []


    fetchNewMessages = ->
        $http.get('/api/messages')
            .success (messages) ->
                $scope.messages = messages
            .error (error, status) ->
                console.log "no new messages"


    $interval(fetchNewMessages, 500)

    $scope.hideChat = ->
        $scope.chatVisible = false
        document.getElementById('dropzone').style.width = '100%'

    $scope.showChat = ->
        $scope.chatVisible = true
        document.getElementById('dropzone').style.width = '80%'

    $scope.addComment = ->
        if $scope.newComment.trim().length > 0
            $http.post('/api/message?user=Test User&content=' + $scope.newComment).then ->
                $scope.newComment = ''
                $scope.newCommentNotValide = false
