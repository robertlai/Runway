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
                if rootScope.loginRedirect.stateName
                    state.go(rootScope.loginRedirect.stateName, rootScope.loginRedirect.stateParams)
                    delete rootScope.loginRedirect
                else
                    state.go('/')
                scope.disabled = false
                scope.loginForm = {}
            .catch ->
                scope.error = true
                scope.errorMessage = 'Invalid username and/or password'
                scope.disabled = false
                scope.loginForm = {}
]

.controller 'logoutController', [
    '$scope'
    '$location'
    'AuthService'
    (scope, location, AuthService) ->

        scope.logout = ->
            AuthService.logout().then ->
                location.path '/login'
]

.controller 'registerController', [
    '$scope'
    '$location'
    'AuthService'
    (scope, location, AuthService) ->

        scope.register = ->
            scope.error = false
            scope.disabled = true
            AuthService.register(scope.registerForm.username, scope.registerForm.password).then ->
                location.path '/login'
                scope.disabled = false
                scope.registerForm = {}
            .catch ->
                scope.error = true
                scope.errorMessage = 'Something went wrong!'
                scope.disabled = false
                scope.registerForm = {}
]
