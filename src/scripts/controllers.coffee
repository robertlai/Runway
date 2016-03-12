angular.module('runwayAppControllers', ['runwayAppConstants', 'runwayAppServices', 'ui.router', 'ui.bootstrap'])

.controller 'loginController', [
    '$scope'
    '$state'
    '$q'
    'returnStateName'
    'returnStateParams'
    'AuthService'
    'Constants'
    (scope, state, q, returnStateName, returnStateParams, AuthService, Constants) ->
        scope.login = ->
            deferred = q.defer()

            scope.disableLogin = true
            scope.error = false
            AuthService.login(scope.loginForm.username, scope.loginForm.password)
                .then ->
                    if returnStateName
                        state.go(returnStateName, JSON.parse(returnStateParams))
                    else
                        state.go(Constants.DEFAULT_ROUTE)
                    scope.loginForm = {}
                    deferred.resolve()
                .catch (errorMessage) ->
                    scope.disableLogin = false
                    scope.error = errorMessage
                    scope.loginForm = {}
                    deferred.reject()

            return deferred.promise
]

.controller 'navBarController', [
    '$scope'
    '$q'
    '$state'
    'AuthService'
    (scope, q, state, AuthService) ->
        scope.username = AuthService.getUser().username

        scope.logout = ->
            deferred = q.defer()

            AuthService.logout()
                .then ->
                    state.go('login')
                    deferred.resolve()
                .catch ->
                    state.go('login')
                    deferred.reject()

            return deferred.promise
]

.controller 'settingsController', [
    '$scope'
    '$state'
    'AuthService'
    (scope, state, AuthService) ->
        scope.user = AuthService.getUser()
]

.controller 'registerController', [
    '$scope'
    '$q'
    '$state'
    'AuthService'
    (scope, q, state, AuthService) ->
        # todo: check for duplicate usernames when adding and editing users
        scope.register = ->
            deferred = q.defer()

            scope.disableRegister = true
            scope.error = false
            AuthService.register(scope.registerForm)
                .then ->
                    state.go('login')
                    scope.registerForm = {}
                    deferred.resolve()
                .catch (errorMessage) ->
                    scope.disableRegister = false
                    scope.error = errorMessage
                    scope.registerForm = {}
                    deferred.reject()

            return deferred.promise
]

.controller 'groupsController', ['$scope', '$uibModal', '$stateParams', 'groupService', (scope, uibModal, stateParams, groupService) ->
    scope.groups = []
    scope.groupType = stateParams.groupType
    groupService.getGroups(stateParams.groupType)
        .then (groups) ->
            scope.groups = groups
        .catch (error) ->
            scope.error = error

    scope.openEditGroupPropertiesModal = ($event, groupToEdit) ->
        $event.stopPropagation()
        modalInstance = uibModal.open(
            animation: true
            backdrop: 'static'
            resolve:
                editingGroup: groupToEdit
            templateUrl: '/partials/editGroupPropertiesModal.html'
            controller: 'editGroupPropertiesModalController'
        )
        modalInstance.result.then (editedGroup, deleteGroup = false) ->
            scope.error = null
            for group, index in scope.groups
                if group._id is editedGroup._id
                    if deleteGroup
                        scope.groups.splice(index, 1)
                    else
                        scope.groups[index] = editedGroup
                    break
            return

    scope.openEditGroupMembersModal = ($event, groupToEdit) ->
        $event.stopPropagation()
        modalInstance = uibModal.open(
            animation: true
            backdrop: 'static'
            size: 'lg'
            resolve:
                editingGroup: groupToEdit
            templateUrl: '/partials/editGroupMembersModal.html'
            controller: 'editGroupMembersModalController'
        )
        modalInstance.result.then (editedGroup) ->
            for group, index in scope.groups
                if group._id is editedGroup._id
                    scope.groups[index] = editedGroup
                    break
            return

    scope.openAddGroupModal = ->
        modalInstance = uibModal.open(
            animation: true
            backdrop: 'static'
            templateUrl: '/partials/addGroupModal.html'
            controller: 'addGroupModalController'
        )
        modalInstance.result.then (groupToAdd) ->
            scope.error = null
            scope.groups.push(groupToAdd)
]

