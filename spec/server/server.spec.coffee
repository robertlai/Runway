require('coffee-script').register()

# expect = require('chai').expect

mongoose = require('mongoose')
supertest = require('supertest')

dbAddress = require('../../dbcredentials.json').unitTestAddress
process.env.PORT = 7468
process.env.dbAddress = dbAddress

mongoose.createConnection(dbAddress)
mongoose.models = {}
mongoose.modelSchemas = {}

app = require('../../app')
User = require('../../models/User')

describe 'test', ->

    userAgent = supertest.agent(app)

    beforeEach (done) ->
        User.remove {}, ->
            newUser = new User {
                firstName: 'testFirstName'
                lastName: 'testLastName'
                email: 'testingUser@testEmail.com'
                username: 'testingUser'
            }
            newUser.password = newUser.generateHash('testingPassword')
            newUser.save (err) ->
                userAgent
                    .post('/login')
                    .send({ username: 'testingUser', password: 'testingPassword' })
                    .end ->
                        done()


    it 'should do it', (done) ->
        userAgent
            .post('/api/users/find')
            .send({ query: 'test' })
            .end (err, res) ->
                done()

after ->
    app.close()
    mongoose.disconnect()
