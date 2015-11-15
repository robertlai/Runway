app = angular.module('workspaceApp', [])

app.controller 'workspaceController', ($scope) ->



app.controller 'messagesController', ($scope, $http, $interval) ->


    $scope.chatVisible = true
    $scope.newCommentNotValide = false

    lastMessageId = -1

    $scope.messages = []


    fetchNewMessages = ->
        $http.get('/api/message?lastMessageId=' + lastMessageId)
            .success (message) ->
                lastMessageId = message.timestamp
                $scope.messages.push(message)



    $scope.hideChat = ->
        $scope.chatVisible = false
        document.getElementById('dropzone').style.width = '100%'

    $scope.showChat = ->
        $scope.chatVisible = true
        document.getElementById('dropzone').style.width = '75%'

    $scope.addComment = ->
        if $scope.newComment.trim().length > 0
            $http.post('/api/message?user=Test User&content=' + $scope.newComment).then ->
                $scope.newComment = ''
                $scope.newCommentNotValide = false

    fetchInitialMessages = ->
        $http.get('/api/messages')
            .success (messages) ->
                (
                    if message.timestamp > lastMessageId
                        lastMessageId = message.timestamp
                ) for message in messages

                $scope.messages = messages

    fetchInitialMessages().then ->
        $interval(fetchNewMessages, 500)
