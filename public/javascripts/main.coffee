myApp = angular.module('myApp', ['ngRoute'])

myApp.config ($routeProvider) ->
    $routeProvider
    .when('/',
        templateUrl: 'partials/home'
        authenticated: true
    )
    .when('/login',
        templateUrl: 'partials/login'
        controller: 'loginController'
        authenticated: false
    )
    .when('/logout',
        controller: 'logoutController'
        authenticated: true
    )
    .when('/register',
        templateUrl: 'partials/register'
        controller: 'registerController'
        authenticated: true
    )
    .when('/one',
        template: '<h1>This is page one!</h1>'
        authenticated: true
    )
    .when('/two',
        template: '<h1>This is page two!</h1>'
        authenticated: true
    )
    .otherwise redirectTo: '/'


myApp.run ($rootScope, $location, $route, AuthService) ->
    $rootScope.$on '$routeChangeStart', (event, next, current) ->
        if next.authenticated and AuthService.isLoggedIn() is false
            $location.path '/login'
            $route.reload()
