angular.module('runwayAppControllers',
    ['runwayAppConstants', 'runwayAppServices', 'runwayAppDirectives', 'ui.router', 'ui.bootstrap', 'color.picker'])

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
    'User'
    (scope, q, state, AuthService, User) ->
        scope.username = User.username

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
    '$q'
    'User'
    'UserService'
    (scope, q, User, UserService) ->

        scope.generalSettings = {
            _id: User._id
            username: User.username
            firstName: User.firstName
            lastName: User.lastName
            email: User.email
        }
        scope.securitySettings = {
            _id: User._id
            searchability: User.searchability
        }

        scope.saveUserSettings = (userSettingsToSave) ->
            deferred = q.defer()
            UserService.saveUserSettings(userSettingsToSave)
                .then ->
                    deferred.resolve()
                .catch (errorMessage) ->
                    scope.error = errorMessage
                    deferred.reject()

            return deferred.promise

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

.controller 'groupsController', ['$scope', '$uibModal', '$stateParams', 'GroupService', 'AuthService',
(scope, uibModal, stateParams, GroupService, AuthService) ->
    scope.groups = []
    scope.groupType = stateParams.groupType
    GroupService.getGroups(stateParams.groupType)
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
                User: AuthService.getUser()
            templateUrl: '/partials/editGroupPropertiesModal.html'
            controller: 'editGroupPropertiesModalController'
        )
        # seem to have to pass an array or the second param is always lost...
        # todo: found out why passing args normally is not wokring here
        modalInstance.result.then ([newEditedGroupProperties, deleteGroup]) ->
            scope.error = null
            for group, index in scope.groups
                if group._id is newEditedGroupProperties._id
                    if deleteGroup
                        scope.groups.splice(index, 1)
                    else
                        angular.extend(scope.groups[index], newEditedGroupProperties)
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
                User: AuthService.getUser()
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

.controller 'addGroupModalController', ['$scope', '$q', '$uibModalInstance', 'GroupService', 'Constants',
(scope, q, uibModalInstance, GroupService, Constants) ->

    scope.newGroup = {
        name: ''
        description: ''
        colour: Constants.DEFAULT_GROUP_COLOUR
    }

    scope.addGroup = ->
        deferred = q.defer()

        scope.disableModal = true
        GroupService.addGroup(scope.newGroup)
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

# too: use window instead of $window
.controller 'editGroupPropertiesModalController',
['$window', '$scope', '$q', '$uibModalInstance', 'GroupService', 'editingGroup', 'User', 'Constants'
($window, scope, q, uibModalInstance, GroupService, editingGroup, User, Constants) ->

    scope.editingGroup = angular.copy(editingGroup)

    scope.canDelete = scope.editingGroup._owner is User._id

    scope.editGroup = ->
        deferred = q.defer()

        scope.disableModal = true
        GroupService.editGroup(scope.editingGroup)
            .then (newProperties) ->
                uibModalInstance.close([newProperties])
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
                GroupService.deleteGroup(scope.editingGroup)
                    .then ->
                        uibModalInstance.close([scope.editingGroup, true])
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
['$scope', '$q', '$http', '$uibModalInstance', 'GroupService', 'UserService', 'editingGroup', 'User',
(scope, q, http, uibModalInstance, GroupService, UserService, editingGroup, User) ->
    # todo: this should be passed an id / resolve the id of the group and populate everything before getting here
    # then all info will be present and the info doesn't have to be retuned from the modal and it becomes state free
    scope.owner = User

    scope.editingGroup = angular.copy(editingGroup)

    scope.canRemove = scope.editingGroup._owner is scope.owner._id

    scope.getUsers = (query) ->
        deferred = q.defer()

        UserService.findUsers(query)
            .then (members) ->
                deferred.resolve(members)
            .catch (message) ->
                scope.error = message
                deferred.reject()

        return deferred.promise

    scope.addMember = ->
        deferred = q.defer()

        scope.disableModal = true
        GroupService.addMember(scope.editingGroup._id, scope.memberToAdd)
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


    scope.removeMember = (_member) ->
        deferred = q.defer()

        scope.disableModal = true
        GroupService.removeMember(scope.editingGroup._id, _member)
            .then ->
                scope.disableModal = false
                for member, index in scope.editingGroup._members
                    if member._id is _member
                        scope.editingGroup._members.splice(index, 1)
                        break
                deferred.resolve()
            .catch (message) ->
                scope.disableModal = false
                scope.error = message
                deferred.reject()

        return deferred.promise

    scope.getMemberDisplay = (member) ->
        if member then member.username + ' (' + member.firstName + ' ' + member.lastName + ')' else ''

    scope.close = ->
        uibModalInstance.close(scope.editingGroup)
]

.controller 'workspaceController', ['$scope', '$q', '$state', '$stateParams', 'socket', 'User', 'Constants'
(scope, q, state, stateParams, socket, User, Constants) ->

    #expose for directives
    scope.socket = socket
    scope.chatVisible = true
    scope.user =  User

    socket.emit('groupConnect', scope.user, stateParams.groupId)

    deferredGroup = q.defer()

    socket._group = deferredGroup.promise

    socket.on 'setGroupId', (_group) ->
        deferredGroup.resolve(_group)

    socket.on 'notAllowed', ->
        state.go(Constants.DEFAULT_ROUTE)
]
