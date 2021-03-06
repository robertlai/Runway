angular.module('runwayAppConstants', [])

.constant 'Constants', {

    DEFAULT_ROUTE: 'home.groups'

    OWNED_GROUP: 'owned'
    JOINED_GROUP: 'joined'

    DEFAULT_GROUP_COLOUR: '#0099CC'

    SEARCHABILITY: {
        PRIVATE: 'private'
        FRIENDS: 'friends'
        PUBLIC: 'public'
    }

    Messages: {
        SERVER_ERROR: 'Server Error. Please contact support.'

        USERNAME_ALREADY_TAKEN: 'That username is already taken.'
        GROUP_ALREADY_EXISTS: 'This group already exists.'
        NO_OWNED_GROUPS: 'You have no groups. Create one!'
        NO_JOINED_GROUPS: 'You have not been added to any groups.'
        UNSUPPORTED_GROUP_TYPE: 'This group type is unsupported.'
        NO_GROUP_NAME_PROVIDED: 'Please provide a group name.'
        MUST_BE_OWNER_TO_DELETE: 'You must be the owner of a group in order to delete it.'
        MUST_BE_OWNER_TO_REMOVE_MEMBER: 'You must be the owner of a group in order to remove members from it.'
        MEMBER_TRYING_TO_ADD_NOT_FOUND: 'The member you are trying to add cannot be found. Please check your spelling and try again.'
        CONFIRM_GROUP_DELETE_1: '''Are you sure you and to delete this group?
                                   All members will be removed and all content destroyed.
                                   There is no going back!'''
        CONFIRM_GROUP_DELETE_2: 'Last chance. Are you 100% sure you want to do this?'
        NOT_AUTHORIZED: 'You are not authorized to do this. Please log in.'
    }
}
