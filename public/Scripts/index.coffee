runwayApp = angular.module('runwayApp', ['ui.router', 'ui.router.title', 'ui.bootstrap', 'ngAnimate'])


.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', (stateProvider, urlRouterProvider, locationProvider) ->
    locationProvider.html5Mode({ enabled: true })
    urlRouterProvider.otherwise('/home/groups/owned')

    stateProvider
    .state('login',
        url: '/login'
        resolve: $title: -> 'Login'
        authenticated: false
        views: {
            'content@': {
                templateUrl: '/partials/login'
                controller: 'loginController'
            }
        }
    )
    .state('register',
        url: '/register'
        resolve: $title: -> 'Register'
        authenticated: false
        views: {
            'content@': {
                templateUrl: '/partials/register'
                controller: 'registerController'
            }
        }
    )
    .state('home',
        abstract: true
        url: '/home'
        replace: true
        views: {
            'navBar@': {
                replace: true
                templateUrl: '/partials/navBar'
                controller: 'navBarController'
            }
            'content@': {
                template: '<div ui-view class="homeUiView"></div>'
            }
        }
    )
    .state('home.one',
        url: '/one'
        resolve: $title: -> 'One"s Title'
        authenticated: true
        template: '<h1>This is page one!</h1>'
    )
    .state('home.two',
        url: '/two'
        resolve: $title: -> 'One"s Title'
        authenticated: true
        template: '<h1>This is page two!</h1>'
    )
    .state('home.groups',
        url: '/groups/:groupType'
        params: groupType: 'owned'
        resolve: $title: -> 'Groups'
        authenticated: true
        templateUrl: '/partials/groups'
        controller: 'groupsController'
    )
    .state('home.manage',
        url: '/manage'
        resolve: $title: -> 'Manage'
        authenticated: true
        templateUrl: '/partials/manage'
        controller: 'manageController'
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
