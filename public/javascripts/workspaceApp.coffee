app = angular.module('workspaceApp', [])

scrollAtBottom = true

app.controller 'workspaceController', ($scope) ->

app.controller 'messagesController',  ($scope, $http) ->

    socket = io();

    socket.on 'initialMessages', (messages) ->
        $scope.messages = messages
        $scope.$apply()

    socket.on 'newMessage', (message) ->
        $scope.messages.push(message)
        $scope.$apply()

    socket.on 'removeMessage', (timestamp) ->
        i = 0
        (
            if (message.timestamp == timestamp)
                $scope.messages.splice(i, 1)
                break
            i++
        ) for message in $scope.messages
        $scope.$apply()



    $scope.chatVisible = true
    $scope.newMessageNotValide = false

    $scope.messages = []


    $scope.sendMessage = ->
        if $scope.newMessage.trim().length > 0
            $scope.newMessageNotValide = false
            message = {
                content: $scope.newMessage
                user: $scope.username
            }
            socket.emit('newMessage', message)
            $scope.newMessage = ''

    $scope.removeMessage = (timestamp) ->
        socket.emit('removeMessage', timestamp)


    $scope.hideChat = ->
        $scope.chatVisible = false
        document.getElementById('dropzone').style.width = '100%'

    $scope.showChat = ->
        $scope.chatVisible = true
        document.getElementById('dropzone').style.width = '75%'



window.onload = ->
    msgpanel = document.getElementById("msgpanel")
    msgpanel.scrollTop = msgpanel.scrollHeight
    i = setInterval(scrollToBottom, 100)

updateScrollState = ->
    scrollAtBottom = msgpanel.scrollTop == (msgpanel.scrollHeight - msgpanel.offsetHeight)

scrollToBottom = ->
    if scrollAtBottom
        msgpanel.scrollTop = msgpanel.scrollHeight
