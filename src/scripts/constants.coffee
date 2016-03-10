angular.module('runwayAppConstants', [])

.constant 'Constants', {

    DEFAULT_ROUTE: 'home.groups'

    # todo: test that these match other constants file
    OWNED_GROUP: 'owned'
    JOINED_GROUP: 'joined'

    DEFAULT_GROUP_COLOUR: '#0099CC'

    Messages: {
        SERVER_ERROR: 'Server Error.  Please contact support.'

        GROUP_ALREADY_EXISTS: 'This group already exists.'
        NO_OWNED_GROUPS: 'You have no groups. Create one!'
        NO_JOINED_GROUPS: 'You have not been added to any groups.'
        NO_GROUP_NAME_PROVIDED: 'Please provide a group name.'
        USER_ALREADY_IN_GROUP: 'This user has already been added to this group.'
        MUST_BE_OWNER_TO_DELETE: 'You must be the owner of a group in order to delte it.'
        CONFIRM_GROUP_DELETE_1: '''Are you sure you and to delete this group?
                                   All members will be removed and all content destroyed.
                                   There is no going back!'''
        CONFIRM_GROUP_DELETE_2: 'Last chance.  Are you 100% sure you want to do this?'
    }
}
