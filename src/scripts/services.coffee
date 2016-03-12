angular.module('runwayAppServices', ['runwayAppConstants'])

.factory 'AuthService', [
    '$q'
    '$http'
    (q, http) ->
        user = null

        getUser = -> user

        loggedIn = ->
            deferred = q.defer()

            http.post '/getUserStatus'
                .success (data) ->
                    loggedIn = data.loggedIn
                    if loggedIn
                        user = data.user
                        deferred.resolve()
                    else
                        user = null
                        deferred.reject()
                .error (data) ->
                    user = null
                    deferred.reject()

            return deferred.promise

        login = (username, password) ->
            deferred = q.defer()

            http.post '/login', { username: username, password: password }
                .success (data, status) ->
                    if status is 200 and data.status
                        user = data.user
                        deferred.resolve()
                    else
                        user = null
                        deferred.reject(data.error)
                .error (data) ->
                    user = null
                    deferred.reject(data.error)

            return deferred.promise

        logout = ->
            deferred = q.defer()
            http.get '/logout'
                .success (data) ->
                    user = null
                    deferred.resolve()
                .error (data) ->
                    user = null
                    deferred.reject()

            return deferred.promise

        register = (registerForm) ->
            deferred = q.defer()

            http.post '/register', registerForm
                .success (data, status) ->
                    if status is 200 and data.status
                        deferred.resolve()
                    else
                        deferred.reject(data.error)
                .error (data) ->
                    deferred.reject(data.error)

            return deferred.promise

        {
            getUser: getUser
            loggedIn: loggedIn
            login: login
            logout: logout
            register: register
        }
]


.factory 'groupService', [
    '$http'
    '$q'
    'Constants'
    (http, q, Constants) ->

        getGroups = (groupType) ->
            deferred = q.defer()

            http.get('/api/groups/' + groupType)
                .success (groups) ->
                    if groups.length > 0
                        deferred.resolve(groups)
                    else
                        if groupType is Constants.OWNED_GROUP
                            deferred.reject(Constants.Messages.NO_OWNED_GROUPS)
                        else if groupType is Constants.JOINED_GROUP
                            deferred.reject(Constants.Messages.NO_JOINED_GROUPS)

                .error (error) ->
                    deferred.reject(Constants.Messages.SERVER_ERROR)

            return deferred.promise

        addGroup = (newGroup) ->
            deferred = q.defer()

            if newGroup and newGroup.name.trim().length > 0
                http.post('/api/newGroup', newGroup)
                    .success (addedGroup) ->
                        deferred.resolve(addedGroup)
                    .error (error, status) ->
                        if status is 409
                            deferred.reject(Constants.Messages.GROUP_ALREADY_EXISTS)
                        else
                            deferred.reject(Constants.Messages.SERVER_ERROR)
            else
                deferred.reject(Constants.Messages.NO_GROUP_NAME_PROVIDED)

            return deferred.promise

        editGroup = (groupToEdit) ->
            deferred = q.defer()

            if groupToEdit and groupToEdit.name.trim().length > 0
                http.post('/api/editGroup', groupToEdit)
                    .success (editedGroup) ->
                        deferred.resolve(editedGroup)
                    .error (error, status) ->
                        if status is 409
                            deferred.reject(Constants.Messages.GROUP_ALREADY_EXISTS)
                        else
                            deferred.reject(Constants.Messages.SERVER_ERROR)
            else
                deferred.reject(Constants.Messages.NO_GROUP_NAME_PROVIDED)

            return deferred.promise

        addMember = (_group, memberToAdd) ->
            deferred = q.defer()

            http.post('/api/addGroupMember', {_group: _group, memberToAdd: memberToAdd})
                .success ->
                    deferred.resolve()
                .error (error, status) ->
                    if status is 409
                        deferred.reject(Constants.Messages.USER_ALREADY_IN_GROUP)
                    else
                        deferred.reject(Constants.Messages.SERVER_ERROR)

            return deferred.promise

        deleteGroup = (groupToDelete) ->
            deferred = q.defer()

            http.post('/api/deleteGroup', groupToDelete)
                .success ->
                    deferred.resolve()
                .error (error, status) ->
                    if status is 401
                        deferred.reject(Constants.Messages.MUST_BE_OWNER_TO_DELETE)
                    else
                        deferred.reject(Constants.Messages.SERVER_ERROR)

            return deferred.promise

        {
            getGroups: getGroups
            addGroup: addGroup
            editGroup: editGroup
            addMember: addMember
            deleteGroup: deleteGroup
        }
]


.factory 'userService', [
    '$http'
    '$q'
    'Constants'
    (http, q, Constants) ->

        getUsers = (query) ->
            deferred = q.defer()

            http.post('/api/getUsers', {query: query})
                .success (members) ->
                    deferred.resolve(members)
                .error (error) ->
                    deferred.reject(Constants.Messages.SERVER_ERROR)

            return deferred.promise

        {
            getUsers: getUsers
        }
]