stockApp = angular.module('messagesApp', [])
# todo: rename all "Stock" classes and files to "Entries" to match "Stocks"


stockApp.controller 'messagesController', ($scope, $http, $interval) ->


    lastMessageId = -1

    $scope.messages = []

    fetchNewMessages = ->
        $http.get('/api/messages')
            .success (messages) ->
                $scope.messages = messages;
            .error (error, status) ->
                console.log "no new things"


    $interval(fetchNewMessages, 500)


    $scope.messages = {
        "a":{"user":"test", "content":"this is a message"},
        "B":{"user":"test2", "content":"this is another message"}
    }
