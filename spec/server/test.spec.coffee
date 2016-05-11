require('coffee-script').register()

chai = require('chai')
expect = chai.expect
should = chai.should()
sinon = require('sinon')
chai.use(require('sinon-chai'))

UserRepo = require('../../data/UserRepo')
GroupRepo = require('../../data/GroupRepo')

groupsApiHandler = require('../../handlers/groupsApiHandler')

stubs = undefined

beforeEach ->
    stubs = sinon.collection

afterEach ->
    stubs.restore()

describe 'groupsApiHandler', ->

    describe 'getGroups', ->

        describe 'with the groupType param not in the allowed GROUP_TYPES', ->

            it 'should call next with 404', ->
                req =
                    params:
                        groupType: 'not in GROUP_TYPES'
                next = sinon.spy()
                groupsApiHandler.getGroups(req, undefined, next)

                next.should.have.been.calledWith(404)

        describe 'with the groupType param in the allowed GROUP_TYPES', ->

            it 'should call UserRepo.getGroupsOfTypeFromUserWithId with the user id and the groupType field', ->
                req =
                    params:
                        groupType: 'owned'
                    user:
                        _id: 1234
                stubs.stub(UserRepo, 'getGroupsOfTypeFromUserWithId')
                groupsApiHandler.getGroups(req, undefined, undefined)
                UserRepo.getGroupsOfTypeFromUserWithId.should.have.been.calledWith(1234, '_ownedGroups', sinon.match.func)

            it 'should call next with an eror if UserRepo.getGroupsOfTypeFromUserWithId returns an error', ->
                req =
                    params:
                        groupType: 'owned'
                    user:
                        _id: 1234
                next = sinon.spy()
                stubs.stub UserRepo, 'getGroupsOfTypeFromUserWithId', (_user, groupField, callback) ->
                    callback('test error message')
                groupsApiHandler.getGroups(req, undefined, next)

                next.should.have.been.calledWith('test error message')

            it 'should call GroupRepo.populateGroupMembersDisplayInfo with the requestedGroups if there are no errors', ->
                req =
                    params:
                        groupType: 'owned'
                    user:
                        _id: 1234
                user =
                    _ownedGroups: ['group1', 'group2', 'group3']
                stubs.stub UserRepo, 'getGroupsOfTypeFromUserWithId', (_user, groupField, callback) ->
                    callback(null, user)
                stubs.stub(GroupRepo, 'populateGroupMembersDisplayInfo')
                groupsApiHandler.getGroups(req, undefined, undefined)

                GroupRepo.populateGroupMembersDisplayInfo.should.have.been.calledWith(user._ownedGroups, sinon.match.func)

            it 'should call next with an eror if GroupRepo.populateGroupMembersDisplayInfo returns an error', ->
                req =
                    params:
                        groupType: 'owned'
                    user:
                        _id: 1234
                next = sinon.spy()
                user =
                    _ownedGroups: ['group1', 'group2', 'group3']
                stubs.stub UserRepo, 'getGroupsOfTypeFromUserWithId', (_user, groupField, callback) ->
                    callback(null, user)
                stubs.stub GroupRepo, 'populateGroupMembersDisplayInfo', (groups, callback) ->
                    callback('test error message')
                groupsApiHandler.getGroups(req, undefined, next)

                next.should.have.been.calledWith('test error message')

            it 'should return a json response with the populated groups if there are no errors', ->
                req =
                    params:
                        groupType: 'owned'
                    user:
                        _id: 1234
                res =
                    json: sinon.stub()
                next = sinon.spy()
                user =
                    _ownedGroups: ['group1', 'group2', 'group3']
                populatedGroups = ['pop1', 'pop2', 'pop3']
                stubs.stub UserRepo, 'getGroupsOfTypeFromUserWithId', (_user, groupField, callback) ->
                    callback(null, user)
                stubs.stub GroupRepo, 'populateGroupMembersDisplayInfo', (groups, callback) ->
                    callback(null, populatedGroups)
                groupsApiHandler.getGroups(req, res, undefined)

                res.json.should.have.been.calledWith(populatedGroups)

    # describe 'addNewGroup', ->

    # describe 'editGroup', ->

    # describe 'deleteGroup', ->

    # describe 'addMemberToGroup', ->

    # describe 'removeMemberFromGroup', ->



    # it 'should', ->
    #     expect(true).to.equal(true)
