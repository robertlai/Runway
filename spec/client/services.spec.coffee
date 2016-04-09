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


        describe 'getUser', ->

            it 'should return the user if the user exists', (done) ->
                AuthService.user = mockUser
                AuthService.getUser().then (user) ->
                    expect(user).toEqual(mockUser)
                    done()
                $rootScope.$digest()

            it 'should POST to /getUserStatus when no user exits', ->
                httpBackend.expectPOST('/getUserStatus').respond(200, { loggedIn: true, user: mockUser })
                AuthService.getUser()
                httpBackend.flush()


            describe 'successful', ->

                it 'should set the user to the retuned user if the user is logged in', (done) ->
                    mockUser2 = {
                        groups: ['thing1', 'thing2']
                    }
                    httpBackend.expectPOST('/getUserStatus').respond(200, { loggedIn: true, user: mockUser2 })
                    AuthService.getUser().then ->
                        expect(AuthService.user).toEqual(mockUser2)
                        done()
                    httpBackend.flush()

                it 'should clear the user if the user if not logged in', (done) ->
                    mockUser2 = {
                        groups: ['thing1', 'thing2']
                    }
                    httpBackend.expectPOST('/getUserStatus').respond(200, { loggedIn: false, user: mockUser2 })
                    AuthService.getUser().catch ->
                        expect(AuthService.user).toEqual(null)
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should clear the user', (done) ->
                    httpBackend.expectPOST('/getUserStatus').respond(500)
                    AuthService.getUser().catch ->
                        expect(AuthService.user).toEqual(null)
                        done()
                    httpBackend.flush()


        describe 'login', ->

            it 'should POST to /login', ->
                httpBackend.expectPOST('/login').respond(200, { user: mockUser })
                AuthService.login('Justin', 'superSecretPassword')
                httpBackend.flush()


            describe 'successful', ->

                it 'should set the user to the retuned user if the status is 200', (done) ->
                    mockUser2 = {
                        groups: ['thing1', 'thing2']
                    }
                    httpBackend.expectPOST('/login').respond(200, { user: mockUser2 })
                    AuthService.login('Justin', 'superSecretPassword').then ->
                        expect(AuthService.user).toEqual(mockUser2)
                        done()
                    httpBackend.flush()

                it "should clear the user and reject with error message if the status isn't 200", (done) ->
                    mockUser2 = {
                        groups: ['thing1', 'thing2']
                    }
                    httpBackend.expectPOST('/login').respond(201, { user: mockUser2, error: 'test error messsage' })
                    AuthService.login('Justin', 'superSecretPassword').catch (message) ->
                        expect(AuthService.user).toEqual(null)
                        expect(message).toEqual('test error messsage')
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should clear the user and reject with the user message', (done) ->
                    httpBackend.expectPOST('/login').respond(500, { error: 'test error messsage' })
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
                    httpBackend.expectPOST('/register').respond(201, { error: 'test error messsage' })
                    AuthService.register(registerForm).catch (message) ->
                        expect(message).toEqual('test error messsage')
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject the promise with error message', (done) ->
                    httpBackend.expectPOST('/register').respond(500, { error: 'test error messsage' })
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

            it 'should POST to /api/groups/new', ->
                httpBackend.expectPOST('/api/groups/new', newGroup).respond(200)
                GroupService.addGroup(newGroup)
                httpBackend.flush()


            describe 'invalid group given', ->

                it 'should reject with NO_GROUP_NAME_PROVIDED when not group given', (done) ->
                    GroupService.addGroup().catch (message) ->
                        expect(message).toEqual(Constants.Messages.NO_GROUP_NAME_PROVIDED)
                        done()
                    $rootScope.$digest()

                it 'should reject with NO_GROUP_NAME_PROVIDED when group name zero characters', (done) ->
                    GroupService.addGroup({ name: '' }).catch (message) ->
                        expect(message).toEqual(Constants.Messages.NO_GROUP_NAME_PROVIDED)
                        done()
                    $rootScope.$digest()

            describe 'successful', ->

                it 'should resolve the group returned', (done) ->
                    httpBackend.expectPOST('/api/groups/new').respond(200, newGroup)
                    GroupService.addGroup(newGroup).then (groups) ->
                        expect(groups).toEqual(newGroup)
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with GROUP_ALREADY_EXISTS when status is 409', (done) ->
                    httpBackend.expectPOST('/api/groups/new').respond(409)
                    GroupService.addGroup(newGroup).catch (message) ->
                        expect(message).toEqual(Constants.Messages.GROUP_ALREADY_EXISTS)
                        done()
                    httpBackend.flush()

                it 'should reject with SERVER_ERROR otherwise', (done) ->
                    httpBackend.expectPOST('/api/groups/new').respond(500)
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

            it 'should POST to /api/groups/edit', ->
                httpBackend.expectPOST('/api/groups/edit', groupToEdit).respond(200)
                GroupService.editGroup(groupToEdit)
                httpBackend.flush()


            describe 'invalid group given', ->

                it 'should reject with NO_GROUP_NAME_PROVIDED when not group given', (done) ->
                    GroupService.editGroup().catch (message) ->
                        expect(message).toEqual(Constants.Messages.NO_GROUP_NAME_PROVIDED)
                        done()
                    $rootScope.$digest()

                it 'should reject with NO_GROUP_NAME_PROVIDED when group name zero characters', (done) ->
                    GroupService.editGroup({ name: '' }).catch (message) ->
                        expect(message).toEqual(Constants.Messages.NO_GROUP_NAME_PROVIDED)
                        done()
                    $rootScope.$digest()


            describe 'successful', ->

                it 'should resolve the group returned', (done) ->
                    httpBackend.expectPOST('/api/groups/edit').respond(200, groupToEdit)
                    GroupService.editGroup(groupToEdit).then (groups) ->
                        expect(groups).toEqual(groupToEdit)
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with GROUP_ALREADY_EXISTS when status is 409', (done) ->
                    httpBackend.expectPOST('/api/groups/edit').respond(409)
                    GroupService.editGroup(groupToEdit).catch (message) ->
                        expect(message).toEqual(Constants.Messages.GROUP_ALREADY_EXISTS)
                        done()
                    httpBackend.flush()

                it 'should reject with SERVER_ERROR otherwise', (done) ->
                    httpBackend.expectPOST('/api/groups/edit').respond(500)
                    GroupService.editGroup(groupToEdit).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()



        describe 'addMember', ->

            _group = memberToAdd = undefined

            beforeEach ->
                _group = 'testGroup'
                memberToAdd = { username: 'Justin' }

            it 'should POST to /api/groups/addMember', ->
                httpBackend.expectPOST('/api/groups/addMember', { _group: _group, memberToAdd: memberToAdd }).respond(200)
                GroupService.addMember(_group, memberToAdd)
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the promise', (done) ->
                    httpBackend.expectPOST('/api/groups/addMember', { _group: _group, memberToAdd: memberToAdd }).respond(200)
                    GroupService.addMember(_group, memberToAdd).then -> done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with USER_ALREADY_IN_GROUP when status is 409', (done) ->
                    httpBackend.expectPOST('/api/groups/addMember', { _group: _group, memberToAdd: memberToAdd }).respond(409)
                    GroupService.addMember(_group, memberToAdd).catch (message) ->
                        expect(message).toEqual(Constants.Messages.USER_ALREADY_IN_GROUP)
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR otherwise', (done) ->
                    httpBackend.expectPOST('/api/groups/addMember', { _group: _group, memberToAdd: memberToAdd }).respond(500)
                    GroupService.addMember(_group, memberToAdd).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()



        describe 'deleteGroup', ->

            groupToDelete = undefined

            beforeEach ->
                groupToDelete = 'testGroup'

            it 'should POST to /api/groups/delete', ->
                httpBackend.expectPOST('/api/groups/delete', groupToDelete).respond(200)
                GroupService.deleteGroup(groupToDelete)
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the promise', (done) ->
                    httpBackend.expectPOST('/api/groups/delete', groupToDelete).respond(200)
                    GroupService.deleteGroup(groupToDelete).then -> done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with MUST_BE_OWNER_TO_DELETE when status is 401', (done) ->
                    httpBackend.expectPOST('/api/groups/delete', groupToDelete).respond(401)
                    GroupService.deleteGroup(groupToDelete).catch (message) ->
                        expect(message).toEqual(Constants.Messages.MUST_BE_OWNER_TO_DELETE)
                        done()
                    httpBackend.flush()

                it 'should reject with SERVER_ERROR otherwise', (done) ->
                    httpBackend.expectPOST('/api/groups/delete', groupToDelete).respond(500)
                    GroupService.deleteGroup(groupToDelete).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


    describe 'UserService', ->

        UserService = undefined

        beforeEach inject (_UserService_) ->
            UserService = _UserService_


        describe 'findUsers', ->

            testQuery = undefined

            beforeEach ->
                testQuery = 'test query'

            it 'should POST to /api/users/find', ->
                httpBackend.expectPOST('/api/users/find', { query: testQuery }).respond(200)
                UserService.findUsers(testQuery)
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the members returned', (done) ->
                    httpBackend.expectPOST('/api/users/find', { query: testQuery }).respond(200, ['member1', 'member2'])
                    UserService.findUsers(testQuery).then (members) ->
                        expect(members).toEqual(['member1', 'member2'])
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR', (done) ->
                    httpBackend.expectPOST('/api/users/find', { query: testQuery }).respond(401)
                    UserService.findUsers(testQuery).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


        describe 'updateGeneralSettings', ->

            user = undefined

            beforeEach ->
                user = { username: 'Justin' }

            it 'should POST to /api/users/updateGeneralSettings', ->
                httpBackend.expectPOST('/api/users/updateGeneralSettings', user).respond(200)
                UserService.updateGeneralSettings(user)
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the promise', (done) ->
                    httpBackend.expectPOST('/api/users/updateGeneralSettings', user).respond(200)
                    UserService.updateGeneralSettings(user).then ->
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR', (done) ->
                    httpBackend.expectPOST('/api/users/updateGeneralSettings', user).respond(401)
                    UserService.updateGeneralSettings(user).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


        describe 'saveUserSettings', ->

            user = undefined

            beforeEach ->
                user = { username: 'Justin' }

            it 'should POST to /api/users/updateUserSettings', ->
                httpBackend.expectPOST('/api/users/updateUserSettings', user).respond(200)
                UserService.saveUserSettings(user)
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the promise', (done) ->
                    httpBackend.expectPOST('/api/users/updateUserSettings', user).respond(200)
                    UserService.saveUserSettings(user).then ->
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR', (done) ->
                    httpBackend.expectPOST('/api/users/updateUserSettings', user).respond(401)
                    UserService.saveUserSettings(user).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


    describe 'MessageService', ->

        MessageService = undefined

        beforeEach inject (_MessageService_) ->
            MessageService = _MessageService_


        describe 'addNewMessageToChat', ->

            _group = undefined
            messageContent = undefined

            beforeEach ->
                _group = 'groupId'
                messageContent = 'an interesting message'

            it 'should GET /api/messages/new', (done) ->
                httpBackend.expectPOST('/api/messages/new', { _group: _group, messageContent: messageContent }).respond(200)
                MessageService.addNewMessageToChat(_group, messageContent).then ->
                    done()
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the messages returned', (done) ->
                    httpBackend.expectPOST('/api/messages/new', { _group: _group, messageContent: messageContent }).respond(200)
                    MessageService.addNewMessageToChat(_group, messageContent).then ->
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR', (done) ->
                    httpBackend.expectPOST('/api/messages/new', { _group: _group, messageContent: messageContent }).respond(401)
                    MessageService.addNewMessageToChat(_group, messageContent).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


        describe 'removeMessage', ->

            _message = undefined

            beforeEach ->
                _message = 'messageId'

            it 'should POST to /api/messages/delete', ->
                httpBackend.expectPOST('/api/messages/delete', { _message: _message }).respond(200)
                MessageService.removeMessage(_message)
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve when returned', (done) ->
                    httpBackend.expectPOST('/api/messages/delete', { _message: _message }).respond(200)
                    MessageService.removeMessage(_message).then ->
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR', (done) ->
                    httpBackend.expectPOST('/api/messages/delete', { _message: _message }).respond(401)
                    MessageService.removeMessage(_message).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


        describe 'getInitialMessages', ->

            _group = undefined

            beforeEach ->
                _group = 'groupId'

            it 'should POST to /api/messages/getInitial', (done) ->
                httpBackend.expectPOST('/api/messages/getInitial', { _group: _group }).respond(200)
                MessageService.getInitialMessages(_group).then ->
                    done()
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the messages returned', (done) ->
                    httpBackend.expectPOST('/api/messages/getInitial', { _group: _group }).respond(200, ['message1', 'message2'])
                    MessageService.getInitialMessages(_group).then (messages) ->
                        expect(messages).toEqual(['message1', 'message2'])
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR', (done) ->
                    httpBackend.expectPOST('/api/messages/getInitial', { _group: _group }).respond(401)
                    MessageService.getInitialMessages(_group).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


        describe 'getMoreMessages', ->

            _group = undefined
            lastDate = undefined

            beforeEach ->
                _group = 'groupID'
                lastDate = 'testLastDate'

            it 'should POST to /api/messages/getMore', (done) ->
                httpBackend.expectPOST('/api/messages/getMore', { _group: _group, lastDate: lastDate }).respond(200)
                MessageService.getMoreMessages(_group, lastDate).then ->
                    done()
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the messages returned', (done) ->
                    httpBackend.expectPOST('/api/messages/getMore', { _group: _group, lastDate: lastDate }).respond(200, ['message1', 'message2'])
                    MessageService.getMoreMessages(_group, lastDate).then (messages) ->
                        expect(messages).toEqual(['message1', 'message2'])
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR', (done) ->
                    httpBackend.expectPOST('/api/messages/getMore', { _group: _group, lastDate: lastDate }).respond(401)
                    MessageService.getMoreMessages(_group, lastDate).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


    describe 'ItemService', ->

        ItemService = undefined

        beforeEach inject (_ItemService_) ->
            ItemService = _ItemService_


        describe 'getInitialItems', ->

            _group = undefined

            beforeEach ->
                _group = 'groupId'

            it 'should POST to /api/items/initialItems', (done) ->
                httpBackend.expectPOST('/api/items/initialItems', { _group: _group }).respond(200)
                ItemService.getInitialItems(_group).then ->
                    done()
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve the items returned', (done) ->
                    httpBackend.expectPOST('/api/items/initialItems', { _group: _group }).respond(200, ['item1', 'item2'])
                    ItemService.getInitialItems(_group).then (items) ->
                        expect(items).toEqual(['item1', 'item2'])
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR', (done) ->
                    httpBackend.expectPOST('/api/items/initialItems', { _group: _group }).respond(401)
                    ItemService.getInitialItems(_group).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


        describe 'updateItemLocation', ->

            _item = undefined
            newX = undefined
            newY = undefined

            beforeEach ->
                _item = 'itemId'
                newX = 5
                newY = 10

            it 'should POST /api/items/updateItemLocation', (done) ->
                httpBackend.expectPOST('/api/items/updateItemLocation', { _item: _item, newX: newX, newY: newY }).respond(200)
                ItemService.updateItemLocation(_item, newX, newY).then ->
                    done()
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve returned', (done) ->
                    httpBackend.expectPOST('/api/items/updateItemLocation', { _item: _item, newX: newX, newY: newY }).respond(200)
                    ItemService.updateItemLocation(_item, newX, newY).then ->
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR', (done) ->
                    httpBackend.expectPOST('/api/items/updateItemLocation', { _item: _item, newX: newX, newY: newY }).respond(401)
                    ItemService.updateItemLocation(_item, newX, newY).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


        describe 'postMessageToWorkspace', ->

            _group = undefined
            message = undefined

            beforeEach ->
                _group = 'groupID'
                message = 'test message'

            it 'should POST to /api/items/text', ->
                httpBackend.expectPOST('/api/items/text', { _group: _group, text: message }).respond(200)
                ItemService.postMessageToWorkspace(_group, message)
                httpBackend.flush()


            describe 'successful', ->

                it 'should resolve when returned', (done) ->
                    httpBackend.expectPOST('/api/items/text', { _group: _group, text: message }).respond(200)
                    ItemService.postMessageToWorkspace(_group, message).then ->
                        done()
                    httpBackend.flush()


            describe 'failed', ->

                it 'should reject with SERVER_ERROR', (done) ->
                    httpBackend.expectPOST('/api/items/text', { _group: _group, text: message }).respond(401)
                    ItemService.postMessageToWorkspace(_group, message).catch (message) ->
                        expect(message).toEqual(Constants.Messages.SERVER_ERROR)
                        done()
                    httpBackend.flush()


    describe 'Socket', ->


        Socket = undefined
        io = undefined

        beforeEach inject (_Socket_) ->
            io = {
                on: (eventName, callback) ->
                    callback('param1', 'param2')
                emit: ->
            }
            window.io = -> io
            Socket = _Socket_

        describe 'setup', ->

            it 'it should call io() to initialize the socket', ->
                spyOn(window, 'io')
                socket = new Socket()
                expect(window.io).toHaveBeenCalled()

        describe 'on', ->

            socket = undefined

            beforeEach ->
                socket = new Socket()

            it 'should apply the params to the callback', ->
                socket.on 'testEvent', (param1, param2) ->
                    expect(param1).toEqual('param1')
                    expect(param2).toEqual('param2')

        describe 'emit', ->

            socket = undefined

            beforeEach ->
                socket = new Socket()

            it 'should emit only a name when given not other params', ->
                spyOn(io, 'emit')
                socket.emit('testEvent')
                expect(io.emit).toHaveBeenCalledWith('testEvent')


            it 'should emit a name and all params when given a name and params', ->
                spyOn(io, 'emit')
                socket.emit('testEvent', 'param1', 'param2', 'param3')
                expect(io.emit).toHaveBeenCalledWith('testEvent', 'param1', 'param2', 'param3')
