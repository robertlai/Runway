require('./routes')
require('./services.coffee')
require('./controllers.coffee')
require('./directives.coffee')
require('./constants.coffee')

runwayApp = angular.module('runwayApp',
    ['runwayAppRoutes', 'runwayAppControllers', 'runwayAppServices', 'runwayAppConstants'])
