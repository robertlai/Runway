runwayApp = angular.module('runwayApp', ['ui.router', 'ui.router.title'])


.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', (stateProvider, urlRouterProvider, locationProvider) ->
    locationProvider.html5Mode({ enabled: true })
    urlRouterProvider.otherwise('/')

    stateProvider
    .state('login',
        url: '/login'
        templateUrl: 'partials/login'
        controller: 'loginController'
        resolve: $title: -> 'Login'
        authenticated: false
    )
    .state('register',
        url: '/register'
        templateUrl: 'partials/register'
        controller: 'registerController'
        resolve: $title: -> 'Register'
        authenticated: false
    )
    .state('/',
        url: '/'
        templateUrl: '/partials/home'
        resolve: $title: -> 'Home'
        authenticated: true
    )
    .state('one',
        url: '/one'
        template: '<h1>This is page one!</h1>'
        resolve: $title: -> 'One"s Title'
        authenticated: true
    )
    .state('two',
        url: '/two'
        template: '<h1>This is page two!</h1>'
        resolve: $title: -> 'One"s Title'
        authenticated: false
    )
]


.run ['$rootScope', '$state', 'AuthService', '$http', (rootScope, state, AuthService, http) ->
    rootScope.$on '$stateChangeStart', (event, nextState, nextParams) ->
        AuthService.isLoggedIn().then (isLoggedIn) ->
            if nextState.authenticated and !isLoggedIn
                rootScope.loginRedirect = {
                    stateName: nextState.name
                    stateParams: nextParams
                }
                state.go('login')
]