.controller 'addGroupModalController', ['$scope', '$q', '$uibModalInstance', 'groupService', 'Constants',
(scope, q, uibModalInstance, groupService, Constants) ->

    scope.newGroup = {
        name: ''
        description: ''
        colour: Constants.DEFAULT_GROUP_COLOUR
    }

    scope.addGroup = ->
        deferred = q.defer()

        scope.disableModal = true
        groupService.addGroup(scope.newGroup)
            .then (addedGroup) ->
                uibModalInstance.close(addedGroup)
                deferred.resolve()
            .catch (message) ->
                scope.disableModal = false
                scope.error = message
                deferred.reject()

        return deferred.promise

    scope.cancel = ->
        uibModalInstance.dismiss()
]

.controller 'editGroupPropertiesModalController', ['$window', '$scope', '$q', '$uibModalInstance', 'groupService', 'editingGroup', 'Constants'
($window, scope, q, uibModalInstance, groupService, editingGroup, Constants) ->

    scope.editingGroup = angular.copy(editingGroup)

    scope.editGroup = ->
        deferred = q.defer()

        scope.disableModal = true
        groupService.editGroup(scope.editingGroup)
            .then (editedGroup) ->
                uibModalInstance.close(editedGroup)
                deferred.resolve()
            .catch (message) ->
                scope.disableModal = false
                scope.error = message
                deferred.reject()

        return deferred.promise

    scope.delete = ->
        deferred = q.defer()
        if $window.confirm(Constants.Messages.CONFIRM_GROUP_DELETE_1)
            if $window.confirm(Constants.Messages.CONFIRM_GROUP_DELETE_2)
                scope.disableModal = true
                groupService.deleteGroup(scope.editingGroup)
                    .then ->
                        uibModalInstance.close(scope.editingGroup, true)
                        deferred.resolve()
                    .catch (message) ->
                        scope.disableModal = false
                        scope.error = message
                        deferred.reject()
            else
                deferred.reject()
        else
            deferred.reject()

        return deferred.promise


    scope.cancel = ->
        uibModalInstance.dismiss()
]

.controller 'editGroupMembersModalController',
['$scope', '$q', '$http', '$uibModalInstance', 'AuthService', 'groupService', 'userService', 'editingGroup',
(scope, q, http, uibModalInstance, AuthService, groupService, userService, editingGroup) ->
    # todo: this should be passed an id / resolve the id of the group and populate everything before getting here
    # then all info will be present and the info doesn't have to be retuned from the modal and it becomes state free
    scope.owner = AuthService.getUser()

    scope.editingGroup = angular.copy(editingGroup)

    scope.getUsers = (query) ->
        deferred = q.defer()

        userService.getUsers(query)
            .then (members) ->
                deferred.resolve(members)
            .catch (message) ->
                scope.error = message
                deferred.reject()

        return deferred.promise

    scope.addMember = ->
        deferred = q.defer()

        scope.disableModal = true
        groupService.addMember(scope.editingGroup._id, scope.memberToAdd)
            .then ->
                scope.disableModal = false
                scope.editingGroup._members.push(scope.memberToAdd)
                scope.memberToAdd = null
                deferred.resolve()
            .catch (message) ->
                scope.disableModal = false
                scope.error = message
                deferred.reject()

        return deferred.promise


    scope.deleteMember = (member) ->
        'not implemented yet'

    scope.getMemberDisplay = (member) ->
        if member then member.username + ' (' + member.firstName + ' ' + member.lastName + ')' else ''

    scope.close = ->
        uibModalInstance.close(scope.editingGroup)
]

.controller 'workspaceController', ['$scope', '$state', '$stateParams', 'AuthService', 'Constants',
(scope, state, stateParams, AuthService, Constants) ->

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

    socket.on 'setGroup', (group) ->
        scope.group = group

    socket.on 'notAllowed', ->
        state.go(Constants.DEFAULT_ROUTE)

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
        for message, index in scope.messages
            if message._id is _message
                scope.messages.splice(index, 1)
                break
        scope.$apply()

    socket.on 'updateItem', (itemInfo) ->
        $('#' + itemInfo._id).offset ({
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
            .attr('id', itemInfo._id)
            .offset(
                top: itemInfo.y / 100.0 * maxy()
                left: itemInfo.x / 100.0 * maxx()
            )
            .appendTo($dropzone).draggable(
                containment: 'parent'
                stop: (event, ui) ->
                    socket.emit('updateItemLocation', itemInfo._id, ui.offset.left * 100.0 / maxx(), ui.offset.top * 100.0 / maxy())
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
        $('#dropzone').addClass('dropzoneHover')
        $('#dndText').text('Drop to upload')

    hoverTextOff = ->
        $('#dropzone').removeClass('dropzoneHover')
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
