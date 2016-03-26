require('./routes')
require('./services.coffee')
require('./controllers.coffee')
require('./directives.coffee')
require('./constants.coffee')


#todo: look into moving these deps into other modules (colour,picker may be able to be mooved into runwayAppControllers)
runwayApp = angular.module('runwayApp',
    ['runwayAppRoutes', 'runwayAppControllers', 'runwayAppServices', 'runwayAppConstants'])
