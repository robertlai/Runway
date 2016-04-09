angular.module('runwayAppServices', ['runwayAppConstants'])

.service 'AuthService', [
    '$q'
    '$http'
    class AuthService
        constructor: (@q, @http) -> @user = null

        getUser: =>
            deferred = @q.defer()

            if @user
                deferred.resolve(@user)
            else
                @http.post '/getUserStatus'
                    .success (data) =>
                        if data.loggedIn
                            @user = data.user
                            deferred.resolve(@user)
                        else
                            @user = null
                            deferred.reject()
                    .error (data) =>
                        @user = null
                        deferred.reject()

            return deferred.promise

        login: (username, password) =>
            deferred = @q.defer()

            @http.post '/login', { username: username, password: password }
                .success (data, status) =>
                    if status is 200
                        @user = data.user
                        deferred.resolve()
                    else
                        @user = null
                        deferred.reject(data.error)
                .error (data) =>
                    @user = null
                    deferred.reject(data.error)

            return deferred.promise

        logout: =>
            deferred = @q.defer()
            @http.get '/logout'
                .success (data) =>
                    @user = null
                    deferred.resolve()
                .error (data) =>
                    @user = null
                    deferred.reject()

            return deferred.promise

        register: (registerForm) =>
            deferred = @q.defer()

            @http.post '/register', registerForm
                .success (data, status) ->
                    if status is 200
                        deferred.resolve()
                    else
                        deferred.reject(data.error)
                .error (data) ->
                    deferred.reject(data.error)

            return deferred.promise

]

.service 'GroupService', [
    '$http'
    '$q'
    'Constants'
    class GroupService
        constructor: (@http, @q, @Constants) ->

        getGroups: (groupType) =>
            deferred = @q.defer()

            @http.get('/api/groups/' + groupType)
                .success (groups) =>
                    if groups.length > 0
                        deferred.resolve(groups)
                    else
                        if groupType is @Constants.OWNED_GROUP
                            deferred.reject(@Constants.Messages.NO_OWNED_GROUPS)
                        else if groupType is @Constants.JOINED_GROUP
                            deferred.reject(@Constants.Messages.NO_JOINED_GROUPS)
                        else
                            deferred.reject(@Constants.Messages.UNSUPPORTED_GROUP_TYPE)

                .error =>
                    deferred.reject(@Constants.Messages.SERVER_ERROR)

            return deferred.promise

        addGroup: (newGroup) =>
            deferred = @q.defer()

            if newGroup and newGroup.name.trim().length > 0
                @http.post('/api/groups/new', newGroup)
                    .success (addedGroup) ->
                        deferred.resolve(addedGroup)
                    .error (error, status) =>
                        if status is 409
                            deferred.reject(@Constants.Messages.GROUP_ALREADY_EXISTS)
                        else
                            deferred.reject(@Constants.Messages.SERVER_ERROR)
            else
                deferred.reject(@Constants.Messages.NO_GROUP_NAME_PROVIDED)

            return deferred.promise

        editGroup: (groupToEdit) =>
            deferred = @q.defer()

            if groupToEdit and groupToEdit.name.trim().length > 0
                @http.post('/api/groups/edit', groupToEdit)
                    .success (newProperties) ->
                        deferred.resolve(newProperties)
                    .error (error, status) =>
                        if status is 409
                            deferred.reject(@Constants.Messages.GROUP_ALREADY_EXISTS)
                        else
                            deferred.reject(@Constants.Messages.SERVER_ERROR)
            else
                deferred.reject(@Constants.Messages.NO_GROUP_NAME_PROVIDED)

            return deferred.promise

        deleteGroup: (groupToDelete) =>
            deferred = @q.defer()

            @http.post('/api/groups/delete', groupToDelete)
                .success ->
                    deferred.resolve()
                .error (error, status) =>
                    if status is 403
                        deferred.reject(@Constants.Messages.MUST_BE_OWNER_TO_DELETE)
                    else
                        deferred.reject(@Constants.Messages.SERVER_ERROR)

            return deferred.promise

        addMember: (_group, memberToAdd) =>
            deferred = @q.defer()

            @http.post('/api/groups/addMember', { _group: _group, memberToAdd: memberToAdd })
                .success ->
                    deferred.resolve()
                .error (error, status) =>
                    if status is 409
                        deferred.reject(@Constants.Messages.USER_ALREADY_IN_GROUP)
                    else
                        deferred.reject(@Constants.Messages.SERVER_ERROR)

            return deferred.promise

]

