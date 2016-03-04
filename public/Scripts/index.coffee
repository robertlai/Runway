runwayApp = angular.module('runwayApp', ['ui.router', 'ui.router.title', 'ui.bootstrap', 'color.picker'])


.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', 'Constants', (stateProvider, urlRouterProvider, locationProvider, Constants) ->
    locationProvider.html5Mode({ enabled: true })
    urlRouterProvider.otherwise('/home/groups/' + Constants.OWNED_GROUP)

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
        .state('home.settings',
            abstract: true
            url: '/settings'
            replace: true
            resolve: $title: -> 'Account Setting'
            templateUrl: '/partials/settings'
            controller: 'settingsController'
        )
            .state('home.settings.general',
                url: '/general'
                authenticated: true
                templateUrl: '/partials/settings-general'
            )
            .state('home.settings.security',
                url: '/security'
                authenticated: true
                templateUrl: '/partials/settings-security'
            )
        .state('home.groups',
            url: '/groups/:groupType'
            params: groupType: Constants.OWNED_GROUP
            resolve: $title: -> 'Groups'
            authenticated: true
            templateUrl: '/partials/groups'
            controller: 'groupsController'
        )
    .state('workspace',
        url: '/workspace/:groupId'
        params: groupId: 'groupId'
        resolve: $title: -> 'Workspace'
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
            AuthService.loggedIn()
                .catch (error) ->
                    rootScope.loginRedirect = {
                        stateName: nextState.name
                        stateParams: nextParams
                    }
                    state.go('login')
]
