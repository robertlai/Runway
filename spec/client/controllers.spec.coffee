describe 'loginController', ->

    beforeEach(module('runwayApp'))

    Constants = $controller = scope = $httpBackend = undefined

    setupControllerWithReturnInfo = (returnStateName, returnStateParams) ->
        $controller('loginController', {
            $scope: scope
            returnStateName: returnStateName
            returnStateParams: JSON.stringify(returnStateParams)
        })


    beforeEach inject (_$controller_, _$httpBackend_, $templateCache, _Constants_) ->
        Constants = _Constants_
        $controller = _$controller_
        $httpBackend = _$httpBackend_
        scope = {}
        $httpBackend.when('POST', '/getUserStatus').respond({})
        $templateCache.put('/partials/navBar.html', '')
        $templateCache.put('/partials/login.html', '')
        $templateCache.put('/partials/groups.html', '')
        $templateCache.put('/partials/settings.html', '')
        $templateCache.put('/partials/settings-general.html', '')

    it 'should define the login function', ->
        setupControllerWithReturnInfo()
        expect(scope.login).toBeDefined()

    describe 'call scope.login', ->

        loginPromise = AuthService = undefined

        beforeEach inject (_AuthService_, _$state_) ->
            setupControllerWithReturnInfo()
            AuthService = _AuthService_
            scope.loginForm = { username: 'Justin', password: 'superSecretPassword' }
            loginPromise = scope.login()

        it 'should set disable the login controls', ->
            expect(scope.disableLogin).toEqual(true)

        it 'should clean all errors', ->
            expect(scope.error).toEqual(false)

        it 'should call AuthService.login', (done) ->
            $httpBackend.expect('POST', '/login').respond(200, {status: 'testSTatus'})

            spyOn(AuthService, 'login')

            loginPromise.then (data) -> done()

            $httpBackend.flush()
            expect(AuthService.login).toHaveBeenCalled()


    describe 'successful login with params', ->

        loginPromise = $state = undefined

        beforeEach inject (_$state_) ->
            setupControllerWithReturnInfo('home.settings.general', {param: 'testParam'})
            $state = _$state_
            scope.loginForm = { username: 'Justin', password: 'superSecretPassword' }
            loginPromise = scope.login()
            $httpBackend.expect('POST', '/login').respond(200, {status: 'testStatus'})

        it 'should clear the login form', ->
            $httpBackend.flush()
            expect(scope.loginForm).toEqual({})

        it 'should go to the given return state when a return state is given', (done) ->
            spyOn($state, 'go')
            loginPromise.then (data) ->
                expect($state.go).toHaveBeenCalledWith('home.settings.general', {param: 'testParam'})
                done()
            $httpBackend.flush()


    describe 'successful login with no params', ->

        loginPromise = $state = undefined

        beforeEach inject (_$state_) ->
            setupControllerWithReturnInfo()
            $state = _$state_
            scope.loginForm = { username: 'Justin', password: 'superSecretPassword' }
            loginPromise = scope.login()
            $httpBackend.expect('POST', '/login').respond(200, {status: 'testStatus'})

        it 'should clear the login form', ->
            $httpBackend.flush()
            expect(scope.loginForm).toEqual({})

        it 'should go to the given return state when a return state is given', (done) ->
            spyOn($state, 'go')
            loginPromise.then (data) ->
                expect($state.go).toHaveBeenCalledWith(Constants.DEFAULT_ROUTE)
                done()
            $httpBackend.flush()


    describe 'failed login', ->

        loginPromise = $state = undefined

        beforeEach inject (_$state_) ->
            setupControllerWithReturnInfo('home.settings.general', {param: 'testParam'})
            $state = _$state_
            scope.loginForm = { username: 'Justin', password: 'superSecretPassword' }
            loginPromise = scope.login()
            $httpBackend.expect('POST', '/login').respond(500, {error: 'test error message'})

        it 'should clear the login form', ->
            $httpBackend.flush()
            expect(scope.loginForm).toEqual({})

        it 'should re-enable the login form', ->
            $httpBackend.flush()
            expect(scope.disableLogin).toEqual(false)

        it 'should ', ->
            $httpBackend.flush()
            expect(scope.error).toEqual('test error message')
