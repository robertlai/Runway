angular.module('runwayApp').controller 'workspaceController', ($scope) ->


    $dropzone = $('#dropzone')

    mouseX = undefined
    mouseY = undefined
    maxx = -> $dropzone.outerWidth()
    maxy = -> $dropzone.outerHeight()

    myDropzone = new Dropzone "#dropzone", {
        url: '/api/fileUpload'
        method: "post"
        uploadMultiple: false
        maxFilesize: 9
        clickable: false
        createImageThumbnails: false
        autoProcessQueue: true
        accept: (file, done) ->
            this.options.url = '/api/fileUpload?group=' + $scope.groupName + '&x=' + mouseX * 100.0 / maxx() + '&y=' + mouseY * 100.0 / maxy()
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
        socket.emit('getInitialPictures')


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

    socket.on 'initialPictures', (pictureInfos) ->
        addPicture(pictureInfo) for pictureInfo in pictureInfos
        $scope.$apply()

    socket.on 'updatePicture', (pictureInfo) ->
        $('#' + pictureInfo.fileName).offset ({
            top: pictureInfo.y / 100.0 * maxy()
            left: pictureInfo.x / 100.0 * maxx()
        })

    socket.on 'newPicture', (pictureInfo) ->
        addPicture(pictureInfo)

    reader = new FileReader

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
        # todo: do this differently
        tCtx = $('<canvas/>')[0].getContext('2d')
        tCtx.font = '20px Arial'
        tCtx.canvas.width = tCtx.measureText(str).width
        tCtx.canvas.height = 25
        tCtx.font = '20px Arial'
        tCtx.fillText str, 0, 20

        reader.onload = (arrayBuffer) ->
            $.ajax ({
                method: 'POST'
                url: '/api/picture?group=' + $scope.groupName + '&x=1&y=1'
                data: arrayBuffer.target.result
                processData: false
                contentType: 'application/binary'
            })

        reader.readAsArrayBuffer(dataURLtoBlob(tCtx.canvas.toDataURL()))

    addPicture = (pictureInfo) ->
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
        if hover
            $(e.target).addClass('hover')
            $('#dndText').text('Drop to upload')
        else
            $(e.target).removeClass('hover')
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
        if $scope.newMessage.trim().length > 0
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


    updateScrollState = ->
        scrollAtBottom = msgpanel.scrollTop == (msgpanel.scrollHeight - msgpanel.offsetHeight)

    scrollToBottom = ->
        if scrollAtBottom
            msgpanel.scrollTop = msgpanel.scrollHeight
