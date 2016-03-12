describe 'controllers', ->

    beforeEach(module('runwayAppServices'))

    Constants = undefined
    AuthService = undefined
    groupService = undefined
    userService = undefined
    $controller = undefined
    mockCredentials = undefined
    resolvedPromiseFunc = undefined
    rejectedPromiseFunc = undefined
    $state = undefined
    $rootScope = undefined
    scope = undefined
    $window = undefined
    uibModalInstance = undefined
    uibModal = undefined


    beforeEach inject ($q, _Constants_, _$rootScope_, _$httpBackend_) ->
        Constants = _Constants_
        $rootScope = _$rootScope_
        $httpBackend = _$httpBackend_
        scope = {}

        resolvedPromiseFunc = (value) ->
            deferred = $q.defer()
            deferred.resolve(value)
            deferred.promise

        rejectedPromiseFunc = (value) ->
            deferred = $q.defer()
            deferred.reject(value)
            deferred.promise


    describe 'AuthService', ->

        AuthService = undefined

        beforeEach inject (_AuthService_) ->
            AuthService = _AuthService_


        describe 'getUser', ->

            beforeEach ->


        describe 'loggedIn', ->

            beforeEach ->


        describe 'login', ->

            beforeEach ->


        describe 'logout', ->

            beforeEach ->


        describe 'register', ->

            beforeEach ->




    describe 'GroupService', ->

        groupService = undefined

        beforeEach inject (_groupService_) ->
            groupService = _groupService_


    describe 'UserService', ->

        userService = undefined

        beforeEach inject (_userService_) ->
            userService = _userService_
