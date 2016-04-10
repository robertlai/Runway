describe 'controllers', ->

    beforeEach(module('runwayAppControllers'))

    Constants = undefined
    AuthService = undefined
    GroupService = undefined
    UserService = undefined
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


    beforeEach inject ($q, _Constants_, _$controller_, _$rootScope_, _$window_) ->
        Constants = _Constants_
        $controller = _$controller_
        $rootScope = _$rootScope_
        $window = _$window_
        $window.confirm = -> true
        scope = {}

        mockCredentials = { username: 'Justin', password: 'superSecretPassword' }

        resolvedPromiseFunc = (value) ->
            deferred = $q.defer()
            deferred.resolve(value)
            deferred.promise

        rejectedPromiseFunc = (value) ->
            deferred = $q.defer()
            deferred.reject(value)
            deferred.promise

        AuthService = {
            getUser: -> { _id: 'justinId', username: 'Justin' }
            login: -> resolvedPromiseFunc()
            logout: -> resolvedPromiseFunc()
            register: -> resolvedPromiseFunc()
        }

        GroupService = {
            getGroups: -> resolvedPromiseFunc(['a', 'b', 'c'])
            addGroup: -> resolvedPromiseFunc()
            editGroup: (editingGroup) -> resolvedPromiseFunc(editingGroup)
            deleteGroup: -> resolvedPromiseFunc()
            addMember: -> resolvedPromiseFunc({ _id: 'newMemberId', name: 'test return member' })
            removeMember: -> resolvedPromiseFunc()
        }

        UserService = {
            findUsers: (query) -> resolvedPromiseFunc(query)
            saveUserSettings: -> resolvedPromiseFunc()
        }

        uibModalInstance = {
            result: then: (confirmCallback) -> @confirmCallBack = confirmCallback
            close: (params...) -> @result.confirmCallBack(params...)
            dismiss: ->
        }

        uibModal = {
            open: (options) -> uibModalInstance
        }

        $state = {
            go: ->
        }

    describe 'loginController', ->

        loginControllerParams = undefined

        beforeEach ->
            loginControllerParams = {
                $scope: scope
                returnStateName: undefined
                returnStateParams: undefined
                AuthService: AuthService
                $state: $state
            }

        it 'should define the login function', ->
            $controller('loginController', loginControllerParams)
            expect(scope.login).toBeDefined()

        describe 'scope.login', ->

            beforeEach ->
                $controller('loginController', loginControllerParams)
                scope.loginForm = mockCredentials

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
                    expect(AuthService.login).toHaveBeenCalledWith(mockCredentials.username, mockCredentials.password)
                    done()
                $rootScope.$digest()


        describe 'successful login with params', ->

            beforeEach ->
                angular.extend loginControllerParams, {
                    returnStateName: 'home.settings.general'
                    returnStateParams: JSON.stringify({ param: 'testParam' })
                }
                $controller('loginController', loginControllerParams)
                scope.loginForm = mockCredentials

            it 'should clear the login form', (done) ->
                scope.login().then ->
                    expect(scope.loginForm).toEqual({})
                    done()
                $rootScope.$digest()

            it 'should go to the given return state when a return state is given', (done) ->
                spyOn($state, 'go')
                scope.login().then ->
                    expect($state.go).toHaveBeenCalledWith('home.settings.general', { param: 'testParam' })
                    done()
                $rootScope.$digest()


        describe 'successful login with no params', ->

            beforeEach ->
                $controller('loginController', loginControllerParams)
                scope.loginForm = mockCredentials

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
                    login: -> rejectedPromiseFunc('test error message')
                }
                $controller('loginController', loginControllerParams)
                scope.loginForm = mockCredentials

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

        navBarControllerParams = undefined
        User = undefined

        beforeEach ->
            User = { username: 'Justin' }
            navBarControllerParams = {
                $scope: scope
                AuthService: AuthService
                $state: $state
                User: User
            }

        it 'should initialize scope.username to the username of the user obtained from AuthService.getUser().username', ->
            $controller('navBarController', navBarControllerParams)
            expect(scope.username).toEqual(User.username)


        describe 'scope.logout, logout successful', ->

            beforeEach ->
                spyOn(AuthService, 'logout').and.callThrough()
                $controller('navBarController', navBarControllerParams)

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


        describe 'scope.logout, logout failed', ->

            beforeEach ->
                angular.extend AuthService, {
                    logout: -> rejectedPromiseFunc('test error message')
                }
                spyOn(AuthService, 'logout').and.callThrough()
                $controller('navBarController', navBarControllerParams)

            it 'should go to the login state', (done) ->
                spyOn($state, 'go')
                scope.logout().catch ->
                    expect($state.go).toHaveBeenCalledWith('login')
                    done()
                $rootScope.$digest()


    describe 'settingsController', ->

        settingsControllerParams = undefined
        User = undefined
        UserService = undefined


        describe 'setup', ->

            beforeEach ->
                User = {
                    _id: 'justinId'
                    username: 'Justin'
                    firstName: 'Justin'
                    lastName: 'Stribling'
                    email: 'justin@email.com'
                    searchability: 'friends'
                }
                settingsControllerParams = {
                    $scope: scope
                    User: User
                }
                $controller('settingsController', settingsControllerParams)

            it 'should initialize scope.generalSettings from the user obtained from the resolved User', ->
                expect(scope.generalSettings).toEqual {
                    _id: 'justinId'
                    username: 'Justin'
                    firstName: 'Justin'
                    lastName: 'Stribling'
                    email: 'justin@email.com'
                }

            it 'should initialize scope.securitySettings from the user obtained from the resolved User', ->
                expect(scope.securitySettings).toEqual {
                    _id: 'justinId'
                    searchability: 'friends'
                }

            it 'should define scope.saveUserSettings', ->
                expect(scope.saveUserSettings).toEqual(jasmine.any(Function))


        describe 'scope.saveUserSettings', ->

            settingsToSave = undefined

            beforeEach ->
                settingsToSave = {
                    key: 'value'
                }
                User = {
                    _id: 'justinId'
                    username: 'Justin'
                    firstName: 'Justin'
                    lastName: 'Stribling'
                    email: 'justin@email.com'
                    searchability: 'friends'
                }
                settingsControllerParams = {
                    $scope: scope
                    User: User
                    UserService: UserService
                }
                spyOn(UserService, 'saveUserSettings').and.callThrough()
                $controller('settingsController', settingsControllerParams)


            describe 'UserService.saveUserSettings returns successfully', ->

                it 'should resolve the promise', (done) ->
                    scope.saveUserSettings(settingsToSave).then ->
                        expect(UserService.saveUserSettings).toHaveBeenCalledWith(settingsToSave)
                        done()
                    $rootScope.$digest()


            describe 'UserService.saveUserSettings fails', ->

                beforeEach ->
                    angular.extend UserService, {
                        saveUserSettings: -> rejectedPromiseFunc('test error message')
                    }

                it 'should reject the promise and set scope.error to the returned error', (done) ->
                    scope.saveUserSettings(settingsToSave).catch (error) ->
                        expect(scope.error).toEqual('test error message')
                        done()
                    $rootScope.$digest()


    describe 'registerController', ->

        registerControllerParams = undefined

        beforeEach ->
            registerControllerParams = {
                $scope: scope
                AuthService: AuthService
                $state: $state
            }

        it 'should define the register function', ->
            $controller('registerController', registerControllerParams)
            expect(scope.register).toBeDefined()

        describe 'scope.register', ->

            beforeEach ->
                $controller('registerController', registerControllerParams)
                scope.registerForm = mockCredentials

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
                    expect(AuthService.register).toHaveBeenCalledWith(mockCredentials)
                    done()
                $rootScope.$digest()


        describe 'successful register', ->

            beforeEach ->
                $controller('registerController', registerControllerParams)
                scope.registerForm = mockCredentials

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
                    register: -> rejectedPromiseFunc('test error message')
                }
                $controller('registerController', registerControllerParams)
                scope.registerForm = mockCredentials

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

        groupsControllerParams = groupToEdit = event = undefined

        beforeEach ->
            groupToEdit = { _id: 5 }
            event = {
                stopPropagation: ->
            }
            groupsControllerParams = {
                $scope: scope
                $stateParams: {
                    groupType: 'testGroupType'
                }
                GroupService: GroupService
                $uibModal: uibModal
                AuthService: AuthService
            }

        describe 'setup', ->

            beforeEach ->
                $controller('groupsController', groupsControllerParams)

            it 'should initialize the scope.groups to an empty array', ->
                expect(scope.groups).toEqual([])

            it 'should initialize the scope.groupType to stateParams.groupType', ->
                expect(scope.groupType).toEqual('testGroupType')

            it 'should define the scope.openEditGroupPropertiesModal function', ->
                expect(scope.openEditGroupPropertiesModal).toBeDefined()

            it 'should define the scope.openEditGroupMembersModal function', ->
                expect(scope.openEditGroupMembersModal).toBeDefined()

            it 'should define the scope.openAddGroupModal function', ->
                expect(scope.openAddGroupModal).toBeDefined()

            it 'should initialize the scope.groupType to stateParams.groupType', ->
                expect(scope.groupType).toEqual('testGroupType')


        describe 'successfully get groups', ->

            beforeEach ->
                spyOn(GroupService, 'getGroups').and.callThrough()
                $controller('groupsController', groupsControllerParams)

            it 'should call GroupService.getGroups with stateParams.groupType', ->
                expect(GroupService.getGroups).toHaveBeenCalledWith('testGroupType')

            it 'should set scope.groups to the returned result of GroupService.getGroups on success', ->
                $rootScope.$digest()
                expect(scope.groups).toEqual(['a', 'b', 'c'])


        describe 'fail getting groups', ->

            beforeEach ->
                angular.extend GroupService, {
                    getGroups: -> rejectedPromiseFunc('test error message')
                }
                spyOn(GroupService, 'getGroups').and.callThrough()
                $controller('groupsController', groupsControllerParams)

            it 'should call GroupService.getGroups with stateParams.groupType', ->
                expect(GroupService.getGroups).toHaveBeenCalledWith('testGroupType')

            it 'should set scope.error to the returned error of GroupService.getGroups on error', ->
                $rootScope.$digest()
                expect(scope.error).toEqual('test error message')


        describe 'scope.openEditGroupPropertiesModal', ->

            beforeEach ->
                $controller('groupsController', groupsControllerParams)
                spyOn(event, 'stopPropagation').and.callThrough()
                spyOn(uibModal, 'open').and.callThrough()
                scope.openEditGroupPropertiesModal(event, groupToEdit)

            it 'should call event.stopPropagation on the event passed in', ->
                expect(event.stopPropagation).toHaveBeenCalled()

            it 'should open a modal with the correct options', ->
                expect(uibModal.open).toHaveBeenCalledWith({
                    animation: true
                    backdrop: 'static'
                    resolve:
                        editingGroup: groupToEdit
                        User: { _id: 'justinId', username: 'Justin' }
                    templateUrl: '/partials/editGroupPropertiesModal.html'
                    controller: 'editGroupPropertiesModalController'
                })


            describe 'close modal successfully', ->

                beforeEach ->
                    $controller('groupsController', groupsControllerParams)
                    scope.openEditGroupPropertiesModal(event, groupToEdit)
                    scope.groups = [{ _id: 36 }, { _id: 5 }, { _id: 6 }]


                describe 'with editedGroup and no deleteGroup specified', ->

                    it 'should clear all errors', ->
                        uibModalInstance.close([{ _id: 5 }])
                        expect(scope.error).toEqual(null)

                    it 'should replace the groups being edited in the groups list', ->
                        uibModalInstance.close([{ _id: 5, name: 'test' }])
                        expect(scope.groups).toEqual([{ _id: 36 }, { _id: 5, name: 'test' }, { _id: 6 }])


                describe 'with editedGroup and deleteGroup = true', ->

                    beforeEach ->
                        uibModalInstance.close([{ _id: 5 }, true])

                    it 'should clear all errors', ->
                        expect(scope.error).toEqual(null)

                    it 'should remove the groups from the groups list', ->
                        expect(scope.groups).toEqual([{ _id: 36 }, { _id: 6 }])


                describe 'with editedGroup and deleteGroup = false', ->

                    beforeEach ->
                        uibModalInstance.close([{ _id: 5, name: 'test' }, false])

                    it 'should clear all errors', ->
                        expect(scope.error).toEqual(null)

                    it 'should replace the groups being edited in the groups list', ->
                        expect(scope.groups).toEqual([{ _id: 36 }, { _id: 5, name: 'test' }, { _id: 6 }])


        describe 'fail getting groups', ->

            beforeEach ->
                angular.extend GroupService, {
                    getGroups: -> rejectedPromiseFunc('test error message')
                }
                spyOn(GroupService, 'getGroups').and.callThrough()
                $controller('groupsController', groupsControllerParams)

            it 'should call GroupService.getGroups with stateParams.groupType', ->
                expect(GroupService.getGroups).toHaveBeenCalledWith('testGroupType')

            it 'should set scope.error to the returned error of GroupService.getGroups on error', ->
                $rootScope.$digest()
                expect(scope.error).toEqual('test error message')


        describe 'scope.openEditGroupMembersModal', ->

            beforeEach ->
                $controller('groupsController', groupsControllerParams)

            it 'should call event.stopPropagation on the event passed in', ->
                spyOn(event, 'stopPropagation').and.callThrough()
                scope.openEditGroupMembersModal(event, groupToEdit)
                expect(event.stopPropagation).toHaveBeenCalled()

            it 'should open a modal with the correct options', ->
                spyOn(uibModal, 'open').and.callThrough()
                scope.openEditGroupMembersModal(event, groupToEdit)
                expect(uibModal.open).toHaveBeenCalledWith({
                    animation: true
                    backdrop: 'static'
                    size: 'lg'
                    resolve:
                        editingGroup: groupToEdit
                        User: { _id: 'justinId', username: 'Justin' }
                    templateUrl: '/partials/editGroupMembersModal.html'
                    controller: 'editGroupMembersModalController'
                })


            describe 'close modal successfully with editedGroup', ->

                it 'should replace the groups being edited in the groups list', ->
                    scope.openEditGroupMembersModal(event, groupToEdit)
                    scope.groups = [{ _id: 36 }, { _id: 5 }, { _id: 6 }]
                    uibModalInstance.close({ _id: 5, name: 'test' }, false)
                    expect(scope.groups).toEqual([{ _id: 36 }, { _id: 5, name: 'test' }, { _id: 6 }])


        describe 'scope.openAddGroupModal', ->

            beforeEach ->
                $controller('groupsController', groupsControllerParams)

            it 'should open a modal with the correct options', ->
                spyOn(uibModal, 'open').and.callThrough()
                scope.openAddGroupModal()
                expect(uibModal.open).toHaveBeenCalledWith({
                    animation: true
                    backdrop: 'static'
                    templateUrl: '/partials/addGroupModal.html'
                    controller: 'addGroupModalController'
                })


            describe 'close modal successfully with groupToAdd', ->

                it 'should add the groupToAdd to the groups list', ->
                    scope.openAddGroupModal()
                    scope.groups = [{ _id: 5 }, { _id: 36 }, { _id: 6 }]
                    uibModalInstance.close({ _id: 27 })
                    expect(scope.groups).toEqual([{ _id: 5 }, { _id: 36 }, { _id: 6 }, { _id: 27 }])


    describe 'addGroupModalController', ->

        addGroupModalControllerParams = undefined

        beforeEach ->
            angular.extend uibModalInstance, {
                close: (addedGroup) ->
            }
            addGroupModalControllerParams = {
                $scope: scope
                $uibModalInstance: uibModalInstance
                GroupService: GroupService
            }

        describe 'setup', ->

            beforeEach ->
                $controller('addGroupModalController', addGroupModalControllerParams)

            it 'should initialize scope.newGroup"s name to an empty string', ->
                expect(scope.newGroup.name).toEqual('')

            it 'should initialize scope.newGroup"s description to an empty string', ->
                expect(scope.newGroup.description).toEqual('')

            it 'should initialize scope.newGroup"s colour to the default group colour', ->
                expect(scope.newGroup.colour).toEqual(Constants.DEFAULT_GROUP_COLOUR)

            it 'should define the addGroup function', ->
                expect(scope.addGroup).toBeDefined()

            it 'should define the cancel function', ->
                expect(scope.cancel).toBeDefined()


        describe 'scope.addGroup adds successfully', ->

            beforeEach ->
                $controller('addGroupModalController', addGroupModalControllerParams)

            it 'should disable the modal input fields', ->
                scope.addGroup().then ->
                    expect(scope.disableModal).toEqual(true)
                $rootScope.$digest()

            it 'should close the modal with the addedGroup', ->
                spyOn(uibModalInstance, 'close').and.callThrough()
                scope.newGroup = { name: 'testGroup' }
                scope.addGroup().then ->
                    expect(uibModalInstance.close).toHaveBeenCalledWith({ name: 'testGroup' })


        describe "scope.addGroup doesn't add successfully", ->

            beforeEach ->
                angular.extend GroupService, {
                    addGroup: -> rejectedPromiseFunc('test error message')
                }
                $controller('addGroupModalController', addGroupModalControllerParams)

            it 'should disable the modal input fields', ->
                scope.addGroup()
                expect(scope.disableModal).toEqual(true)

            it 'should re-enable modal input fields', ->
                scope.addGroup().catch ->
                    expect(scope.disableModal).toEqual(false)
                $rootScope.$digest()

            it 'should set the scope.error to the error passed back from the GroupService.addGroup catch', ->
                scope.addGroup().catch ->
                    expect(scope.error).toEqual('test error message')
                $rootScope.$digest()

        describe 'scope.cancel', ->

            it 'should dismiss the modal', ->
                $controller('addGroupModalController', addGroupModalControllerParams)
                spyOn(uibModalInstance, 'dismiss').and.callThrough()
                scope.cancel()
                expect(uibModalInstance.dismiss).toHaveBeenCalled()


    describe 'editGroupPropertiesModalController', ->

        editingGroup = User = editGroupPropertiesModalControllerParams = undefined

        beforeEach ->
            editingGroup = { name: 'test name', _owner: 'justinId' }
            User = { _id: 'justinId' }
            angular.extend uibModalInstance, {
                close: (addedGroup) ->
            }
            editGroupPropertiesModalControllerParams = {
                $scope: scope
                $uibModalInstance: uibModalInstance
                GroupService: GroupService
                editingGroup: editingGroup
                User: User
            }

        describe 'setup owner of group', ->

            beforeEach  ->
                $controller('editGroupPropertiesModalController', editGroupPropertiesModalControllerParams)

            it 'should set scope.editingGroup to a deep copy of the resolved editingGroup parameter', ->
                expect(scope.editingGroup).toEqual(editingGroup)
                editingGroup = 'thing'
                expect(scope.editingGroup).not.toEqual(editingGroup)

            it 'should define the editGroup function', ->
                expect(scope.editGroup).toBeDefined()

            it 'should define the delete function', ->
                expect(scope.delete).toBeDefined()

            it 'should define the cancel function', ->
                expect(scope.cancel).toBeDefined()

            it 'should set scope.isOwner to true if the resolved user id matches the groups owner', ->
                expect(scope.isOwner).toEqual(true)

        describe 'setup not owner of group', ->

            beforeEach  ->
                angular.extend editGroupPropertiesModalControllerParams, {
                    User: { _id: 'notJustinId' }
                }
                $controller('editGroupPropertiesModalController', editGroupPropertiesModalControllerParams)

            it "should set scope.isOwner to false if the resolved user id doesn't match the groups owner", ->
                expect(scope.isOwner).toEqual(false)



        describe 'scope.editGroup edits successfully', ->

            it 'should close the modal with the editingGroup', ->
                $controller('editGroupPropertiesModalController', editGroupPropertiesModalControllerParams)
                spyOn(uibModalInstance, 'close').and.callThrough()
                scope.editGroup(editingGroup).then ->
                    expect(uibModalInstance.close).toHaveBeenCalledWith([editingGroup])
                $rootScope.$digest()


        describe "scope.editGroup doesn't edit successfully", ->

            beforeEach ->
                angular.extend GroupService, {
                    editGroup: -> rejectedPromiseFunc('test error message')
                }
                $controller('editGroupPropertiesModalController', editGroupPropertiesModalControllerParams)

            it 'should re-enable modal input fields', ->
                scope.editGroup().catch ->
                    expect(scope.disableModal).toEqual(false)
                $rootScope.$digest()

            it 'should set the scope.error to the error passed back from the GroupService.editGroup catch', ->
                scope.editGroup().catch ->
                    expect(scope.error).toEqual('test error message')
                $rootScope.$digest()


        describe 'scope.delete', ->

            describe 'setup', ->

                beforeEach ->
                    $controller('editGroupPropertiesModalController', editGroupPropertiesModalControllerParams)

                it 'should open a confirm dialog with the CONFIRM_GROUP_DELETE_1 message', (done) ->
                    spyOn($window, 'confirm').and.callFake -> true
                    scope.delete().then ->
                        expect($window.confirm).toHaveBeenCalledWith(Constants.Messages.CONFIRM_GROUP_DELETE_1)
                        done()
                    $rootScope.$digest()

                it 'should then open a confirm dialog with the CONFIRM_GROUP_DELETE_2 message', (done) ->
                    spyOn($window, 'confirm').and.callFake -> true
                    scope.delete().then ->
                        expect($window.confirm).toHaveBeenCalledWith(Constants.Messages.CONFIRM_GROUP_DELETE_2)
                        done()
                    $rootScope.$digest()

                it 'should no nothing if the first dialog is rejected', (done) ->
                    spyOn($window, 'confirm').and.callFake (message) -> message isnt Constants.Messages.CONFIRM_GROUP_DELETE_1
                    spyOn(GroupService, 'deleteGroup').and.callThrough()
                    scope.delete().catch ->
                        expect(GroupService.deleteGroup).not.toHaveBeenCalled()
                        done()
                    $rootScope.$digest()

                it 'should no nothing if the second dialog is rejected', (done) ->
                    spyOn($window, 'confirm').and.callFake (message) -> message isnt Constants.Messages.CONFIRM_GROUP_DELETE_2
                    spyOn(GroupService, 'deleteGroup').and.callThrough()
                    scope.delete().catch ->
                        expect(GroupService.deleteGroup).not.toHaveBeenCalled()
                        done()
                    $rootScope.$digest()

                it 'should call GroupService.deleteGroup with editingGroup', (done) ->
                    spyOn($window, 'confirm').and.callFake -> true
                    spyOn(GroupService, 'deleteGroup').and.callThrough()
                    scope.delete().then ->
                        expect(GroupService.deleteGroup).toHaveBeenCalledWith(editingGroup)
                        done()
                    $rootScope.$digest()


            describe 'delete successfully', ->

                beforeEach ->
                    $controller('editGroupPropertiesModalController', editGroupPropertiesModalControllerParams)

                it 'should close the modal', (done) ->
                    spyOn(uibModalInstance, 'close').and.callFake -> true
                    scope.delete().then ->
                        expect(uibModalInstance.close).toHaveBeenCalledWith([editingGroup, true])
                        done()
                    $rootScope.$digest()


            describe 'delete failed', ->

                beforeEach ->
                    angular.extend GroupService, {
                        deleteGroup: -> rejectedPromiseFunc('test error message')
                    }
                    $controller('editGroupPropertiesModalController', editGroupPropertiesModalControllerParams)

                it 'should set scope.disableModal to false', (done) ->
                    scope.delete().catch ->
                        expect(scope.disableModal).toEqual(false)
                        done()
                    $rootScope.$digest()

                it 'should set scope.error to the error returned from GroupService.deleteGroup', (done) ->
                    scope.delete().catch ->
                        expect(scope.error).toEqual('test error message')
                        done()
                    $rootScope.$digest()


        describe 'scope.cancel', ->

            it 'should dismiss the modal', ->
                $controller('editGroupPropertiesModalController', editGroupPropertiesModalControllerParams)
                spyOn(uibModalInstance, 'dismiss').and.callThrough()
                scope.cancel()
                expect(uibModalInstance.dismiss).toHaveBeenCalled()


    describe 'editGroupMembersModalController', ->

        editingGroup = editGroupMembersModalControllerParams = undefined

        beforeEach ->
            editingGroup = {
                _id: 5
                name: 'test group name'
                _members: []
                _owner: 'justinId'
            }
            User = { _id: 'justinId', username: 'Justin' }
            editGroupMembersModalControllerParams = {
                $scope: scope
                $uibModalInstance: uibModalInstance
                editingGroup: editingGroup
                GroupService: GroupService
                UserService: UserService
                User: User
            }

        describe 'setup', ->

            beforeEach  ->
                spyOn(AuthService, 'getUser').and.callThrough()
                $controller('editGroupMembersModalController', editGroupMembersModalControllerParams)

            it 'should set scope.editingGroup to a deep copy of the resolved editingGroup parameter', ->
                expect(scope.editingGroup).toEqual(editingGroup)
                editingGroup = 'thing'
                expect(scope.editingGroup).not.toEqual(editingGroup)

            it 'should initialize scope._owner to the owner of the scope.editingGroup', ->
                expect(scope._owner).toEqual('justinId')

            it 'should define the scope.getUsers function', ->
                expect(scope.getUsers).toBeDefined()

            it 'should define the scope.addMember function', ->
                expect(scope.addMember).toBeDefined()

            it 'should define the scope.removeMember function', ->
                expect(scope.removeMember).toBeDefined()

            it 'should define the scope.getMemberDisplay function', ->
                expect(scope.getMemberDisplay).toBeDefined()

            it 'should define the scope.close function', ->
                expect(scope.close).toBeDefined()

            it 'should set scope.isOwner to true if the resolved user id matches the groups owner', ->
                expect(scope.isOwner).toEqual(true)

        describe 'setup not owner of group', ->

            beforeEach  ->
                angular.extend editGroupMembersModalControllerParams, {
                    User: { _id: 'notJustinId' }
                }
                $controller('editGroupMembersModalController', editGroupMembersModalControllerParams)

            it "should set scope.isOwner to false if the resolved user id doesn't match the groups owner", ->
                expect(scope.isOwner).toEqual(false)


        describe 'scope.getUsers, get users successfully', ->

            beforeEach ->
                $controller('editGroupMembersModalController', editGroupMembersModalControllerParams)

            it 'should call UserService.findUsers with the given query to get the list of users', (done) ->
                spyOn(UserService, 'findUsers').and.callThrough()
                scope.getUsers('query').then ->
                    expect(UserService.findUsers).toHaveBeenCalledWith('query', editingGroup._id)
                    done()
                $rootScope.$digest()

            it 'should return the list of message users found', ->
                scope.getUsers('query').then (users) ->
                    expect(users).toEqual('query')
                $rootScope.$digest()


        describe 'scope.getUsers, get users failed', ->

            beforeEach ->
                angular.extend UserService, {
                    findUsers: -> rejectedPromiseFunc('test error message')
                }
                $controller('editGroupMembersModalController', editGroupMembersModalControllerParams)


            it 'should set scope.error to the error message returned from the UserService.findUsers', (done) ->
                scope.getUsers('query').catch ->
                    expect(scope.error).toEqual('test error message')
                    done()
                $rootScope.$digest()


        describe 'scope.addMember, member adds successfully', ->

            beforeEach ->
                scope.memberToAdd = { name: 'Justin' }
                $controller('editGroupMembersModalController', editGroupMembersModalControllerParams)

            it 'should set scope.disableModal to true', ->
                scope.addMember()
                expect(scope.disableModal).toEqual(true)

            it 'should call GroupService.addMember with the member to add', (done) ->
                spyOn(GroupService, 'addMember').and.callThrough()
                scope.addMember().then ->
                    expect(GroupService.addMember).toHaveBeenCalledWith(editingGroup._id, { name: 'Justin' })
                    done()
                $rootScope.$digest()

            it 'should set scope.disableModal to false', (done) ->
                scope.addMember().then ->
                    expect(scope.disableModal).toEqual(false)
                    done()
                $rootScope.$digest()

            it 'should push the newly added member onto the scope.editingGroup._members list', (done) ->
                scope.addMember().then ->
                    expect(scope.editingGroup._members).toEqual([{ _id: 'newMemberId', name: 'test return member' }])
                    done()
                $rootScope.$digest()

            it 'should clear scope.memberToAdd', (done) ->
                scope.addMember().then ->
                    expect(scope.memberToAdd).toEqual(null)
                    done()
                $rootScope.$digest()


        describe 'scope.addMember, member add fails', ->

            beforeEach ->
                scope.memberToAdd = { name: 'Justin' }
                angular.extend GroupService, {
                    addMember: -> rejectedPromiseFunc('test error message')
                }
                $controller('editGroupMembersModalController', editGroupMembersModalControllerParams)

            it 'should set the scope.disableModal to false', (done) ->
                scope.addMember().catch (message) ->
                    expect(scope.disableModal).toEqual(false)
                    done()
                $rootScope.$digest()

            it 'should set the scope.error to the error passed back from the GroupService.addMember', (done) ->
                scope.addMember().catch (message) ->
                    expect(scope.error).toEqual('test error message')
                    done()
                $rootScope.$digest()


        describe 'scope.removeMember, member removal succeeds', ->

            _memberToRemove = undefined

            beforeEach ->
                _memberToRemove = 'justinId'
                $controller('editGroupMembersModalController', editGroupMembersModalControllerParams)

            it 'should set scope.disableModal to true', ->
                scope.removeMember(_memberToRemove)
                expect(scope.disableModal).toEqual(true)

            it 'should call GroupService.removeMember with the member to remove', (done) ->
                spyOn(GroupService, 'removeMember').and.callThrough()
                scope.removeMember(_memberToRemove).then ->
                    expect(GroupService.removeMember).toHaveBeenCalledWith(editingGroup._id, 'justinId')
                    done()
                $rootScope.$digest()

            it 'should set scope.disableModal to false', (done) ->
                scope.removeMember(_memberToRemove).then ->
                    expect(scope.disableModal).toEqual(false)
                    done()
                $rootScope.$digest()

            it 'should remove the newly removed member from the scope.editingGroup._members list', (done) ->
                scope.editingGroup._members = [{ _id: 'otherId', name: 'Other' }, { _id: 'justinId', name: 'Justin' }]
                scope.removeMember(_memberToRemove).then ->
                    expect(scope.editingGroup._members).toEqual([{ _id: 'otherId', name: 'Other' }])
                    done()
                $rootScope.$digest()


        describe 'scope.removeMember, member removal fails', ->

            beforeEach ->
                angular.extend GroupService, {
                    removeMember: -> rejectedPromiseFunc('test error message')
                }
                $controller('editGroupMembersModalController', editGroupMembersModalControllerParams)

            it 'should set the scope.disableModal to false', (done) ->
                scope.removeMember().catch (message) ->
                    expect(scope.disableModal).toEqual(false)
                    done()
                $rootScope.$digest()

            it 'should set the scope.error to the error passed back from the GroupService.removeMember', (done) ->
                scope.removeMember().catch (message) ->
                    expect(scope.error).toEqual('test error message')
                    done()
                $rootScope.$digest()


        describe 'scope.getMemberDisplay', ->

            beforeEach ->
                $controller('editGroupMembersModalController', editGroupMembersModalControllerParams)

            it 'should return an empty string if the member passed to the function is undefined', ->
                expect(scope.getMemberDisplay()).toEqual('')

            it "should return the member in 'username (firstname lastname) format' is a member us passed", ->
                member = {
                    username: 'JustinStribling'
                    firstName: 'Justin'
                    lastName: 'Stribling'
                }
                expect(scope.getMemberDisplay(member)).toEqual('JustinStribling (Justin Stribling)')


        describe 'scope.close', ->

            beforeEach ->
                angular.extend uibModalInstance, {
                    close: (addedGroup) ->
                }
                $controller('editGroupMembersModalController', editGroupMembersModalControllerParams)

            it 'should close the modal with the editingGroup', ->
                spyOn(uibModalInstance, 'close').and.callThrough()
                scope.close()
                expect(uibModalInstance.close).toHaveBeenCalledWith(editingGroup)


    describe 'workspaceController', ->

        workspaceControllerParams = undefined
        Socket = undefined
        testUser = undefined
        stateParams = undefined

        describe 'setup', ->

            beforeEach ->
                testUser = { username: 'Justin' }
                stateParams = { groupId: 'test groupId' }
                Socket = {
                    on: ->
                    emit: -> 'test emit'
                }
                workspaceControllerParams = {
                    $scope: scope
                    $stateParams: stateParams
                    User: testUser
                    socket: Socket
                }
                spyOn(Socket, 'emit').and.callThrough()
                $controller('workspaceController', workspaceControllerParams)

            it 'should initialize scope.chatVisible to true', ->
                expect(scope.chatVisible).toEqual(true)

            it 'should into scope.user to the given User', ->
                expect(scope.user).toEqual(testUser)

            it "should emit 'groupConnect' with the username and groupId tot he socket", ->
                expect(scope.socket.emit).toHaveBeenCalledWith('groupConnect', testUser, stateParams.groupId)


        describe 'server emits setGroupId', ->

            beforeEach ->
                testUser = { username: 'Justin' }
                stateParams = { groupId: 'test groupId' }
                Socket = {
                    on: (name, callback) ->
                        if name is 'setGroupId'
                            callback('testGroupId')
                    emit: -> 'test emit'
                }
                workspaceControllerParams = {
                    $scope: scope
                    $stateParams: stateParams
                    User: testUser
                    socket: Socket
                }
                $controller('workspaceController', workspaceControllerParams)

            it 'should initialize scope.chatVisible to true', (done) ->
                scope.socket._group.then (_group) ->
                    expect(_group).toEqual('testGroupId')
                    done()
                $rootScope.$digest()


        describe 'server emits notAllowed', ->

            state = undefined
            Constants = undefined

            beforeEach ->
                Constants = {
                    DEFAULT_ROUTE: 'test default group'
                }
                state = {
                    go: ->
                }
                testUser = { username: 'Justin' }
                stateParams = { groupId: 'test groupId' }
                Socket = {
                    on: (name, callback) ->
                        if name is 'notAllowed'
                            callback('testGroupName')
                    emit: -> 'test emit'
                }
                workspaceControllerParams = {
                    $scope: scope
                    $state: state
                    $stateParams: stateParams
                    User: testUser
                    socket: Socket
                    Constants: Constants
                }
                spyOn(state, 'go').and.callThrough()
                $controller('workspaceController', workspaceControllerParams)

            it 'should call state.go with the Constants.DEFAULT_ROUTE', ->
                $rootScope.$digest()
                expect(state.go).toHaveBeenCalledWith(Constants.DEFAULT_ROUTE)
