angular.module('runwayApp')

.controller 'loginController', [
    '$rootScope'
    '$scope'
    '$state'
    'AuthService'
    (rootScope, scope, state, AuthService) ->
        AuthService.logout()
        scope.login = ->
            scope.disableLogin = true
            scope.error = false
            AuthService.login(scope.loginForm.username, scope.loginForm.password).then ->
                if rootScope.loginRedirect
                    state.go(rootScope.loginRedirect.stateName, rootScope.loginRedirect.stateParams)
                    delete rootScope.gloginRedirect
                else
                    state.go('home.groups')
                scope.loginForm = {}
            .catch (errorMessage) ->
                scope.disableLogin = false
                scope.error = errorMessage
                scope.loginForm = {}
]

.controller 'navBarController', [
    '$scope'
    '$state'
    'AuthService'
    (scope, state, AuthService) ->
        scope.username = AuthService.getUser().username

        scope.logout = ->
            AuthService.logout().then ->
                state.go('login')
]

.controller 'settingsController', [
    '$scope'
    '$state'
    'AuthService'
    (scope, state, AuthService) ->
        user = AuthService.getUser()
]

.controller 'registerController', [
    '$scope'
    '$state'
    'AuthService'
    (scope, state, AuthService) ->
        AuthService.logout()
        scope.register = ->
            scope.disableRegister = true
            scope.error = false
            AuthService.register(scope.registerForm)
                .then ->
                    state.go('login')
                    scope.registerForm = {}
                .catch (errorMessage) ->
                    scope.disableRegister = false
                    scope.error = errorMessage
                    scope.registerForm = {}
]

.controller 'groupsController', ['$scope', '$uibModal', '$stateParams', 'groupService', (scope, uibModal, stateParams, groupService) ->
    scope.groups = []
    scope.groupType = stateParams.groupType
    groupService.getGroups(stateParams.groupType)
        .then (groups) ->
            scope.groups = groups
        .catch (error) ->
            scope.error = error

    scope.openEditGroupModal = ($event) ->
        $event.stopPropagation()

    scope.openAddGroupModal = ->
        modalInstance = uibModal.open(
            animation: true
            templateUrl: '/partials/addGroupModal'
            controller: 'addGroupModalController'
        )
        modalInstance.result.then (groupToAdd) ->
            scope.error = null
            scope.groups.push(groupToAdd)
]

.controller 'addGroupModalController', ['$scope', '$uibModalInstance', 'groupService', (scope, uibModalInstance, groupService) ->

    scope.newGroup = {
        name: ''
        description: ''
        colour: '#0099CC'
    }

    scope.addGroup = ->
        scope.disableModal = true
        groupService.addGroup(scope.newGroup)
            .then (addedGroup) ->
                uibModalInstance.close(addedGroup)
            .catch (message) ->
                scope.disableModal = false
                scope.error = message

    scope.cancel = ->
        uibModalInstance.dismiss()
]

# todo: ensure that the user has permission to access this group
# should be checking this when they get here
# but also with every request for content from this group
.controller 'workspaceController', ['$scope', '$stateParams', 'AuthService', (scope, stateParams, AuthService) ->

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
            @options.url = '/api/fileUpload?_group=' + scope.group._id + '&x=' + mouseX * 100.0 / maxx() + '&y=' + mouseY * 100.0 / maxy()
            hoverTextOff()
            done()
    }

    myDropzone.on 'complete', (file) ->
        myDropzone.removeFile(file)

    socket = io()

    socket.on 'setupComplete', (group) ->
        scope.group = group
        socket.emit('getInitialMessages')
        socket.emit('getInitialItems')

    addMessageContent = (addFunction, all) ->
        scope.$apply()
        chatBody = document.getElementById('chatBody')
        scrollAtBottom = all || Math.abs(chatBody.scrollTop - chatBody.scrollHeight + chatBody.offsetHeight) < 50
        addFunction()
        scope.messagesLoading = false
        scope.$apply()
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
        scope.messages = scope.messages.filter (message) ->
            message._id isnt _message
        scope.$apply()

    socket.on 'updateItem', (itemInfo) ->
        $('#' + itemInfo.date).offset ({
            top: itemInfo.y / 100.0 * maxy()
            left: itemInfo.x / 100.0 * maxx()
        })

    socket.on 'newItem', (itemInfo) ->
        innerContent = undefined
        if itemInfo.type is 'text'
            innerContent = $('<p/>', class: 'noselect').text(itemInfo.text)
        else if itemInfo.type.substring(0, 5) is 'image'
            innerContent = $('<img/>', src: '/api/file?_file=' + itemInfo._id)
        else if itemInfo.type is 'application/pdf'
            innerContent = $('<div style="padding-top:25px; background-color:black;"><object data="/api/file?_file=' +
                itemInfo._id + "'/></div>")

        if innerContent
            innerContent.css('position', 'absolute')
            .attr('id', itemInfo.date)
            .offset(
                top: itemInfo.y / 100.0 * maxy()
                left: itemInfo.x / 100.0 * maxx()
            )
            .appendTo($dropzone).draggable(
                containment: 'parent'
                stop: (event, ui) ->
                    socket.emit('updateItemLocation', $(this).attr('id'), ui.offset.left * 100.0 / maxx(), ui.offset.top * 100.0 / maxy())
            )

    scope.addMessageToWorkspace = (string) ->
        data = {'text': string}
        $.ajax ({
            method: 'POST'
            url: '/api/text?_group=' + scope.group._id
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

    scope.chatVisible = true

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
            scope.$apply()
            scope.preLoadScrollHeight = chatBody.scrollHeight
            socket.emit('getMoreMessages', scope.messages[scope.messages.length - 1].date)

    init = ->
        scope.messagesLoading = true
        scope.user = AuthService.getUser()
        socket.emit('groupConnect', scope.user, stateParams.groupId)

    init()
]
