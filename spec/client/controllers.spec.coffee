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

            it 'should call AuthService.login with login credentials', (done) ->
                spyOn(AuthService, 'login').and.callThrough()
                scope.login().then ->
                    expect(AuthService.login).toHaveBeenCalledWith('Justin', 'superSecretPassword')
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

        it 'should initialize scope.username to the username of the user obtained from AuthService.getUser().username', ->
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

        it 'should initialize scope.user to the user obtained from AuthService.getUser()', ->
            spyOn(AuthService, 'getUser').and.callThrough()
            $controller('settingsController', {
                $scope: scope
                AuthService: AuthService
            })
            expect(scope.user).toEqual({username: 'Justin'})
            expect(AuthService.getUser).toHaveBeenCalled()


    describe 'registerController', ->

        it 'should define the register function', ->
            $controller('registerController', {
                $scope: scope
            })
            expect(scope.register).toBeDefined()

        describe 'call scope.register', ->

            beforeEach ->
                angular.extend AuthService, {
                    register: ->
                        deferred = $q.defer()
                        deferred.resolve()
                        deferred.promise
                }
                $controller('registerController', {
                    $scope: scope
                    AuthService: AuthService
                    $state: $state
                })
                scope.registerForm = { username: 'Justin', password: 'superSecretPassword' }

            it 'should set disable the register controls', (done) ->
                scope.register().then ->
                    expect(scope.disableRegister).toEqual(true)
                    done()
                $rootScope.$digest()

            it 'should clean all errors', (done) ->
                scope.register().then ->
                    expect(scope.error).toEqual(false)
                    done()
                $rootScope.$digest()

            it 'should call AuthService.register with register form information', (done) ->
                spyOn(AuthService, 'register').and.callThrough()
                scope.register().then ->
                    expect(AuthService.register).toHaveBeenCalledWith({ username: 'Justin', password: 'superSecretPassword' })
                    done()
                $rootScope.$digest()


        describe 'successful register', ->

            beforeEach ->
                angular.extend AuthService, {
                    register: ->
                        deferred = $q.defer()
                        deferred.resolve()
                        deferred.promise
                }
                $controller('registerController', {
                    $scope: scope
                    AuthService: AuthService
                    $state: $state
                })
                scope.registerForm = { username: 'Justin', password: 'superSecretPassword' }

            it 'should clear the register form', (done) ->
                scope.register().then ->
                    expect(scope.registerForm).toEqual({})
                    done()
                $rootScope.$digest()

            it 'should go to the login state', (done) ->
                spyOn($state, 'go')
                scope.register().then ->
                    expect($state.go).toHaveBeenCalledWith('login')
                    done()
                $rootScope.$digest()


        describe 'failed register', ->

            beforeEach ->
                angular.extend AuthService, {
                    register: ->
                        deferred = $q.defer()
                        deferred.reject('test error message')
                        deferred.promise
                }
                $controller('registerController', {
                    $scope: scope
                    AuthService: AuthService
                    $state: $state
                })
                scope.registerForm = { username: 'Justin', password: 'superSecretPassword' }

            it 'should clear the register form', (done) ->
                scope.register().catch ->
                    expect(scope.registerForm).toEqual({})
                    done()
                $rootScope.$digest()

            it 'should re-enable the register form', (done) ->
                scope.register().catch ->
                    expect(scope.disableRegister).toEqual(false)
                    done()
                $rootScope.$digest()

            it 'should set the scope.error to the error message passed back by the AuthService', (done) ->
                scope.register().catch ->
                    expect(scope.error).toEqual('test error message')
                    done()
                $rootScope.$digest()


    describe 'groupsController', ->

        groupService = undefined

        beforeEach ->
            groupService = {}

        it 'should initialize the scope.groups to an empty array', ->
            $controller('groupsController', {
                $scope: scope
            })
            expect(scope.groups).toEqual([])

        it 'should initialize the scope.groupType to stateParams.groupType', ->
            $controller('groupsController', {
                $scope: scope
                $stateParams: {
                    groupType: 'testGroupType'
                }
            })
            expect(scope.groupType).toEqual('testGroupType')

        it 'should define the scope.openEditGroupPropertiesModal function', ->
            $controller('groupsController', {
                $scope: scope
            })
            expect(scope.openEditGroupPropertiesModal).toBeDefined()

        it 'should define the scope.openEditGroupMembersModal function', ->
            $controller('groupsController', {
                $scope: scope
            })
            expect(scope.openEditGroupMembersModal).toBeDefined()

        it 'should define the scope.openAddGroupModal function', ->
            $controller('groupsController', {
                $scope: scope
            })
            expect(scope.openAddGroupModal).toBeDefined()


        it 'should initialize the scope.groupType to stateParams.groupType', ->
            $controller('groupsController', {
                $scope: scope
                $stateParams: {
                    groupType: 'testGroupType'
                }
            })
            expect(scope.groupType).toEqual('testGroupType')



        describe 'call groupService.getGroups, successfully get groups', ->

            beforeEach ->
                angular.extend groupService, {
                    getGroups: ->
                        deferred = $q.defer()
                        deferred.resolve(['a', 'b', 'c'])
                        deferred.promise
                }
                spyOn(groupService, 'getGroups').and.callThrough()
                $controller('groupsController', {
                    $scope: scope
                    $stateParams: {
                        groupType: 'testGroupType'
                    }
                    groupService: groupService
                })

            it 'should call groupService.getGroups with stateParams.groupType', ->
                expect(groupService.getGroups).toHaveBeenCalledWith('testGroupType')

            it 'should set scope.groups to the returned result of groupService.getGroups on success', ->
                $rootScope.$digest()
                expect(scope.groups).toEqual(['a', 'b', 'c'])


        describe 'call groupService.getGroups, fail getting groups', ->

            beforeEach ->
                angular.extend groupService, {
                    getGroups: ->
                        deferred = $q.defer()
                        deferred.reject('test error message')
                        deferred.promise
                }
                spyOn(groupService, 'getGroups').and.callThrough()
                $controller('groupsController', {
                    $scope: scope
                    $stateParams: {
                        groupType: 'testGroupType'
                    }
                    groupService: groupService
                })

            it 'should call groupService.getGroups with stateParams.groupType', ->
                expect(groupService.getGroups).toHaveBeenCalledWith('testGroupType')

            it 'should set scope.error to the returned error of groupService.getGroups on error', ->
                $rootScope.$digest()
                expect(scope.error).toEqual('test error message')


        describe 'call', ->

            modalInstance = uibModal = groupToEdit = event = undefined

            beforeEach ->
                angular.extend groupService, {
                    getGroups: ->
                        deferred = $q.defer()
                        deferred.resolve()
                        deferred.promise
                }
                event = {
                    stopPropagation: ->
                }
                groupToEdit = {_id: 5}

                modalInstance = {
                    result: then: (confirmCallback) -> @confirmCallBack = confirmCallback
                    close: (params...) -> @result.confirmCallBack(params...)
                }
                uibModal = {
                    open: (options) -> modalInstance
                }

                $controller('groupsController', {
                    $scope: scope
                    $stateParams: {
                        groupType: 'testGroupType'
                    }
                    groupService: groupService
                    $uibModal: uibModal
                })


            describe 'call scope.openEditGroupPropertiesModal', ->

                it 'should call event.stopPropagation on the event passed in', ->
                    spyOn(event, 'stopPropagation').and.callThrough()
                    scope.openEditGroupPropertiesModal(event, groupToEdit)
                    expect(event.stopPropagation).toHaveBeenCalled()

                it 'should open a modal with the correct options', ->
                    spyOn(uibModal, 'open').and.callThrough()
                    scope.openEditGroupPropertiesModal(event, groupToEdit)
                    expect(uibModal.open).toHaveBeenCalledWith({
                        animation: true
                        resolve:
                            editingGroup: groupToEdit
                        templateUrl: '/partials/editGroupPropertiesModal.html'
                        controller: 'editGroupPropertiesModalController'
                    })


                describe 'close modal successfully with editedGroup and deleteGroup = true', ->

                    it 'should clear all errors', ->
                        scope.openEditGroupPropertiesModal(event, groupToEdit)
                        scope.groups = [{_id: 5}, {_id: 36}, {_id: 6}]
                        modalInstance.close({_id: 5}, true)
                        expect(scope.error).toEqual(null)

                    it 'should remove the groups from the groups list', ->
                        scope.openEditGroupPropertiesModal(event, groupToEdit)
                        scope.groups = [{_id: 5}, {_id: 36}, {_id: 6}]
                        modalInstance.close({_id: 5}, true)
                        expect(scope.groups).toEqual([{_id: 36}, {_id: 6}])


                describe 'close modal successfully with editedGroup and deleteGroup = false', ->

                    it 'should clear all errors', ->
                        scope.openEditGroupPropertiesModal(event, groupToEdit)
                        scope.groups = [{_id: 5}, {_id: 36}, {_id: 6}]
                        modalInstance.close({_id: 5}, false)
                        expect(scope.error).toEqual(null)

                    it 'should replace the groups being edited in the groups list', ->
                        scope.openEditGroupPropertiesModal(event, groupToEdit)
                        scope.groups = [{_id: 5}, {_id: 36}, {_id: 6}]
                        modalInstance.close({_id: 5, name: 'test'}, false)
                        expect(scope.groups).toEqual([{_id: 5, name: 'test'}, {_id: 36}, {_id: 6}])


            describe 'call groupService.getGroups, fail getting groups', ->

                beforeEach ->
                    angular.extend groupService, {
                        getGroups: ->
                            deferred = $q.defer()
                            deferred.reject('test error message')
                            deferred.promise
                    }
                    spyOn(groupService, 'getGroups').and.callThrough()
                    $controller('groupsController', {
                        $scope: scope
                        $stateParams: {
                            groupType: 'testGroupType'
                        }
                        groupService: groupService
                    })

                it 'should call groupService.getGroups with stateParams.groupType', ->
                    expect(groupService.getGroups).toHaveBeenCalledWith('testGroupType')

                it 'should set scope.error to the returned error of groupService.getGroups on error', ->
                    $rootScope.$digest()
                    expect(scope.error).toEqual('test error message')


            describe 'call scope.openEditGroupMembersModal', ->

                it 'should call event.stopPropagation on the event passed in', ->
                    spyOn(event, 'stopPropagation').and.callThrough()
                    scope.openEditGroupMembersModal(event, groupToEdit)
                    expect(event.stopPropagation).toHaveBeenCalled()

                it 'should open a modal with the correct options', ->
                    spyOn(uibModal, 'open').and.callThrough()
                    scope.openEditGroupMembersModal(event, groupToEdit)
                    expect(uibModal.open).toHaveBeenCalledWith({
                        animation: true
                        size: 'lg'
                        resolve:
                            editingGroup: groupToEdit
                        templateUrl: '/partials/editGroupMembersModal.html'
                        controller: 'editGroupMembersModalController'
                    })


                describe 'close modal successfully with editedGroup', ->

                    it 'should replace the groups being edited in the groups list', ->
                        scope.openEditGroupMembersModal(event, groupToEdit)
                        scope.groups = [{_id: 5}, {_id: 36}, {_id: 6}]
                        modalInstance.close({_id: 5, name: 'test'}, false)
                        expect(scope.groups).toEqual([{_id: 5, name: 'test'}, {_id: 36}, {_id: 6}])


            describe 'scope.openAddGroupModal', ->

                it 'should open a modal with the correct options', ->
                    spyOn(uibModal, 'open').and.callThrough()
                    scope.openAddGroupModal()
                    expect(uibModal.open).toHaveBeenCalledWith({
                        animation: true
                        templateUrl: '/partials/addGroupModal.html'
                        controller: 'addGroupModalController'
                    })


                describe 'close modal successfully with groupToAdd', ->

                    it 'should add the groupToAdd to the groups list', ->
                        scope.openAddGroupModal()
                        scope.groups = [{_id: 5}, {_id: 36}, {_id: 6}]
                        modalInstance.close({_id: 27})
                        expect(scope.groups).toEqual([{_id: 5}, {_id: 36}, {_id: 6}, {_id: 27}])


    describe 'addGroupModalController', ->

        describe 'setup', ->

            scope = Constants = uibModalInstance = undefined

            beforeEach inject (_Constants_) ->
                Constants = _Constants_
                $controller('addGroupModalController', {
                    $scope: scope
                    $uibModalInstance: uibModalInstance
                })

            it 'should initialize scope.newGroup"s name to an empty string', ->
                expect(scope.newGroup.name).toEqual('')

            it 'should initialize scope.newGroup"s description to an empty string', ->
                expect(scope.newGroup.description).toEqual('')

            it 'should initialize scope.newGroup"s colour to the default group colour', ->
                expect(scope.newGroup.colour).toEqual(Constants.DEFAULT_GROUP_COLOUR)


        describe 'call scope.addGroup adds successfully', ->

            scope = groupService = uibModalInstance = undefined

            beforeEach inject ($q) ->
                groupService = {
                    addGroup: ->
                        deferred = $q.defer()
                        deferred.resolve()
                        deferred.promise
                }
                scope = {}
                uibModalInstance = {
                    close: (addedGroup) ->
                }
                $controller('addGroupModalController', {
                    $scope: scope
                    $uibModalInstance: uibModalInstance
                    groupService: groupService
                })

            it 'should disable the modal input fields', ->
                scope.addGroup()
                expect(scope.disableModal).toEqual(true)

            it 'should close the modal with the addedGroup', ->
                spyOn(uibModalInstance, 'close').and.callThrough()
                scope.newGroup = {name: 'testGroup'}
                scope.addGroup().then ->
                    expect(uibModalInstance.close).toHaveBeenCalledWith({name: 'testGroup'})


        describe 'call scope.addGroup adds successfully', ->

            scope = groupService = uibModalInstance = undefined

            beforeEach inject ($q) ->
                groupService = {
                    addGroup: ->
                        deferred = $q.defer()
                        deferred.reject('test error message')
                        deferred.promise
                }
                scope = {}
                $controller('addGroupModalController', {
                    $scope: scope
                    $uibModalInstance: null
                    groupService: groupService
                })

            it 'should disable the modal input fields', ->
                scope.addGroup()
                expect(scope.disableModal).toEqual(true)

            it 'should re-enable modal input fields', ->
                scope.addGroup().catch ->
                    expect(scope.disableModal).toEqual(false)
                $rootScope.$digest()

            it 'should set the scope.error to the error passed back from the groupService.addGroup catch', ->
                scope.addGroup().catch ->
                    expect(scope.error).toEqual('test error message')
                $rootScope.$digest()

        describe 'call scope.cancel', ->

            it 'should dismiss the modal', ->
                scope = {}
                uibModalInstance = {
                    dismiss: ->
                }
                $controller('addGroupModalController', {
                    $scope: scope
                    $uibModalInstance: uibModalInstance
                })
                spyOn(uibModalInstance, 'dismiss').and.callThrough()
                scope.cancel()
                expect(uibModalInstance.dismiss).toHaveBeenCalled()
