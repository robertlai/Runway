angular.module('runwayApp')

.controller 'loginController', [
    '$rootScope'
    '$scope'
    '$state'
    'AuthService'
    (rootScope, scope, state, AuthService) ->
        scope.login = ->
            scope.error = false
            scope.disabled = true
            AuthService.login(scope.loginForm.username, scope.loginForm.password).then ->
                if rootScope.loginRedirect
                    state.go(rootScope.loginRedirect.stateName, rootScope.loginRedirect.stateParams)
                    delete rootScope.loginRedirect
                else
                    state.go('/')
                scope.disabled = false
                scope.loginForm = {}
            .catch (errorMessage) ->
                scope.error = errorMessage
                scope.disabled = false
                scope.loginForm = {}
]

.controller 'logoutController', [
    '$scope'
    '$state'
    'AuthService'
    (scope, state, AuthService) ->

        scope.logout = ->
            AuthService.logout().then ->
                state.go('login')
]

.controller 'registerController', [
    '$scope'
    '$state'
    'AuthService'
    (scope, state, AuthService) ->

        scope.register = ->
            scope.error = false
            scope.disabled = true
            AuthService.register(scope.registerForm.username, scope.registerForm.password).then ->
                state.go('login')
                scope.disabled = false
                scope.registerForm = {}
            .catch (errorMessage) ->
                scope.error = errorMessage
                scope.disabled = false
                scope.registerForm = {}
]
