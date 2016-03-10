describe 'controllers', ->

    beforeEach(module('runwayAppControllers'))

    Constants = AuthService = $controller = $q = $state = $rootScope = scope = undefined

    beforeEach inject (_$q_, _Constants_, _$controller_, _$rootScope_) ->
        $q = _$q_
        Constants = _Constants_
        $controller = _$controller_
        $rootScope = _$rootScope_
        scope = {}
        AuthService = {
            getUser: ->
                { username: 'Justin' }
            loggedIn: ->
                deferred = $q.defer()
                deferred.resolve()
                deferred.promise
        }
        $state = {
            go: ->
        }

    describe 'loginController', ->

        it 'should define the login function', ->
            $controller('loginController', {
                $scope: scope
                returnStateName: undefined
                returnStateParams: undefined
            })
            expect(scope.login).toBeDefined()

        describe 'call scope.login', ->

            beforeEach ->
                angular.extend AuthService, {
                    login: ->
                        deferred = $q.defer()
                        deferred.resolve()
                        deferred.promise
                }
                $controller('loginController', {
                    $scope: scope
                    returnStateName: undefined
                    returnStateParams: undefined
                    AuthService: AuthService
                    $state: $state
                })
                scope.loginForm = { username: 'Justin', password: 'superSecretPassword' }

            it 'should set disable the login controls', (done) ->
                scope.login().then ->
                    expect(scope.disableLogin).toEqual(true)
                    done()
                $rootScope.$digest()

            it 'should clean all errors', (done) ->
                scope.login().then ->
                    expect(scope.error).toEqual(false)
                    done()
                $rootScope.$digest()

            it 'should call AuthService.login', (done) ->
                spyOn(AuthService, 'login').and.callThrough()
                scope.login().then ->
                    expect(AuthService.login).toHaveBeenCalled()
                    done()
                $rootScope.$digest()


        describe 'successful login with params', ->

            beforeEach ->
                angular.extend AuthService, {
                    login: ->
                        deferred = $q.defer()
                        deferred.resolve()
                        deferred.promise
                }
                $controller('loginController', {
                    $scope: scope
                    returnStateName: 'home.settings.general'
                    returnStateParams: JSON.stringify({param: 'testParam'})
                    AuthService: AuthService
                    $state: $state
                })
                scope.loginForm = { username: 'Justin', password: 'superSecretPassword' }

            it 'should clear the login form', (done) ->
                scope.login().then ->
                    expect(scope.loginForm).toEqual({})
                    done()
                $rootScope.$digest()

            it 'should go to the given return state when a return state is given', (done) ->
                spyOn($state, 'go')
                scope.login().then ->
                    expect($state.go).toHaveBeenCalledWith('home.settings.general', {param: 'testParam'})
                    done()
                $rootScope.$digest()


        describe 'successful login with no params', ->

            beforeEach ->
                angular.extend AuthService, {
                    login: ->
                        deferred = $q.defer()
                        deferred.resolve()
                        deferred.promise
                }
                $controller('loginController', {
                    $scope: scope
                    returnStateName: undefined
                    returnStateParams: undefined
                    AuthService: AuthService
                    $state: $state
                })
                scope.loginForm = { username: 'Justin', password: 'superSecretPassword' }

            it 'should clear the login form', (done) ->
                scope.login().then ->
                    expect(scope.loginForm).toEqual({})
                    done()
                $rootScope.$digest()

            it 'should go to the given return state when a return state is given', (done) ->
                spyOn($state, 'go')
                scope.login().then ->
                    expect($state.go).toHaveBeenCalledWith(Constants.DEFAULT_ROUTE)
                    done()
                $rootScope.$digest()


        describe 'failed login', ->

            beforeEach ->
                angular.extend AuthService, {
                    login: ->
                        deferred = $q.defer()
                        deferred.reject('test error message')
                        deferred.promise
                }
                $controller('loginController', {
                    $scope: scope
                    returnStateName: undefined
                    returnStateParams: undefined
                    AuthService: AuthService
                    $state: $state
                })
                scope.loginForm = { username: 'Justin', password: 'superSecretPassword' }

            it 'should clear the login form', (done) ->
                scope.login().catch ->
                    expect(scope.loginForm).toEqual({})
                    done()
                $rootScope.$digest()

            it 'should re-enable the login form', (done) ->
                scope.login().catch ->
                    expect(scope.disableLogin).toEqual(false)
                    done()
                $rootScope.$digest()

            it 'should set the scope.error to the error message passed back by the AuthService', (done) ->
                scope.login().catch ->
                    expect(scope.error).toEqual('test error message')
                    done()
                $rootScope.$digest()


    describe 'navBarController', ->

        it 'should set scope.username to the username of the user obtained from AuthService.getUser().username', ->
            spyOn(AuthService, 'getUser').and.callThrough()
            $controller('navBarController', {
                $scope: scope
                AuthService: AuthService
            })
            expect(scope.username).toEqual('Justin')
            expect(AuthService.getUser).toHaveBeenCalled()


        describe 'call scope.logout, logout successful', ->

            beforeEach ->
                angular.extend AuthService,  {
                    logout: ->
                        deferred = $q.defer()
                        deferred.resolve()
                        deferred.promise
                }
                spyOn(AuthService, 'logout').and.callThrough()
                $controller('navBarController', {
                    $scope: scope
                    AuthService: AuthService
                    $state: $state
                })

            it 'should call AuthService.logout', (done) ->
                scope.logout().then ->
                    expect(AuthService.logout).toHaveBeenCalled()
                    done()
                $rootScope.$digest()

            it 'should go to the login state', (done) ->
                spyOn($state, 'go')
                scope.logout().then ->
                    expect($state.go).toHaveBeenCalledWith('login')
                    done()
                $rootScope.$digest()


        describe 'call scope.logout, logout failed', ->

            beforeEach ->
                angular.extend AuthService, {
                    logout: ->
                        deferred = $q.defer()
                        deferred.reject()
                        deferred.promise
                }
                spyOn(AuthService, 'logout').and.callThrough()
                $controller('navBarController', {
                    $scope: scope
                    AuthService: AuthService
                    $state: $state
                })

            it 'should go to the login state', (done) ->
                spyOn($state, 'go')
                scope.logout().catch ->
                    expect($state.go).toHaveBeenCalledWith('login')
                    done()
                $rootScope.$digest()


    describe 'settingsController', ->

        it 'should set scope.user to the user obtained from AuthService.getUser()', ->
            spyOn(AuthService, 'getUser').and.callThrough()
            $controller('settingsController', {
                $scope: scope
                AuthService: AuthService
            })
            expect(scope.user).toEqual({username: 'Justin'})
            expect(AuthService.getUser).toHaveBeenCalled()
