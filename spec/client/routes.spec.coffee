# describe 'Services', ->

#     beforeEach(module('runwayAppServices'))

#     Constants = undefined
#     resolvedPromiseFunc = undefined
#     rejectedPromiseFunc = undefined
#     $rootScope = undefined
#     httpBackend = undefined


#     beforeEach inject ($q, _Constants_, _$rootScope_, _$httpBackend_) ->
#         Constants = _Constants_
#         $rootScope = _$rootScope_
#         httpBackend = _$httpBackend_

#         resolvedPromiseFunc = (value) ->
#             deferred = $q.defer()
#             deferred.resolve(value)
#             deferred.promise

#         rejectedPromiseFunc = (value) ->
#             deferred = $q.defer()
#             deferred.reject(value)
#             deferred.promise
