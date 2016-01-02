app = angular.module('workspaceApp', [])

scrollAtBottom = true


app.controller 'workspaceController', ($scope) ->

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
        accept: (file, done) ->
            this.options.url = '/api/fileUpload?group=' + $scope.groupName + '&x=' + mouseX * 100.0 / maxx() + '&y=' + mouseY * 100.0 / maxy() + '&type=image/jpeg'
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
        $scope.messages = messages
        $scope.$apply()
        scrollToBottom()

    socket.on 'newMessage', (message) ->
        $scope.messages.push(message)
        $scope.$apply()
        scrollToBottom()

    socket.on 'removeMessage', (timestamp) ->
        $scope.messages = $scope.messages.filter (message) ->
            message.timestamp != timestamp
        $scope.$apply()

    socket.on 'updateItem', (itemInfo) ->
        $('#' + itemInfo.fileName).offset ({
            top: itemInfo.y / 100.0 * maxy()
            left: itemInfo.x / 100.0 * maxx()
        })

    socket.on 'newItem', (itemInfo) ->
        innerContent = undefined
        if itemInfo.type == 'text'
            innerContent = $('<p/>', class: 'noselect').text(itemInfo.text)
        else if itemInfo.type == 'image/jpeg'
            innerContent = $('<img/>', src: '/api/picture?fileToGet=' + itemInfo.fileName + '&groupName=' + $scope.groupName)
        else
            # unsuported constnet

        if innerContent
            innerContent.appendTo($dropzone).wrap('<div id=' + itemInfo.fileName + ' style=\'position:absolute;\'></div>').parent().offset(
                top: itemInfo.y / 100.0 * maxy()
                left: itemInfo.x / 100.0 * maxx()).draggable(
                    containment: 'parent'
                    cursor: 'move'
                    stop: (event, ui) ->
                        socket.emit('updateItemLocation', $(this).attr('id'), ui.offset.left * 100.0 / maxx(), ui.offset.top * 100.0 / maxy())
                ).on 'resize', ->
                    width = $(this).outerWidth()
                    height = $(this).outerHeight()

    $scope.buttonClicked = (string) ->
        data = {'text': string}
        $.ajax ({
            method: 'POST'
            url: '/api/text?group=' + $scope.groupName
            data: JSON.stringify(data)
            processData: false
            contentType: 'application/json; charset=utf-8'
        })

    drop = (e, hover) ->
        if hover
            hoverTextOn()
        else
            hoverTextOff()

    hoverTextOn = (e) ->
        $('#dropzone').addClass('hover')
        $('#dndText').text('Drop to upload')

    hoverTextOff = (e) ->
        $('#dropzone').removeClass('hover')
        $('#dndText').text('Drag and drop files here')

    $dropzone.on 'dragover', (e) ->
        mouseX = e.originalEvent.offsetX
        mouseY = e.originalEvent.offsetY
        drop(e, true)

    $dropzone.on 'dragleave', (e) ->
        drop(e, false)


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
        document.getElementById('dropzone').style.width = '100%'

    $scope.showChat = ->
        $scope.chatVisible = true
        document.getElementById('dropzone').style.width = '75%'



window.onload = ->
    msgpanel = document.getElementById('msgpanel')
    msgpanel.scrollTop = msgpanel.scrollHeight

updateScrollState = ->
    scrollAtBottom = msgpanel.scrollTop == (msgpanel.scrollHeight - msgpanel.offsetHeight)

scrollToBottom = ->
    if scrollAtBottom
        msgpanel.scrollTop = msgpanel.scrollHeight
