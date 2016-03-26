angular.module('runwayAppDirectives', ['runwayAppConstants'])

.directive 'runwayDropzone', ['$compile', ($compile) ->
    restrict: 'A'
    scope:
        runwayDropzone: '@'
        socket: '='
    template: "<h1 class='dndText noselect'>Drag and drop files here</h1>"
    link: (scope, element, attrs) ->
        socket = scope.socket

        element.attr('id', scope.runwayDropzone)
        element.css('position', 'relative')

        socket.on 'setGroup', (group) ->
            scope.group = group
            socket.emit('getInitialItems')

        scope.mouseX = null
        scope.mouseY = null
        scope.maxx = -> $(element).outerWidth()
        scope.maxy = -> $(element).outerHeight()

        scope.hoverTextOn = ->
            $(element).addClass('dropzoneHover')
            $('.dndText', element).text('Drop to upload')

        scope.hoverTextOff = ->
            $(element).removeClass('dropzoneHover')
            $('.dndText', element).text('Drag and drop files here')

        $(element)
            .on 'dragover', (e) ->
                scope.mouseX = e.clientX
                scope.mouseY = e.clientY
                scope.hoverTextOn()
            .on 'dragleave', (e) ->
                scope.hoverTextOff()

        scope.myDropzone = new Dropzone $(element).get(0), {
            url: '/api/fileUpload'
            method: 'post'
            uploadMultiple: false
            maxFilesize: 9
            clickable: false
            createImageThumbnails: false
            autoProcessQueue: true
            acceptedFiles: 'image/*, application/pdf'
            accept: (file, done) ->
                scope.myDropzone.options.headers = {
                    '_group': scope.group._id
                    screenwidth: scope.maxx()
                    screenheight: scope.maxy()
                    x: scope.mouseX
                    y: scope.mouseY
                }
                scope.hoverTextOff()
                done()
        }

        scope.myDropzone.on 'complete', (file) ->
            scope.myDropzone.removeFile(file)

        socket.on 'newItem', (itemInfo) ->
            newItem = undefined
            if itemInfo.type is 'text'
                newItem = $('<p />').attr('class', 'noselect').text(itemInfo.text)
            else if itemInfo.type.substring(0, 5) is 'image'
                newItem = $('<img />').attr('src', '/api/file?_file=' + itemInfo._id)
            else if itemInfo.type is 'application/pdf'
                newItem = $('<object data="/api/file?_file=' + itemInfo._id + '"/>').css('padding-top', '25px').css('background-color', '#525659')

            if newItem
                newItem.attr('runway-draggable', JSON.stringify(itemInfo))
                element.append($compile(newItem)(scope))
]

.directive 'runwayDraggable', [ ->
    restrict: 'A'
    scope: false
    link: (scope, element, attrs) ->
        socket = scope.socket

        itemsInfo = JSON.parse(attrs.runwayDraggable)

        setPosition = ->
            $(element)
                .css('top', itemsInfo.y + '%')
                .css('left', itemsInfo.x + '%')

        socket.on 'updateItem', (itemInfo) ->
            if itemInfo._id is itemsInfo._id
                itemsInfo.x = itemInfo.x
                itemsInfo.y = itemInfo.y
                setPosition()

        $(element)
            .css('top', itemsInfo.y + '%')
            .css('left', itemsInfo.x + '%')
            .css('position', 'absolute')
            .css('width', if itemsInfo.width then itemsInfo.width + '%' else null)
            .css('height', if itemsInfo.height then itemsInfo.height + '%' else null)
            .css('max-width', '50%')
            .css('max-height', '50%')
            .draggable(
                stack: '[runway-draggable]'
                containment: 'parent'
            )

        $(element).on 'dragstop', (event, ui) ->
            socket.emit('updateItemLocation', itemsInfo._id, ui.offset.left * 100.0 / scope.maxx(), ui.offset.top * 100.0 / scope.maxy())
]

.directive 'chatPanel', ['$http', '$state', 'Constants'
(http, state, Constants) ->
    restrict: 'A'
    scope:
        socket: '='
        user: '='
    templateUrl: '/partials/chatPanel.html'
    replace: true
    link: (scope, element, attrs) ->
        socket = scope.socket
        console.log socket

        scope.messagesLoading = true

        socket.on 'setGroup', (group) ->
            scope.group = group
            socket.emit('getInitialMessages')

        socket.on 'notAllowed', ->
            state.go(Constants.DEFAULT_ROUTE)

        addMessageContent = (addFunction, all) ->
            scope.$digest()
            chatBody = document.getElementById('chatBody')
            scrollAtBottom = all or Math.abs(chatBody.scrollTop - chatBody.scrollHeight + chatBody.offsetHeight) < 50
            addFunction()
            scope.messagesLoading = false
            scope.$digest()
            chatBody.scrollTop = chatBody.scrollHeight if scrollAtBottom

        socket.on 'initialMessages', (messages) ->
            addMessageContent ->
                scope.messages = messages
            , true

        socket.on 'moreMessages', (moreMessages) ->
            scope.allMessagesLoaded = moreMessages.length is 0
            chatBody = document.getElementById('chatBody')
            chatBody.scrollTop = 1
            addMessageContent ->
                scope.messages = scope.messages.concat(moreMessages)
            chatBody.scrollTop = chatBody.scrollHeight - scope.preLoadScrollHeight

        socket.on 'newMessage', (message) ->
            addMessageContent ->
                scope.messages.push(message)

        socket.on 'removeMessage', (_message) ->
            addMessageContent ->
                for message, index in scope.messages
                    if message._id is _message
                        scope.messages.splice(index, 1)
                        break

        scope.addMessageToWorkspace = (string) ->
            http.post('/api/text', { _group: scope.group._id, text: string })

        scope.messages = []

        scope.sendMessage = ->
            if scope.newMessage and scope.newMessage.trim().length > 0
                socket.emit('postNewMessage', scope.newMessage)
                scope.newMessage = ''

        scope.removeMessage = (_message) ->
            socket.emit('postRemoveMessage', _message)

        $('#chatBody').on 'scroll', (event) ->
            chatBody = document.getElementById('chatBody')
            if !scope.allMessagesLoaded and chatBody.scrollTop is 0
                scope.messagesLoading = true
                scope.$digest()
                scope.preLoadScrollHeight = chatBody.scrollHeight
                socket.emit('getMoreMessages', scope.messages[scope.messages.length - 1].date)

]