.service 'UserService', [
    '$http'
    '$q'
    'Constants'
    class UserService
        constructor: (@http, @q, @Constants) ->

        findUsers: (query) =>
            deferred = @q.defer()

            @http.post('/api/users/find', { query: query })
                .success (members) ->
                    deferred.resolve(members)
                .error =>
                    deferred.reject(@Constants.Messages.SERVER_ERROR)

            return deferred.promise

        updateGeneralSettings: (user) =>
            deferred = @q.defer()

            @http.post('/api/users/updateGeneralSettings', user)
                .success ->
                    deferred.resolve()
                .error =>
                    deferred.reject(@Constants.Messages.SERVER_ERROR)

            return deferred.promise

        saveUserSettings: (user) =>
            deferred = @q.defer()

            @http.post('/api/users/updateUserSettings', user)
                .success ->
                    deferred.resolve()
                .error =>
                    deferred.reject(@Constants.Messages.SERVER_ERROR)

            return deferred.promise

]

.service 'MessageService', [
    '$http'
    '$q'
    'Constants'
    class MessageService
        constructor: (@http, @q, @Constants) ->

        addNewMessageToChat: (_group, messageContent) =>
            deferred = @q.defer()

            @http.post('/api/messages/new', { _group: _group, messageContent: messageContent })
                .success ->
                    deferred.resolve()
                .error =>
                    deferred.reject(@Constants.Messages.SERVER_ERROR)

            return deferred.promise

        removeMessage: (_message) =>
            deferred = @q.defer()

            @http.post('/api/messages/delete', { _message: _message })
                .success ->
                    deferred.resolve()
                .error =>
                    deferred.reject(@Constants.Messages.SERVER_ERROR)

            return deferred.promise

        getInitialMessages: (_group) =>
            deferred = @q.defer()

            @http.post('/api/messages/getInitial', { _group: _group })
                .success (messages) ->
                    deferred.resolve(messages)
                .error =>
                    deferred.reject(@Constants.Messages.SERVER_ERROR)

            return deferred.promise

        getMoreMessages: (_group, lastDate) =>
            deferred = @q.defer()

            @http.post('/api/messages/getMore', { _group: _group, lastDate: lastDate })
                .success (messages) ->
                    deferred.resolve(messages)
                .error =>
                    deferred.reject(@Constants.Messages.SERVER_ERROR)

            return deferred.promise

]

.service 'ItemService', [
    '$http'
    '$q'
    'Constants'
    class ItemService
        constructor: (@http, @q, @Constants) ->

        getInitialItems: (_group) =>
            deferred = @q.defer()

            @http.post('/api/items/initialItems', { _group: _group })
                .success (items) ->
                    deferred.resolve(items)
                .error =>
                    deferred.reject(@Constants.Messages.SERVER_ERROR)

            return deferred.promise

        updateItemLocation: (_item, newX, newY) =>
            deferred = @q.defer()

            @http.post('/api/items/updateItemLocation', { _item: _item, newX: newX, newY: newY })
                .success ->
                    deferred.resolve()
                .error =>
                    deferred.reject(@Constants.Messages.SERVER_ERROR)

            return deferred.promise

        postMessageToWorkspace: (_group, message) =>
            deferred = @q.defer()

            @http.post('/api/items/text', { _group: _group, text: message })
                .success ->
                    deferred.resolve()
                .error =>
                    deferred.reject(@Constants.Messages.SERVER_ERROR)

            return deferred.promise

]

.service 'Socket', ->
    class Socket
        constructor: ->
            @socket = io()

        on: (eventName, callback) =>
            @socket.on eventName, =>
                callback.apply(@socket, arguments)

        emit: (eventName, data...) =>
            @socket.emit(eventName, data...)
