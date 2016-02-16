angular.module('runwayApp')

.controller 'loginController', [
    '$rootScope'
    '$scope'
    '$state'
    'AuthService'
    (rootScope, scope, state, AuthService) ->
        AuthService.logout()
        scope.login = ->
            scope.error = false
            AuthService.login(scope.loginForm.username, scope.loginForm.password).then ->
                if rootScope.loginRedirect
                    state.go(rootScope.loginRedirect.stateName, rootScope.loginRedirect.stateParams)
                    delete rootScope.loginRedirect
                else
                    state.go('home.one')
                scope.loginForm = {}
            .catch (errorMessage) ->
                scope.error = errorMessage
                scope.loginForm = {}
]

.controller 'navBarController', [
    '$scope'
    '$state'
    'AuthService'
    (scope, state, AuthService) ->
        scope.user = AuthService.getUser()

        scope.logout = ->
            AuthService.logout().then ->
                state.go('login')
]

.controller 'registerController', [
    '$scope'
    '$state'
    'AuthService'
    (scope, state, AuthService) ->
        AuthService.logout()
        scope.register = ->
            scope.error = false
            AuthService.register(scope.registerForm.username, scope.registerForm.password)
                .then ->
                    state.go('login')
                    scope.registerForm = {}
                .catch (errorMessage) ->
                    scope.error = errorMessage
                    scope.registerForm = {}
]

.controller 'groupsController', ['$scope', '$stateParams', 'groupService', (scope, stateParams, groupService) ->
    scope.groups = []
    scope.groupType = stateParams.groupType
    groupService.getGroups(stateParams.groupType)
        .then (groups) ->
            scope.groups = groups
        .catch (error) ->
            scope.error = error
]

.controller 'manageController', ['$scope', '$uibModal', 'groupService', (scope, uibModal, groupService) ->
    scope.groups = []
    groupService.getGroups('owned')
        .then (groups) ->
            scope.groups = groups
        .catch (error) ->
            scope.error = error

    scope.openAddGroupModal = ->
        modalInstance = uibModal.open(
            animation: true
            templateUrl: '/partials/addGroupModal'
            controller: 'addGroupModalController'
        )
        modalInstance.result.then (groupToAdd) ->
            scope.groups.push(groupToAdd)
]

.controller 'addGroupModalController', ['$scope', '$uibModalInstance', 'groupService', (scope, uibModalInstance, groupService) ->
    scope.addGroup = ->
        # todo: make it evident that this is doing something (loading spinner?)
        groupService.addGroup(scope.newGroupName)
            .then (newGroup) ->
                uibModalInstance.close(newGroup)
            .catch (message) ->
                scope.error = message

    scope.cancel = ->
        uibModalInstance.dismiss()
]
