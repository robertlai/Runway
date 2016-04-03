angular.module('runwayAppRoutes', ['runwayAppConstants', 'runwayAppServices', 'ui.router', 'ui.router.title'])

.config ['$stateProvider', '$httpProvider', '$urlRouterProvider', '$locationProvider', 'Constants',
(stateProvider, httpProvider, urlRouterProvider, locationProvider, Constants) ->

    locationProvider.html5Mode({ enabled: true })
    urlRouterProvider.otherwise('/home/groups/' + Constants.OWNED_GROUP)

    httpProvider.interceptors.push ->
        {
            responseError: (response) ->
                if response.status is 401
                    window.alert(Constants.Messages.NOT_AUTHORIZED)
                return response
        }

    stateProvider
    .state('login',
        url: '/login?returnStateName&returnStateParams'
        resolve:
            $title: -> 'Login'
            returnStateName: ['$stateParams', (stateParams) ->
                stateParams.returnStateName
            ]
            returnStateParams: ['$stateParams', (stateParams) ->
                stateParams.returnStateParams
            ]
        authenticated: false
        views: {
            'content@': {
                templateUrl: '/partials/login.html'
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
                templateUrl: '/partials/register.html'
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
                templateUrl: '/partials/navBar.html'
                controller: 'navBarController'
                resolve: User: (AuthService) -> AuthService.getUser()
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
            resolve:
                $title: -> 'Account Settings'
                User: (AuthService) -> AuthService.getUser()
            templateUrl: '/partials/settings.html'
            controller: 'settingsController'
        )
            .state('home.settings.general',
                url: '/general'
                authenticated: true
                templateUrl: '/partials/settings-general.html'
            )
            .state('home.settings.security',
                url: '/security'
                authenticated: true
                templateUrl: '/partials/settings-security.html'
            )
        .state('home.groups',
            url: '/groups/:groupType'
            params: groupType: Constants.OWNED_GROUP
            resolve: $title: -> 'Groups'
            authenticated: true
            templateUrl: '/partials/groups.html'
            controller: 'groupsController'
        )
    .state('workspace',
        url: '/workspace/:groupId'
        params: groupId: 'groupId'
        resolve:
            $title: -> 'Workspace'
            User: (AuthService) -> AuthService.getUser()
            socket: (Socket) -> new Socket()
        authenticated: true
        views: {
            'content@': {
                templateUrl: '/partials/workspace.html'
                controller: 'workspaceController'
            }
        }
    )
]

.run ['$rootScope', '$state', 'AuthService', (rootScope, state, AuthService) ->
    rootScope.$on '$stateChangeStart', (event, nextState, nextParams) ->
        if nextState.authenticated
            AuthService.getUser()
                .catch (error) ->
                    state.go('login', {
                        returnStateName: nextState.name
                        returnStateParams: JSON.stringify(nextParams)
                    })
]
