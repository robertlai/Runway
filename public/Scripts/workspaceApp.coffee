workspaceApp = angular.module('workspaceApp', [])

workspaceApp.controller 'workspaceController', ($scope) ->

    $dropzone = $('#dropzone')

    mouseX = undefined
    mouseY = undefined
    maxx = -> $dropzone.outerWidth()
    maxy = -> $dropzone.outerHeight()

    myDropzone = new Dropzone '#dropzone', {
        url: '/api/fileUpload'
        method: 'post'
        uploadMultiple: false
        maxFilesize: 9
        clickable: false
        createImageThumbnails: false
        autoProcessQueue: true
        acceptedFiles: 'image/*, application/pdf'
        accept: (file, done) ->
            this.options.url = '/api/fileUpload?group=' + $scope.groupName + '&x=' + mouseX * 100.0 / maxx() + '&y=' + mouseY * 100.0 / maxy()
            hoverTextOff()
            done()
    }

    myDropzone.on 'complete', (file) ->
        myDropzone.removeFile(file)

    socket = io()

    $scope.init = (username, groupName) ->
        $scope.username = username
        $scope.groupName = groupName
        socket.emit('groupConnect', username, groupName)


    socket.on 'setupComplete', ->
        socket.emit('getInitialMessages')
        socket.emit('getInitialItems')


    socket.on 'initialMessages', (messages) ->
        addMessageContent ->
            $scope.messages = messages

    socket.on 'newMessage', (message) ->
        addMessageContent ->
            $scope.messages.push(message)

    addMessageContent = (addFunction, all) ->
        chatBody = document.getElementById('chatBody')
        scrollAtBottom = all || Math.abs(chatBody.scrollTop - chatBody.scrollHeight + chatBody.offsetHeight) < 50
        addFunction()
        $scope.$apply()
        chatBody.scrollTop = chatBody.scrollHeight if scrollAtBottom

    socket.on 'removeMessage', (timestamp) ->
        $scope.messages = $scope.messages.filter (message) ->
            message.timestamp isnt timestamp
        $scope.$apply()

    socket.on 'updateItem', (itemInfo) ->
        $('#' + itemInfo.fileName).offset ({
            top: itemInfo.y / 100.0 * maxy()
            left: itemInfo.x / 100.0 * maxx()
        })

    socket.on 'newItem', (itemInfo) ->
        innerContent = undefined
        if itemInfo.type is 'text'
            innerContent = $('<p/>', class: 'noselect').text(itemInfo.text)
        else if itemInfo.type.substring(0, 5) is 'image'
            innerContent = $('<img/>', src: '/api/picture?fileToGet=' + itemInfo.fileName + '&groupName=' + $scope.groupName)
        else if itemInfo.type is 'application/pdf'
            innerContent = $('<div style="padding-top:25px; background-color:black;"><object data="/api/picture?fileToGet=' +
                itemInfo.fileName + '&groupName=' + $scope.groupName + "'/></div>")

        if innerContent
            innerContent.css('position', 'absolute')
            .attr('id', itemInfo.fileName)
            .appendTo($dropzone).draggable(
                containment: 'parent'
                stop: (event, ui) ->
                    socket.emit('updateItemLocation', $(this).attr('id'), ui.offset.left * 100.0 / maxx(), ui.offset.top * 100.0 / maxy())
            ).offset(
                top: itemInfo.y / 100.0 * maxy()
                left: itemInfo.x / 100.0 * maxx()
            )

    $scope.addMessageToWorkspace = (string) ->
        data = {'text': string}
        $.ajax ({
            method: 'POST'
            url: '/api/text?group=' + $scope.groupName
            data: JSON.stringify(data)
            processData: false
            contentType: 'application/json; charset=utf-8'
        })

    hoverTextOn = ->
        $('#dropzone').addClass('hover')
        $('#dndText').text('Drop to upload')

    hoverTextOff = ->
        $('#dropzone').removeClass('hover')
        $('#dndText').text('Drag and drop files here')

    $dropzone.on 'dragover', (e) ->
        mouseX = e.originalEvent.offsetX
        mouseY = e.originalEvent.offsetY
        hoverTextOn()

    $dropzone.on 'dragleave', (e) ->
        hoverTextOff()

    $scope.chatVisible = true

    $scope.messages = []

    $scope.sendMessage = ->
        if $scope.newMessage and $scope.newMessage.trim().length > 0
            socket.emit('postNewMessage', $scope.newMessage)
            $scope.newMessage = ''

    $scope.removeMessage = (timestamp) ->
        socket.emit('postRemoveMessage', timestamp)


    $scope.hideChat = ->
        $scope.chatVisible = false

    $scope.showChat = ->
        $scope.chatVisible = true
