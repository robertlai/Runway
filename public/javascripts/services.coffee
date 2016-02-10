angular.module('myApp').factory 'AuthService', [
    '$q'
    '$timeout'
    '$http'
    (q, $timeout, http) ->
        user = null

        isLoggedIn = ->
            if user then true else false

        login = (username, password) ->
            deferred = q.defer()
            http.post '/login',
                username: username
                password: password
            .success (data, status) ->
                if status == 200 and data.status
                    user = true
                    deferred.resolve()
                else
                    user = false
                    deferred.reject()
            .error (data) ->
                user = false
                deferred.reject()
            deferred.promise

        logout = ->
            deferred = q.defer()
            http.get '/logout'
            .success (data) ->
                user = false
                deferred.resolve()
            .error (data) ->
                user = false
                deferred.reject()
                return
            # return promise object
            deferred.promise

        register = (username, password) ->
            # create a new instance of deferred
            deferred = q.defer()
            # send a post request to the server
            http.post '/register',
                username: username
                password: password
            .success (data, status) ->
                if status == 200 and data.status
                    deferred.resolve()
                else
                    deferred.reject()
                return
            .error (data) ->
                deferred.reject()
                return
            # return promise object
            deferred.promise

        return {
            isLoggedIn: isLoggedIn
            login: login
            logout: logout
            register: register
        }
]

