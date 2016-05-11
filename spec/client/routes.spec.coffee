describe 'Routes', ->

    resolvedPromiseFunc = undefined
    rejectedPromiseFunc = undefined
    Constants = undefined
    httpBackend = undefined
    $locationProvider = undefined
    $httpProvider = undefined
    $urlRouterProvider = undefined
    $state = undefined
    $stateParams = undefined
    $injector = undefined
    $rootScope = undefined

    beforeEach ->
        angular.module('preTestConfig', ['ui.router']).config (_$urlRouterProvider_, _$locationProvider_, _$httpProvider_) ->
            $locationProvider = _$locationProvider_
            $httpProvider = _$httpProvider_
            $urlRouterProvider = {
                otherwise: ->
            }
            $urlRouterProvider = _$urlRouterProvider_
            spyOn($locationProvider, 'html5Mode')
            spyOn($urlRouterProvider, 'otherwise')
            spyOn($httpProvider.interceptors, 'push').and.callThrough()

        module('preTestConfig')
        module('runwayAppRoutes')

        inject (_Constants_, _$state_, _$httpBackend_, _$injector_, _$rootScope_, $q) ->
            Constants = _Constants_
            $state = _$state_
            httpBackend = _$httpBackend_
            $injector = _$injector_
            $rootScope = _$rootScope_

            resolvedPromiseFunc = (value) ->
                deferred = $q.defer()
                deferred.resolve(value)
                deferred.promise

            rejectedPromiseFunc = (value) ->
                deferred = $q.defer()
                deferred.reject(value)
                deferred.promise

    describe 'setup', ->

        it 'should set html5 mode with the correct options', ->
            expect($locationProvider.html5Mode).toHaveBeenCalledWith({ enabled: true })

        it 'should set the $urlRouterProvider otherwise to the defauth route', ->
            expect($urlRouterProvider.otherwise).toHaveBeenCalledWith('/home/groups/' + Constants.OWNED_GROUP)

        it 'should push a new interceptor to the $httpProvider.interceptors', ->
            expect($httpProvider.interceptors.push).toHaveBeenCalledWith(jasmine.any(Function))
            expect($httpProvider.interceptors.length).toEqual(1)

    describe 'responseError', ->

        responseErrorFunction = undefined

        beforeEach ->
            responseErrorFunction = $httpProvider.interceptors[0]().responseError
            spyOn(window, 'alert').and.callFake ->

        describe '401 error', ->

            beforeEach ->
                responseErrorFunction({ status: 401 })

            it 'should alert the NOT_AUTHORIZED message', ->
                expect(window.alert).toHaveBeenCalledWith(Constants.Messages.NOT_AUTHORIZED)

        describe '500 error', ->

            beforeEach ->
                responseErrorFunction({ status: 500 })

            it 'should alert anything', ->
                expect(window.alert).not.toHaveBeenCalled()

    describe 'login', ->

        loginParams = undefined

        beforeEach ->
            loginParams = {
                returnStateName: 'testReturnState'
                returnStateParams: JSON.stringify({ params1: 'testParam1' })
            }
            httpBackend.when('GET', '/partials/login.html').respond()
            $state.go('login', loginParams)
            httpBackend.flush()

        it 'should set the url', ->
            expect($state.get('login').url).toEqual('/login?returnStateName&returnStateParams')

        it 'should not be authenticated', ->
            expect($state.current.authenticated).toEqual(false)

        it 'should set the view', ->
            expect($state.current.views['content@'].templateUrl).toEqual('/partials/login.html')

        it 'should set the controller', ->
            expect($state.current.views['content@'].controller).toEqual('loginController')

        it 'should resolve the title', ->
            expect($injector.invoke($state.current.resolve.$title)).toEqual('Login')

        it 'should resolve the returnStateName', ->
            expect($injector.invoke($state.current.resolve.returnStateName)).toEqual(loginParams.returnStateName)

        it 'should resolve the returnStateParams', ->
            expect($injector.invoke($state.current.resolve.returnStateParams)).toEqual(loginParams.returnStateParams)

    describe 'register', ->

        beforeEach ->
            httpBackend.when('GET', '/partials/register.html').respond()
            $state.go('register')
            httpBackend.flush()

        it 'should set the url', ->
            expect($state.get('register').url).toEqual('/register')

        it 'should not be authenticated', ->
            expect($state.current.authenticated).toEqual(false)

        it 'should set the view', ->
            expect($state.current.views['content@'].templateUrl).toEqual('/partials/register.html')

        it 'should set the controller', ->
            expect($state.current.views['content@'].controller).toEqual('registerController')

        it 'should resolve the title', ->
            expect($injector.invoke($state.current.resolve.$title)).toEqual('Register')

    describe 'home', ->

        it 'should set the url', ->
            expect($state.get('home').url).toEqual('/home')

        it 'should be abstract', ->
            expect($state.get('home').abstract).toEqual(true)

        it 'should be set to replace', ->
            expect($state.get('home').replace).toEqual(true)

        it 'should resolve the User', (done) ->
            AuthService = {
                getUser: -> resolvedPromiseFunc({ username: 'Justin' })
            }
            $state.get('home').views['navBar@'].resolve.User(AuthService).then (user) ->
                expect(user).toEqual({ username: 'Justin' })
                done()
            $rootScope.$digest()

        it 'should set the view', ->
            expect($state.get('home').views['content@'].template).toContain('ui-view')

        it 'should set the navBar to replace', ->
            expect($state.get('home').views['navBar@'].replace).toEqual(true)

        it 'should set the navBar view', ->
            expect($state.get('home').views['navBar@'].templateUrl).toEqual('/partials/navBar.html')

        it 'should set the navBar controller', ->
            expect($state.get('home').views['navBar@'].controller).toEqual('navBarController')

    describe 'home.settings', ->

        it 'should set the url', ->
            expect($state.get('home.settings').url).toEqual('/settings')

        it 'should be abstract', ->
            expect($state.get('home.settings').abstract).toEqual(true)

        it 'should be set to replace', ->
            expect($state.get('home.settings').replace).toEqual(true)

        it 'should resolve the title', ->
            expect($state.get('home.settings').resolve.$title()).toEqual('Account Settings')

        it 'should resolve the User', (done) ->
            AuthService = {
                getUser: -> resolvedPromiseFunc({ username: 'Justin' })
            }
            $state.get('home.settings').resolve.User(AuthService).then (user) ->
                expect(user).toEqual({ username: 'Justin' })
                done()
            $rootScope.$digest()

        it 'should set the view', ->
            expect($state.get('home.settings').templateUrl).toEqual('/partials/settings.html')

        it 'should set the controller', ->
            expect($state.get('home.settings').controller).toEqual('settingsController')

    describe 'home.settings.general', ->

        it 'should set the url', ->
            expect($state.get('home.settings.general').url).toEqual('/general')

        it 'should be authenticated', ->
            expect($state.get('home.settings.general').authenticated).toEqual(true)

        it 'should set the view', ->
            expect($state.get('home.settings.general').templateUrl).toEqual('/partials/settings-general.html')

    describe 'home.settings.security', ->

        it 'should set the url', ->
            expect($state.get('home.settings.security').url).toEqual('/security')

        it 'should be authenticated', ->
            expect($state.get('home.settings.security').authenticated).toEqual(true)

        it 'should set the view', ->
            expect($state.get('home.settings.security').templateUrl).toEqual('/partials/settings-security.html')

    describe 'home.groups', ->

        it 'should set the url', ->
            expect($state.get('home.groups').url).toEqual('/groups/:groupType')

        it 'should set the params', ->
            expect($state.get('home.groups').params).toEqual(groupType: Constants.OWNED_GROUP)

        it 'should resolve the title', ->
            expect($state.get('home.groups').resolve.$title()).toEqual('Groups')

        it 'should be authenticated', ->
            expect($state.get('home.groups').authenticated).toEqual(true)

        it 'should set the view', ->
            expect($state.get('home.groups').templateUrl).toEqual('/partials/groups.html')

        it 'should set the controller', ->
            expect($state.get('home.groups').controller).toEqual('groupsController')

    describe 'workspace', ->

        it 'should set the url', ->
            expect($state.get('workspace').url).toEqual('/workspace/:groupId')

        it 'should set the params', ->
            expect($state.get('workspace').params).toEqual(groupId: 'groupId')

        it 'should resolve the User', (done) ->
            AuthService = {
                getUser: -> resolvedPromiseFunc({ username: 'Justin' })
            }
            $state.get('workspace').resolve.User(AuthService).then (user) ->
                expect(user).toEqual({ username: 'Justin' })
                done()
            $rootScope.$digest()

        it 'should resolve the socket', ->
            Socket = ->
                @emit = ->
                @test = -> 'testing property'
                return
            expect($state.get('workspace').resolve.socket(Socket).test()).toEqual('testing property')

        it 'should resolve the title', ->
            expect($state.get('workspace').resolve.$title()).toEqual('Workspace')

        it 'should be authenticated', ->
            expect($state.get('workspace').authenticated).toEqual(true)

        it 'should set the view', ->
            expect($state.get('workspace').views['content@'].templateUrl).toEqual('/partials/workspace.html')

        it 'should set the controller', ->
            expect($state.get('workspace').views['content@'].controller).toEqual('workspaceController')

