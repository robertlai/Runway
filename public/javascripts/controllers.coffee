angular.module('myApp').controller 'loginController', [
    '$scope'
    '$location'
    'AuthService'
    (scope, location, AuthService) ->

        scope.login = ->
            scope.error = false
            scope.disabled = true
            AuthService.login(scope.loginForm.username, scope.loginForm.password).then ->
                location.path '/'
                scope.disabled = false
                scope.loginForm = {}
            .catch ->
                scope.error = true
                scope.errorMessage = 'Invalid username and/or password'
                scope.disabled = false
                scope.loginForm = {}
]


angular.module('myApp').controller 'logoutController', [
    '$scope'
    '$location'
    'AuthService'
    (scope, location, AuthService) ->

        scope.logout = ->
            AuthService.logout().then ->
                location.path '/login'
]

angular.module('myApp').controller 'registerController', [
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
