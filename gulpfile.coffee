gulp = require('gulp')
path = require('path')
del = require('del')
browserify = require('browserify')
source = require('vinyl-source-stream')
buffer = require('vinyl-buffer')
coffeelint = require('gulp-coffeelint')
uglify = require('gulp-uglify')
concat = require('gulp-concat')
sass = require('gulp-sass')
autoprefixer = require('gulp-autoprefixer')
csso = require('gulp-csso')
jade = require('gulp-jade')
nodemon = require('gulp-nodemon')
mocha = require('gulp-mocha')
Server = require('karma').Server


allCoffeeSrc = path.join('src', 'scripts', '*.coffee')
clientScriptsSrcFile = path.join('src', 'scripts', 'app.coffee')
scriptsDestPath = path.join('dist', 'scripts')
clientScriptsMinDestFile = 'client.min.js'
clientScriptsNonMinDestFile = 'client.js'

vendorScriptsSrcFile = 'vendor.coffee'
vendorScriptsDestFile = 'vendor.min.js'

clientStylesSrcPath = path.join('src', 'styles', '*.sass')
stylesDestPath = path.join('dist', 'styles')
clientStylesDestFile = 'client.min.css'

vendorStylesSrcPaths = ['node_modules/jquery-ui-bundle/jquery-ui.min.css'
    'node_modules/angularjs-color-picker/dist/angularjs-color-picker.min.css'
    'node_modules/angularjs-color-picker/dist/themes/angularjs-color-picker-bootstrap.min.css']
vendorStylesDestFile = 'vendor.min.css'

jadeSrcPath = path.join('views', 'partials', '*.jade')
partialsDestPath = path.join('dist', 'partials')

imagesSrcPath = path.join('src', 'images', '*.*')
imagesDestPath = path.join('dist', 'images')


passportSrcPath = './passport.coffee'
appSrcPath = './app.coffee'
socketManagerSrcPath = './socketManager.coffee'
modelsSrcPath = './models/**/*.coffee'
routesSrcPath = './routes/**/*.coffee'
serverSpecSrc = './spec/server/**/*.spec.coffee'

karmaConfSrcFile = path.join(__dirname, 'karma.conf.coffee')


gulp.task 'coffeelint', ->
    gulp.src(allCoffeeSrc)
        .pipe(coffeelint())
        .pipe(coffeelint.reporter())


gulp.task 'clean:clientScripts', ->
    del(scriptsDestPath + clientScriptsMinDestFile)
    del(scriptsDestPath + clientScriptsNonMinDestFile)
gulp.task 'clientScripts', ['coffeelint', 'clean:clientScripts'], ->
    browserify(clientScriptsSrcFile, { transform: ['coffeeify'], extensions: ['.coffee'] })
        .bundle()
        .on 'error', (error) -> @emit('end')
        .pipe(source(clientScriptsNonMinDestFile))
        .pipe(gulp.dest(scriptsDestPath))
        .pipe(buffer())
        .pipe(uglify())
        .pipe(concat(clientScriptsMinDestFile))
        .pipe(gulp.dest(scriptsDestPath))

# todo: add sourcemaps
gulp.task 'clean:vendorScripts', -> del(scriptsDestPath + vendorScriptsDestFile)
gulp.task 'vendorScripts', ['clean:vendorScripts'], ->
    browserify(vendorScriptsSrcFile)
        .bundle()
        .on 'error', (error) -> @emit('end')
        .pipe(source(vendorScriptsDestFile))
        .pipe(buffer())
        .pipe(uglify())
        .pipe(gulp.dest(scriptsDestPath))


gulp.task 'clean:clientCss', -> del(stylesDestPath + clientStylesDestFile)
gulp.task 'clientCss', ['clean:clientCss'], ->
    gulp.src(clientStylesSrcPath)
        .pipe(sass().on('error', sass.logError))
        .pipe(concat(clientStylesDestFile))
        .pipe(autoprefixer(browsers: ['> 0%']))
        .pipe(csso())
        .pipe(gulp.dest(stylesDestPath))


gulp.task 'clean:vendorCss', -> del(stylesDestPath + vendorStylesDestFile)
gulp.task 'vendorCss', ['clean:vendorCss'], ->
    gulp.src(vendorStylesSrcPaths)
        .pipe(concat(vendorStylesDestFile))
        .pipe(csso())
        .pipe(gulp.dest(stylesDestPath))


gulp.task 'clean:jade', -> del(partialsDestPath)
gulp.task 'jade', ['clean:jade'], ->
    gulp.src(jadeSrcPath)
        .pipe(jade())
        .pipe(gulp.dest(partialsDestPath))


gulp.task 'clean:images', -> del(imagesDestPath)
gulp.task 'images', ['clean:images'], ->
    gulp.src(imagesSrcPath)
        .pipe(gulp.dest(imagesDestPath))


allBuildTasks = ['vendorCss', 'clientCss', 'vendorScripts', 'clientScripts', 'jade', 'images']


gulp.task 'dev', allBuildTasks, ->
    gulp.watch(allCoffeeSrc, ['clientScripts'])
    gulp.watch([vendorScriptsSrcFile, 'package.json'], ['vendorScripts', 'vendorCss'])
    gulp.watch(['package.json', clientStylesSrcPath], ['clientCss'])
    gulp.watch(jadeSrcPath, ['jade'])
    gulp.watch(imagesSrcPath, ['images'])
    nodemon({
        script: 'server.coffee'
    })


gulp.task 'release', allBuildTasks


# test
gulp.task 'test:server', ->
    gulp.src(serverSpecSrc)
        .pipe(mocha({ reporter: 'nyan' }))

gulp.task 'test', ['test:server'], ->
    new Server({ configFile: karmaConfSrcFile }).start()
    gulp.watch([passportSrcPath, appSrcPath, socketManagerSrcPath, modelsSrcPath, routesSrcPath, serverSpecSrc], ['test:server'])
