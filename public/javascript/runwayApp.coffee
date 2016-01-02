runwayApp = angular.module('runwayApp', [ 'ngRoute' ])


runwayApp.config ($routeProvider) ->
    $routeProvider.when '/',
        title : 'Home',
        templateUrl: 'home'
        controller: 'homeController'
    .when '/workspace',
        title: 'Workspace'
        templateUrl: (params) ->
            'workspace?group=' + params.group
        controller: 'workspaceController'
    .otherwise
        redirectTo: '/'

runwayApp.run ['$rootScope', '$route', ($rootScope, $route) ->
    $rootScope.$on '$routeChangeSuccess', ->
        document.title = $route.current.title
]