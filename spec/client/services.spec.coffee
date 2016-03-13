describe 'Services', ->

    beforeEach(module('runwayAppServices'))

    Constants = undefined
    resolvedPromiseFunc = undefined
    rejectedPromiseFunc = undefined
    $rootScope = undefined
    httpBackend = undefined


    beforeEach inject ($q, _Constants_, _$rootScope_, _$httpBackend_) ->
        Constants = _Constants_
        $rootScope = _$rootScope_
        httpBackend = _$httpBackend_

        resolvedPromiseFunc = (value) ->
            deferred = $q.defer()
            deferred.resolve(value)
            deferred.promise

        rejectedPromiseFunc = (value) ->
            deferred = $q.defer()
            deferred.reject(value)
            deferred.promise


    describe 'AuthService', ->

        AuthService = mockUser = undefined

        beforeEach inject (_AuthService_) ->
            AuthService = _AuthService_
            mockUser = {
                username: 'Justin'
            }
            AuthService.user = mockUser


        describe 'getUser', ->

            it 'should return the user', ->
                expect(AuthService.getUser()).toEqual(mockUser)


        describe 'loggedIn', ->

            it 'should POST to /getUserStatus', ->
                httpBackend.expectPOST('/getUserStatus').respond(200, {loggedIn: true, user: mockUser})
                AuthService.loggedIn()
                httpBackend.flush()


            describe 'successful', ->

                it 'should set the user to the retuned user if the user is logged in', (done) ->
                    mockUser2 = {
                        groups: ['thing1', 'thing2']
                    }
                    httpBackend.expectPOST('/getUserStatus').respond(200, {loggedIn: true, user: mockUser2})
                    AuthService.loggedIn().then ->
                        expect(AuthService.user).toEqual(mockUser2)
                        done()
                    httpBackend.flush()

                it 'should clear the user if the user if not logged in', (done) ->
                    mockUser2 = {
                        groups: ['thing1', 'thing2']
                    }
                    httpBackend.expectPOST('/getUserStatus').respond(200, {loggedIn: false, user: mockUser2})
                    AuthService.loggedIn().catch ->
                        expect(AuthService.user).toEqual(null)
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should clear the user', (done) ->
                    httpBackend.expectPOST('/getUserStatus').respond(500)
                    AuthService.loggedIn().catch ->
                        expect(AuthService.user).toEqual(null)
                        done()
                    httpBackend.flush()


        describe 'login', ->

            it 'should POST to /login', ->
                httpBackend.expectPOST('/login').respond(200, {user: mockUser})
                AuthService.login('Justin', 'superSecretPassword')
                httpBackend.flush()


            describe 'successful', ->

                it 'should set the user to the retuned user if the status is 200', (done) ->
                    mockUser2 = {
                        groups: ['thing1', 'thing2']
                    }
                    httpBackend.expectPOST('/login').respond(200, {user: mockUser2})
                    AuthService.login('Justin', 'superSecretPassword').then ->
                        expect(AuthService.user).toEqual(mockUser2)
                        done()
                    httpBackend.flush()

                it "should clear the user and reject with error message if the status isn't 200", (done) ->
                    mockUser2 = {
                        groups: ['thing1', 'thing2']
                    }
                    httpBackend.expectPOST('/login').respond(201, {user: mockUser2, error: 'test error messsage'})
                    AuthService.login('Justin', 'superSecretPassword').catch (message) ->
                        expect(AuthService.user).toEqual(null)
                        expect(message).toEqual('test error messsage')
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should clear the user and reject with the user message', (done) ->
                    httpBackend.expectPOST('/login').respond(500, {error: 'test error messsage'})
                    AuthService.login('Justin', 'superSecretPassword').catch (message) ->
                        expect(AuthService.user).toEqual(null)
                        expect(message).toEqual('test error messsage')
                        done()
                    httpBackend.flush()


        describe 'logout', ->

            it 'should GET /logout', ->
                httpBackend.expectGET('/logout').respond(200)
                AuthService.logout()
                httpBackend.flush()


            describe 'successful', ->

                it 'should clear the user', (done) ->
                    httpBackend.expectGET('/logout').respond(200)
                    AuthService.logout().then ->
                        expect(AuthService.user).toEqual(null)
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should clear the user', (done) ->
                    httpBackend.expectGET('/logout').respond(500)
                    AuthService.logout().catch ->
                        expect(AuthService.user).toEqual(null)
                        done()
                    httpBackend.flush()

        describe 'register', ->

            registerForm = undefined

            beforeEach ->
                registerForm = {
                    username: 'JustinStribling'
                    password: 'superSecretPassword'
                    firstName: 'Justin'
                    lastNAme: 'Stribling'
                }

            it 'should POST to /register', ->
                httpBackend.expectPOST('/register').respond(200)
                AuthService.register(registerForm)
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the promise if the status is 200', (done) ->
                    httpBackend.expectPOST('/register').respond(200)
                    AuthService.register(registerForm).then -> done()
                    httpBackend.flush()

                it "should reject the promise with error messsage if the status isn't 200", (done) ->
                    httpBackend.expectPOST('/register').respond(201, {error: 'test error messsage'})
                    AuthService.register(registerForm).catch (message) ->
                        expect(message).toEqual('test error messsage')
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject the promise with error message', (done) ->
                    httpBackend.expectPOST('/register').respond(500, {error: 'test error messsage'})
                    AuthService.register(registerForm).catch (message) ->
                        expect(message).toEqual('test error messsage')
                        done()
                    httpBackend.flush()


    describe 'GroupService', ->

        GroupService = undefined

        beforeEach inject (_GroupService_) ->
            GroupService = _GroupService_

        describe 'getGroups', ->

            groupToGet = undefined

            beforeEach ->
                groupToGet = 'testGroup'

            it 'should GET /api/groups/', ->
                httpBackend.expectGET('/api/groups/' + groupToGet).respond(200, ['group1', 'group2'])
                GroupService.getGroups(groupToGet)
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the gorups if there is at least one group sent back', (done) ->
                    httpBackend.expectGET('/api/groups/' + groupToGet).respond(200, ['group1'])
                    GroupService.getGroups(groupToGet).then (groups) ->
                        expect(groups).toEqual(['group1'])
                        done()
                    httpBackend.flush()

                it 'should reject with NO_OWNED_GROUPS error message if there are not groups and the type requested is owned', (done) ->
                    httpBackend.expectGET('/api/groups/owned').respond(200, [])
                    GroupService.getGroups('owned').catch (message) ->
                        expect(message).toEqual(Constants.Messages.NO_OWNED_GROUPS)
                        done()
                    httpBackend.flush()

                it 'should reject with NO_JOINED_GROUPS error message if there are not groups and the type requested is joined', (done) ->
                    httpBackend.expectGET('/api/groups/joined').respond(200, [])
                    GroupService.getGroups('joined').catch (message) ->
                        expect(message).toEqual(Constants.Messages.NO_JOINED_GROUPS)
                        done()
                    httpBackend.flush()

                it 'should reject with NO_JOINED_GROUPS error message if there are not groups and the type requested is joined', (done) ->
                    httpBackend.expectGET('/api/groups/thing').respond(200, [])
                    GroupService.getGroups('thing').catch (message) ->
                        expect(message).toEqual(Constants.Messages.UNSUPPORTED_GROUP_TYPE)
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR ', (done) ->
                    httpBackend.expectGET('/api/groups/' + groupToGet).respond(500)
                    GroupService.getGroups(groupToGet).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


        describe 'addGroup', ->

            newGroup = undefined

            beforeEach ->
                newGroup = {
                    name: 'thing'
                }

            it 'should POST to /api/newGroup', ->
                httpBackend.expectPOST('/api/newGroup', newGroup).respond(200)
                GroupService.addGroup(newGroup)
                httpBackend.flush()


            describe 'invalid group given', ->

                it 'should reject with NO_GROUP_NAME_PROVIDED when not group given', (done) ->
                    GroupService.addGroup().catch (message) ->
                        expect(message).toEqual(Constants.Messages.NO_GROUP_NAME_PROVIDED)
                        done()
                    $rootScope.$digest()

                it 'should reject with NO_GROUP_NAME_PROVIDED when group name zero characters', (done) ->
                    GroupService.addGroup({name: ''}).catch (message) ->
                        expect(message).toEqual(Constants.Messages.NO_GROUP_NAME_PROVIDED)
                        done()
                    $rootScope.$digest()

            describe 'successful', ->

                it 'should resolve the group returned', (done) ->
                    httpBackend.expectPOST('/api/newGroup').respond(200, newGroup)
                    GroupService.addGroup(newGroup).then (groups) ->
                        expect(groups).toEqual(newGroup)
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with GROUP_ALREADY_EXISTS when status is 409', (done) ->
                    httpBackend.expectPOST('/api/newGroup').respond(409)
                    GroupService.addGroup(newGroup).catch (message) ->
                        expect(message).toEqual(Constants.Messages.GROUP_ALREADY_EXISTS)
                        done()
                    httpBackend.flush()

                it 'should reject with SERVER_ERROR otherwise', (done) ->
                    httpBackend.expectPOST('/api/newGroup').respond(500)
                    GroupService.addGroup(newGroup).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


        describe 'editGroup', ->

            groupToEdit = undefined

            beforeEach ->
                groupToEdit = {
                    name: 'thing'
                }

            it 'should POST to /api/editGroup', ->
                httpBackend.expectPOST('/api/editGroup', groupToEdit).respond(200)
                GroupService.editGroup(groupToEdit)
                httpBackend.flush()


            describe 'invalid group given', ->

                it 'should reject with NO_GROUP_NAME_PROVIDED when not group given', (done) ->
                    GroupService.editGroup().catch (message) ->
                        expect(message).toEqual(Constants.Messages.NO_GROUP_NAME_PROVIDED)
                        done()
                    $rootScope.$digest()

                it 'should reject with NO_GROUP_NAME_PROVIDED when group name zero characters', (done) ->
                    GroupService.editGroup({name: ''}).catch (message) ->
                        expect(message).toEqual(Constants.Messages.NO_GROUP_NAME_PROVIDED)
                        done()
                    $rootScope.$digest()


            describe 'successful', ->

                it 'should resolve the group returned', (done) ->
                    httpBackend.expectPOST('/api/editGroup').respond(200, groupToEdit)
                    GroupService.editGroup(groupToEdit).then (groups) ->
                        expect(groups).toEqual(groupToEdit)
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with GROUP_ALREADY_EXISTS when status is 409', (done) ->
                    httpBackend.expectPOST('/api/editGroup').respond(409)
                    GroupService.editGroup(groupToEdit).catch (message) ->
                        expect(message).toEqual(Constants.Messages.GROUP_ALREADY_EXISTS)
                        done()
                    httpBackend.flush()

                it 'should reject with SERVER_ERROR otherwise', (done) ->
                    httpBackend.expectPOST('/api/editGroup').respond(500)
                    GroupService.editGroup(groupToEdit).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()



        describe 'addMember', ->

            _group = memberToAdd = undefined

            beforeEach ->
                _group = 'testGroup'
                memberToAdd = {username: 'Justin'}

            it 'should POST to /api/addGroupMember', ->
                httpBackend.expectPOST('/api/addGroupMember', {_group: _group, memberToAdd: memberToAdd}).respond(200)
                GroupService.addMember(_group, memberToAdd)
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the promise', (done) ->
                    httpBackend.expectPOST('/api/addGroupMember', {_group: _group, memberToAdd: memberToAdd}).respond(200)
                    GroupService.addMember(_group, memberToAdd).then -> done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with USER_ALREADY_IN_GROUP when status is 409', (done) ->
                    httpBackend.expectPOST('/api/addGroupMember', {_group: _group, memberToAdd: memberToAdd}).respond(409)
                    GroupService.addMember(_group, memberToAdd).catch (message) ->
                        expect(message).toEqual(Constants.Messages.USER_ALREADY_IN_GROUP)
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR otherwise', (done) ->
                    httpBackend.expectPOST('/api/addGroupMember', {_group: _group, memberToAdd: memberToAdd}).respond(500)
                    GroupService.addMember(_group, memberToAdd).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()



        describe 'deleteGroup', ->

            groupToDelete = undefined

            beforeEach ->
                groupToDelete = 'testGroup'

            it 'should POST to /api/deleteGroup', ->
                httpBackend.expectPOST('/api/deleteGroup', groupToDelete).respond(200)
                GroupService.deleteGroup(groupToDelete)
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the promise', (done) ->
                    httpBackend.expectPOST('/api/deleteGroup', groupToDelete).respond(200)
                    GroupService.deleteGroup(groupToDelete).then -> done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with MUST_BE_OWNER_TO_DELETE when status is 401', (done) ->
                    httpBackend.expectPOST('/api/deleteGroup', groupToDelete).respond(401)
                    GroupService.deleteGroup(groupToDelete).catch (message) ->
                        expect(message).toEqual(Constants.Messages.MUST_BE_OWNER_TO_DELETE)
                        done()
                    httpBackend.flush()

                it 'should reject with SERVER_ERROR otherwise', (done) ->
                    httpBackend.expectPOST('/api/deleteGroup', groupToDelete).respond(500)
                    GroupService.deleteGroup(groupToDelete).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


    describe 'UserService', ->

        UserService = undefined

        beforeEach inject (_UserService_) ->
            UserService = _UserService_


        describe 'getUsers', ->

            testQuery = undefined

            beforeEach ->
                testQuery = 'test query'

            it 'should POST to /api/getUsers', ->
                httpBackend.expectPOST('/api/getUsers', {query: testQuery}).respond(200)
                UserService.getUsers(testQuery)
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the members returned', (done) ->
                    httpBackend.expectPOST('/api/getUsers', {query: testQuery}).respond(200, ['member1', 'member2'])
                    UserService.getUsers(testQuery).then (members) ->
                        expect(members).toEqual(['member1', 'member2'])
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR', (done) ->
                    httpBackend.expectPOST('/api/getUsers', {query: testQuery}).respond(401)
                    UserService.getUsers(testQuery).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()
