angular.module('runwayApp')

.service 'AuthService', [
    '$q'
    '$http'
    (q, http) ->
        user = null

        getUser = -> user

        isLoggedIn = ->
            deferred = q.defer()

            if user
                deferred.resolve(true)
            else
                http.post '/getUserStatus'
                    .success (data) ->
                        loggedIn = data.loggedIn
                        if loggedIn
                            user = {
                                username: data.user.username
                            }
                        else
                            user = false
                        deferred.resolve(data.loggedIn)
                    .error (data) ->
                        user = false
                        deferred.resolve(user)

            return deferred.promise

        login = (username, password) ->
            deferred = q.defer()

            http.post '/login', { username: username, password: password }
                .success (data, status) ->
                    if status is 200 and data.status
                        user = {
                            username: data.user.username
                        }
                        deferred.resolve()
                    else
                        user = false
                        deferred.reject(data.error)
                .error (data) ->
                    user = false
                    deferred.reject(data.error)

            return deferred.promise

        logout = ->
            deferred = q.defer()
            http.get '/logout'
                .success (data) ->
                    user = false
                    deferred.resolve()
                .error (data) ->
                    user = false
                    deferred.reject()

            return deferred.promise

        register = (username, password) ->
            deferred = q.defer()

            http.post '/register', { username: username, password: password }
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
            isLoggedIn: isLoggedIn
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

        addGroup = (newGroupName) ->
            deferred = q.defer()

            if newGroupName and newGroupName.trim().length > 0
                if newGroupName.match(/[^A-Za-z0-9\-_ ]/)
                    deferred.reject('This group contains invalid characters.')
                else
                    http.post('/api/newGroup?newGroupName=' + newGroupName)
                        .success (addedGroup) ->
                            deferred.resolve(newGroupName)
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
        }
]
