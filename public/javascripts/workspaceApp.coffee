app = angular.module('workspaceApp', [])

scrollAtBottom = true


app.controller 'workspaceController', ($scope, $http) ->

    maxx = -> $dropzone.outerWidth()
    maxy = -> $dropzone.outerHeight()

    socket = io()

    socket.on 'initialMessages', (messages) ->
        $scope.messages = messages
        $scope.$apply()
        scrollToBottom()

    socket.on 'newMessage', (message) ->
        $scope.messages.push(message)
        $scope.$apply()
        scrollToBottom()

    socket.on 'removeMessage', (timestamp) ->
        (
            if (message.timestamp == timestamp)
                $scope.messages.splice(i, 1)
                break
        ) for message, i in $scope.messages
        $scope.$apply()

    socket.on 'initialPictures', (pictureInfos) ->
        addPicture(pictureInfo) for pictureInfo in pictureInfos
        $scope.$apply()

    socket.on 'updatePicture', (pictureInfo) ->
        pictureInfo.x = 1 if pictureInfo.x == 0
        pictureInfo.y = 1 if pictureInfo.y == 0
        $('#' + pictureInfo.fileName).offset ({
            top: pictureInfo.y / 100.0 * maxy()
            left: pictureInfo.x / 100.0 * maxx()
        })

    socket.on 'newPicture', (pictureInfo) ->
        addPicture(pictureInfo)

    socket.emit('getInitialMessages')
    socket.emit('getInitialPictures')

    # raw js
    reader = new FileReader
    $dropzone = $('#dropzone')
    mousex = undefined
    mousey = undefined
    allPicturesInfo = []

    dataURLtoBlob = (dataurl) ->
        arr = dataurl.split(',')
        mime = arr[0].match(/:(.*?);/)[1]
        bstr = atob(arr[1])
        n = bstr.length
        u8arr = new Uint8Array(n)
        while n--
            u8arr[n] = bstr.charCodeAt(n)
        return new Blob([ u8arr ], type: mime)


    $scope.buttonClicked = (str) ->
        tCtx = $('<canvas/>')[0].getContext('2d')
        tCtx.font = '20px Arial'
        tCtx.canvas.width = tCtx.measureText(str).width
        tCtx.canvas.height = 25
        tCtx.font = '20px Arial'
        tCtx.fillText str, 0, 20

        reader.onload = (arrayBuffer) ->
            $.ajax ({
                method: 'POST'
                url: '/api/picture?x=1&y=1'
                data: arrayBuffer.target.result
                processData: false
                contentType: 'application/binary'
            })

        reader.readAsArrayBuffer(dataURLtoBlob(tCtx.canvas.toDataURL()))

    addPicture = (pictureInfo) ->
        if pictureInfo.x == 0
            pictureInfo.x = 1
        if pictureInfo.y == 0
            pictureInfo.y = 1
        allPicturesInfo.push pictureInfo.fileName
        $('<img/>', src: '/api/picture?fileToGet=' + pictureInfo.fileName).appendTo($dropzone).wrap('<div id=' + pictureInfo.fileName + ' style=\'position:absolute;\'></div>').parent().offset(
            top: pictureInfo.y / 100.0 * maxy()
            left: pictureInfo.x / 100.0 * maxx()).draggable(
                containment: 'parent'
                cursor: 'move'
                stop: (event, ui) ->
                    socket.emit('updatePictureLocation', $(this).attr('id'), ui.offset.left * 100.0 / maxx(), ui.offset.top * 100.0 / maxy())
            ).on 'resize', ->
                width = $(this).outerWidth()
                height = $(this).outerHeight()

    drop = (e, hover) ->
        e.preventDefault()
        e.stopPropagation()
        if hover
            $(e.target).addClass('hover')
            $('#dndText').text('Drop to upload')
        else
            $(e.target).removeClass('hover')
            $('#dndText').text('Drag and drop files here')


    $(document).on 'mousemove', (e) ->
        mousex = e.pageX
        mousey = e.pageY

    $dropzone.on 'dragover', (e) ->
        drop(e, true)

    $dropzone.on 'dragleave', (e) ->
        drop(e, false)

    $dropzone.on 'drop', (e) ->
        drop(e, false)
        if e.originalEvent.dataTransfer
            if e.originalEvent.dataTransfer.files.length
                f = e.originalEvent.dataTransfer.files[0]
                reader.onload = (arrayBuffer) ->
                    $.ajax ({
                        method: 'POST'
                        url: '/api/picture?x=' + mousex * 100.0 / maxx() + '&y=' + mousey * 100.0 / maxy()
                        data: arrayBuffer.target.result
                        processData: false
                        contentType: 'application/binary'
                    })

                reader.readAsArrayBuffer(f)


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
            socket.emit('postNewMessage', message)
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
    msgpanel = document.getElementById("msgpanel")
    msgpanel.scrollTop = msgpanel.scrollHeight

updateScrollState = ->
    scrollAtBottom = msgpanel.scrollTop == (msgpanel.scrollHeight - msgpanel.offsetHeight)

scrollToBottom = ->
    if scrollAtBottom
        msgpanel.scrollTop = msgpanel.scrollHeight
