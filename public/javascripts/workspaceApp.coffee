app = angular.module('workspaceApp', [])

scrollAtBottom = true

app.controller 'workspaceController', ($scope) ->

app.controller 'messagesController',  ($scope, $http, $interval) ->


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
            $scope.newCommentNotValide = false
            $http.post('/api/message?user=' + $scope.username + '&content=' + $scope.newComment).then ->
                $scope.newComment = ''

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

window.onload = ->
    msgpanel = document.getElementById("msgpanel")
    msgpanel.scrollTop = msgpanel.scrollHeight
    i = setInterval(scrollToBottom, 10)

updateScrollState = ->
    scrollAtBottom = msgpanel.scrollTop == (msgpanel.scrollHeight - msgpanel.offsetHeight)

scrollToBottom = ->
    if scrollAtBottom
        msgpanel.scrollTop = msgpanel.scrollHeight


