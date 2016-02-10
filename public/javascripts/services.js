// Generated by CoffeeScript 1.10.0
angular.module('myApp').factory('AuthService', [
  '$q', '$timeout', '$http', function(q, $timeout, http) {
    var isLoggedIn, login, logout, register, user;
    user = null;
    isLoggedIn = function() {
      if (user) {
        return true;
      } else {
        return false;
      }
    };
    login = function(username, password) {
      var deferred;
      deferred = q.defer();
      http.post('/login', {
        username: username,
        password: password
      }).success(function(data, status) {
        if (status === 200 && data.status) {
          user = true;
          return deferred.resolve();
        } else {
          user = false;
          return deferred.reject();
        }
      }).error(function(data) {
        user = false;
        return deferred.reject();
      });
      return deferred.promise;
    };
    logout = function() {
      var deferred;
      deferred = q.defer();
      http.get('/logout').success(function(data) {
        user = false;
        return deferred.resolve();
      }).error(function(data) {
        user = false;
        deferred.reject();
      });
      return deferred.promise;
    };
    register = function(username, password) {
      var deferred;
      deferred = q.defer();
      http.post('/register', {
        username: username,
        password: password
      }).success(function(data, status) {
        if (status === 200 && data.status) {
          deferred.resolve();
        } else {
          deferred.reject();
        }
      }).error(function(data) {
        deferred.reject();
      });
      return deferred.promise;
    };
    return {
      isLoggedIn: isLoggedIn,
      login: login,
      logout: logout,
      register: register
    };
  }
]);