describe 'Routes Authentication', ->

    resolvedPromiseFunc = undefined
    rejectedPromiseFunc = undefined
    $rootScope = undefined
    httpBackend = undefined
    AuthService = undefined
    $q = undefined
    $state = undefined

    beforeEach ->
        resolvedPromiseFunc = (value) ->
            deferred = $q.defer()
            deferred.resolve(value)
            deferred.promise

        rejectedPromiseFunc = (value) ->
            deferred = $q.defer()
            deferred.reject(value)
            deferred.promise

        module 'runwayAppRoutes', ($provide) ->
            $provide.service 'AuthService', -> {
                getUser: -> resolvedPromiseFunc()
            }
            return

    beforeEach inject (_AuthService_, _$rootScope_, _$q_, _$state_, _$httpBackend_) ->
        AuthService = _AuthService_
        $rootScope = _$rootScope_
        $q = _$q_
        $state = _$state_
        httpBackend = _$httpBackend_

    it 'should do nothing when the state is not authenicated', ->
        spyOn(AuthService, 'getUser').and.callThrough()
        nextState = {
            authenticated: false
        }
        $rootScope.$broadcast('$stateChangeStart', nextState)
        expect(AuthService.getUser).not.toHaveBeenCalled()

    it 'should call AuthService.getUser when the state is authenicated', ->
        angular.extend AuthService, {
            getUser: -> rejectedPromiseFunc()
        }
        spyOn(AuthService, 'getUser').and.callThrough()
        nextState = {
            authenticated: true
        }
        $rootScope.$broadcast('$stateChangeStart', nextState)
        expect(AuthService.getUser).toHaveBeenCalled()

    describe 'authenticated', ->

        it 'should not go to the login state', ->
            spyOn($state, 'go').and.callThrough()
            nextState = {
                authenticated: true
            }
            $rootScope.$broadcast('$stateChangeStart', nextState)
            expect($state.go).not.toHaveBeenCalled()

    describe 'authenticated', ->

        it 'should go to the login state', ->
            angular.extend AuthService, {
                getUser: -> rejectedPromiseFunc()
            }
            spyOn($state, 'go').and.callThrough()
            nextState = {
                name: 'test state name'
                authenticated: true
            }
            nextParams = {
                returnStateName: 'testReturnState'
                returnStateParams: JSON.stringify({ params1: 'testParam1' })
            }
            httpBackend.when('GET', '/partials/login.html').respond()
            httpBackend.when('GET', '/partials/navBar.html').respond()
            $rootScope.$broadcast('$stateChangeStart', nextState, nextParams)
            $rootScope.$digest()
            expect($state.go).toHaveBeenCalledWith('login', {
                returnStateName: 'test state name'
                returnStateParams: JSON.stringify(nextParams)
            })
