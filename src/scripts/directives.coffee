angular.module('runwayAppDirectives', ['runwayAppConstants', 'runwayAppServices'])

.directive 'runwayDropzone', ['$compile', 'ItemService', ($compile, ItemService) ->
    restrict: 'A'
    scope:
        runwayDropzone: '@'
        socket: '='
    template: "<h1 class='dndText noselect'>Drag and drop files here</h1>"
    link: (scope, element, attrs) ->
        socket = scope.socket

        element.attr('id', scope.runwayDropzone)
        element.css('position', 'relative')

        scope.addNewItem = (itemInfo) ->
            newItem = undefined
            if itemInfo.type is 'text'
                newItem = $('<p />').attr('class', 'noselect').text(itemInfo.text)
            else if itemInfo.type.substring(0, 5) is 'image'
                newItem = $('<img />').attr('src', '/api/items/file?_file=' + itemInfo._id)
            else if itemInfo.type is 'application/pdf'
                newItem = $('<object data="/api/items/file?_file=' + itemInfo._id + '"/>')
                    .css('padding-top', '25px').css('background-color', '#525659')

            if newItem
                newItem.attr('runway-draggable', JSON.stringify(itemInfo))
                element.append($compile(newItem)(scope))

        socket._group.then (_group) ->
            scope._group = _group
            ItemService.getInitialItems(scope._group).then (items) ->
                scope.addNewItem(item) for item in items

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
                scope.mouseX = e.originalEvent.clientX
                scope.mouseY = e.originalEvent.clientY
                scope.hoverTextOn()
            .on 'dragleave', (e) ->
                scope.hoverTextOff()

        scope.myDropzone = new Dropzone $(element).get(0), {
            url: '/api/items/fileUpload'
            method: 'post'
            uploadMultiple: false
            maxFilesize: 9
            clickable: false
            createImageThumbnails: false
            autoProcessQueue: true
            acceptedFiles: 'image/*, application/pdf'
            accept: (file, done) ->
                scope.myDropzone.options.headers = {
                    '_group': scope._group
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
            scope.addNewItem(itemInfo)
]

.directive 'runwayDraggable', ['ItemService', (ItemService) ->
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
            ItemService.updateItemLocation(itemsInfo._id, ui.offset.left * 100.0 / scope.maxx(), ui.offset.top * 100.0 / scope.maxy())
]

.directive 'chatPanel', ['$http', 'MessageService', 'ItemService', (http, MessageService, ItemService) ->
    restrict: 'A'
    scope:
        socket: '='
        user: '='
    templateUrl: '/partials/chatPanel.html'
    replace: true
    link: (scope, element, attrs) ->
        socket = scope.socket

        scope.messages = []
        scope.messagesLoading = true

        chatBody = $('.chatBody', element)[0]

        socket._group.then (_group) ->
            scope._group = _group
            MessageService.getInitialMessages(scope._group).then (messages) ->
                setTimeout ->
                    scope.addMessageContent ->
                        scope.messages = messages
                    , true
                , 1

        # slight hack to easily test dom attributes
        scope.getDomAttribute = (elmt, attr) -> elmt[attr]

        scope.addMessageContent = (addFunction, all) ->
            scope.$digest()
            scrollAtBottom =
                all or
                Math.abs(
                    scope.getDomAttribute(chatBody, 'scrollTop') -
                    scope.getDomAttribute(chatBody, 'scrollHeight') +
                    scope.getDomAttribute(chatBody, 'offsetHeight')
                ) < 50
            addFunction()
            scope.messagesLoading = false
            scope.$digest()
            chatBody.scrollTop = scope.getDomAttribute(chatBody, 'scrollHeight') if scrollAtBottom

        socket.on 'newMessage', (message) ->
            scope.addMessageContent ->
                scope.messages.push(message)

        socket.on 'removeMessage', (_message) ->
            scope.addMessageContent ->
                for message, index in scope.messages
                    if message._id is _message
                        scope.messages.splice(index, 1)
                        break
                return

        scope.addMessageToWorkspace = (message) ->
            ItemService.postMessageToWorkspace(scope._group, message)

        scope.sendMessage = ->
            if scope.newMessage and scope.newMessage.trim().length > 0
                MessageService.addNewMessageToChat(scope._group, scope.newMessage)
                scope.newMessage = ''

        scope.removeMessage = (_message) ->
            MessageService.removeMessage(_message)

        $('.chatBody', element).on 'scroll', ->
            if not scope.allMessagesLoaded and chatBody.scrollTop is 0
                scope.messagesLoading = true
                scope.$digest()
                scope.preLoadScrollHeight = chatBody.scrollHeight
                MessageService.getMoreMessages(scope._group, scope.messages[scope.messages.length - 1].date).then (moreMessages) ->
                    scope.allMessagesLoaded = moreMessages.length is 0
                    chatBody.scrollTop = 1
                    setTimeout ->
                        scope.addMessageContent ->
                            scope.messages = scope.messages.concat(moreMessages)
                        chatBody.scrollTop = scope.getDomAttribute(chatBody, 'scrollHeight') - scope.preLoadScrollHeight
                    , 1

]
