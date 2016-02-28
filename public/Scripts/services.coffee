angular.module('runwayApp')

.service 'AuthService', [
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

        loggedIn()
        {
            getUser: getUser
            loggedIn: loggedIn
            login: login
            logout: logout
            register: register
        }
]


.service 'groupService', [
    '$http'
    '$q'
    (http, q) ->

        getGroups = (groupType) ->
            deferred = q.defer()

            http.get('/api/groups/' + groupType)
                .success (groups) ->
                    if groups.length > 0
                        deferred.resolve(groups)
                    else
                        if groupType is 'owned'
                            deferred.reject('You have no groups. Create one!')
                        else if groupType is 'joined'
                            deferred.reject('You have not been added to any groups.')

                .error (error) ->
                    deferred.reject('Server Error.  Please contact support.')

            return deferred.promise

        addGroup = (newGroup) ->
            deferred = q.defer()

            if newGroup and newGroup.name.trim().length > 0
                http.post('/api/newGroup', newGroup)
                    .success (addedGroup) ->
                        deferred.resolve(addedGroup)
                    .error (error, status) ->
                        if status is 409
                            deferred.reject('This group already exists.')
                        else
                            deferred.reject('Server Error.  Please contact support.')
            else
                deferred.reject('Please provide a group name.')

            return deferred.promise

        editGroup = (groupToEdit) ->
            deferred = q.defer()

            if groupToEdit and groupToEdit.name.trim().length > 0
                http.post('/api/editGroup', groupToEdit)
                    .success (editedGroup) ->
                        deferred.resolve(editedGroup)
                    .error (error, status) ->
                        if status is 409
                            deferred.reject('This group already exists.')
                        else
                            deferred.reject('Server Error.  Please contact support.')
            else
                deferred.reject('Please provide a group name.')

            return deferred.promise

        {
            getGroups: getGroups
            addGroup: addGroup
            editGroup: editGroup
        }
]
