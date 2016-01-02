runwayApp = angular.module('runwayApp', [ 'ngRoute' ])

scrollAtBottom = true


runwayApp.config ($routeProvider) ->
    $routeProvider.when '/',
        templateUrl: 'home'
        controller: 'homeController'
    .when '/workspace',
        templateUrl: 'workspace'
        templateUrl: (params) ->
            'workspace?group=' + params.group
        controller: 'workspaceController'
    .otherwise
        redirectTo: '/'
