describe 'Constants', ->

    beforeEach(module('runwayAppConstants'))

    Constants = undefined

    beforeEach inject (_Constants_) ->
        Constants = _Constants_

    it 'should have the correct DEFAULT_ROUTE', ->
        expect(Constants.DEFAULT_ROUTE).toEqual('home.groups')

    it 'should have the correct OWNED_GROUP enum', ->
        expect(Constants.OWNED_GROUP).toEqual('owned')

    it 'should have the correct JOINED_GROUP enum', ->
        expect(Constants.JOINED_GROUP).toEqual('joined')

    it 'should have the correct DEFAULT_GROUP_COLOUR', ->
        expect(Constants.DEFAULT_GROUP_COLOUR).toEqual('#0099CC')

    describe 'searchability settings', ->

        it 'should have the correct constant for private', ->
            expect(Constants.SEARCHABILITY.PRIVATE).toEqual('private')

        it 'should have the correct constant for friends', ->
            expect(Constants.SEARCHABILITY.FRIENDS).toEqual('friends')

        it 'should have the correct constant for public', ->
            expect(Constants.SEARCHABILITY.PUBLIC).toEqual('public')

    describe 'Messages', ->

        it 'should have the correct server error', ->
            expect(Constants.Messages.SERVER_ERROR).toEqual('Server Error. Please contact support.')

        it 'should have the correct USERNAME_ALREADY_TAKEN', ->
            expect(Constants.Messages.USERNAME_ALREADY_TAKEN).toEqual('That username is already taken.')

        it 'should have the correct GROUP_ALREADY_EXISTS', ->
            expect(Constants.Messages.GROUP_ALREADY_EXISTS).toEqual('This group already exists.')

        it 'should have the correct NO_OWNED_GROUPS', ->
            expect(Constants.Messages.NO_OWNED_GROUPS).toEqual('You have no groups. Create one!')

        it 'should have the correct NO_JOINED_GROUPS', ->
            expect(Constants.Messages.NO_JOINED_GROUPS).toEqual('You have not been added to any groups.')

        it 'should have the correct UNSUPPORTED_GROUP_TYPE', ->
            expect(Constants.Messages.UNSUPPORTED_GROUP_TYPE).toEqual('This group type is unsupported.')

        it 'should have the correct NO_GROUP_NAME_PROVIDED', ->
            expect(Constants.Messages.NO_GROUP_NAME_PROVIDED).toEqual('Please provide a group name.')

        it 'should have the correct MUST_BE_OWNER_TO_DELETE', ->
            expect(Constants.Messages.MUST_BE_OWNER_TO_DELETE).toEqual('You must be the owner of a group in order to delete it.')

        it 'should have the correct MUST_BE_OWNER_TO_REMOVE_MEMBER', ->
            expect(Constants.Messages.MUST_BE_OWNER_TO_REMOVE_MEMBER).toEqual('You must be the owner of a group in order to remove members from it.')

        it 'should have the correct MEMBER_TRYING_TO_ADD_NOT_FOUND', ->
            expect(Constants.Messages.MEMBER_TRYING_TO_ADD_NOT_FOUND)
                .toEqual('The member you are trying to add cannot be found. Please check your spelling and try again.')

        it 'should have the correct CONFIRM_GROUP_DELETE_1', ->
            expect(Constants.Messages.CONFIRM_GROUP_DELETE_1).toEqual('''Are you sure you and to delete this group?
                                                                        All members will be removed and all content destroyed.
                                                                        There is no going back!''')

        it 'should have the correct CONFIRM_GROUP_DELETE_2', ->
            expect(Constants.Messages.CONFIRM_GROUP_DELETE_2).toEqual('Last chance. Are you 100% sure you want to do this?')

        it 'should have the correct NOT_AUTHORIZED', ->
            expect(Constants.Messages.NOT_AUTHORIZED).toEqual('You are not authorized to do this. Please log in.')
