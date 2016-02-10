homeApp = angular.module('homeApp', ['ui.router', 'ui.router.title'])


.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', (stateProvider, urlRouterProvider, locationProvider) ->
    locationProvider.html5Mode({ enabled: true })
    urlRouterProvider.otherwise('/')

    stateProvider
    .state('groups',
        url: '/groups/:groupType'
        params: groupType: 'owned'
        templateUrl: '/partials/groups'
        controller: 'groupsController'
        resolve: $title: -> 'Groups'
    )
    .state('manage',
        url: '/manage'
        templateUrl: '/partials/manage'
        controller: 'manageController'
    )
        .state('manage.list',
            url: '/:groupType'
            templateUrl: '/partials/manage-list'
            controller: 'manageListController'
            resolve: $title: -> 'Manage'
        )
        .state('manage.edit',
            abstract: true
            url: '/edit'
            templateUrl: '/partials/manage-edit'
            resolve: $title: -> 'Edit Group'
        )
            .state('manage.edit.owned',
                url: '/owned/:groupName'
                templateUrl: '/partials/manage-edit-owned'
                controller: 'editOwnedController'
                parent: 'manage.edit'
            )
            .state('manage.edit.joined',
                url: '/joined/:groupName'
                templateUrl: '/partials/manage-edit-joined'
                controller: 'editJoinedController'
                parent: 'manage.edit'
            )
    ]

.directive 'groupTypeTabs', ->
    restrist: 'E'
    templateUrl: '/partials/groupTypeTabs'
    replace: true
    controller: ['$scope', '$http', (scope, http) ->
        scope.$watch 'groupType', (newValue) ->
            http.get('/api/groups/' + newValue).then (groups) ->
                scope.groups = groups.data
                if groups.data.length is 0
                    if newValue is 'owned'
                        scope.error = 'You have no groups. Create one!'
                    else if newValue is 'joined'
                        scope.error = 'You have not been added to any groups.'
                else
                    scope.error = null
            , (err) ->
                scope.error = 'Server Error.  Please contact support.'
    ]

.controller 'groupsController', ($scope, $stateParams) ->
    $scope.groupType = $stateParams.groupType

.controller 'manageController', ['$scope', '$state', (scope, state) ->
    scope.$on '$stateChangeSuccess', (event, toState) ->
        state.go('manage.list') if toState.name is 'manage'
]

.controller 'manageListController', ['$scope', '$state', '$http', (scope, state, http) ->

    scope.$on '$stateChangeSuccess', (event, toState, toParams) ->
        state.go('manage.list', {groupType: 'owned'}) if toParams.groupType not in ['owned', 'joined']
        scope.groupType = toParams.groupType

        scope.addGroup = ->
            if scope.newGroupName and scope.newGroupName.trim().length > 0
                if scope.newGroupName.match(/[^A-Za-z0-9\-_ ]/)
                    scope.newGroupError = 'This group contains invalid characters.'
                else
                    http.post('/api/newGroup?newGroupName=' + scope.newGroupName).then (addedGroupName) ->
                        scope.groups.push(addedGroupName.data)
                        scope.newGroupName = ''
                        scope.newGroupError = null
                    , (err) ->
                        if err.status is 409
                            scope.newGroupError = 'This group already exists.'
                        else
                            scope.newGroupError = 'Server Error.  Please contact support.'
]

.controller 'editOwnedController', ['$rootScope', '$scope', '$state', '$stateParams', '$http', (rootScope, scope, state, stateParams, http) ->
    rootScope.editHeader = 'Edit Owned Group: ' + stateParams.groupName
]

.controller 'editJoinedController', ['$rootScope', '$scope', '$state', '$stateParams', '$http', (rootScope, scope, state, stateParams, http) ->
    rootScope.editHeader = 'Edit Joined Group: ' + stateParams.groupName
]
