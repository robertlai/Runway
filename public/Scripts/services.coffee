angular.module('runwayApp')

.factory 'AuthService', [
    '$q'
    '$timeout'
    '$http'
    (q, $timeout, http) ->
        user = false

        isLoggedIn = ->
            deferred = q.defer()

            if user
                deferred.resolve(true)
            else
                http.post '/isUserLoggedIn'
                    .success (data) ->
                        user = data.loggedIn
                        deferred.resolve(user)
                    .error (data) ->
                        user = false
                        deferred.resolve(user)

            return deferred.promise

        setUser = (userToSet) ->
            user = userToSet

        login = (username, password) ->
            deferred = q.defer()

            http.post '/login', { username: username, password: password }
                .success (data, status) ->
                    if status is 200 and data.status
                        user = true
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
            isLoggedIn: isLoggedIn
            login: login
            logout: logout
            register: register
        }
]
