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
    .state('workspace',
        url: '/workspace/:groupName'
        params: groupName: 'groupName'
        resolve: $title: -> 'Workspace: ' + 'groupName'
        authenticated: true
        views: {
            'content@': {
                templateUrl: '/partials/workspace'
                controller: 'workspaceController'
            }
        }
    )
]

# todo: add angular interceptor to handle a similar situation as below but for http requests
.run ['$rootScope', '$state', 'AuthService', (rootScope, state, AuthService) ->
    rootScope.$on '$stateChangeStart', (event, nextState, nextParams) ->
        if nextState.authenticated
            AuthService.isLoggedIn()
                .catch (error) ->
                    rootScope.loginRedirect = {
                        stateName: nextState.name
                        stateParams: nextParams
                    }
                    state.go('login')
]
