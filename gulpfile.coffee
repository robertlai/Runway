gulp = require('gulp')
del = require('del')
browserify = require('gulp-browserify')
coffeelint = require('gulp-coffeelint')
uglify = require('gulp-uglify')
concat = require('gulp-concat')
sass = require('gulp-sass')
autoprefixer = require('gulp-autoprefixer')
csso = require('gulp-csso')
nodemon = require('gulp-nodemon')


gulp.task 'coffeelint', ->
    gulp.src('./client/scripts/*.coffee')
        .pipe(coffeelint())
        .pipe(coffeelint.reporter())

gulp.task 'clean:scripts', -> del('public/scripts/scripts.min.js')
gulp.task 'scripts', ['coffeelint', 'clean:scripts'], ->
    outputDir = 'public/scripts/'
    outputFile = 'scripts.min.js'
    gulp.src('./client/scripts/index.coffee', read: false)
        .pipe(browserify({transform: ['coffeeify'], extensions: ['.coffee']}))
        .pipe(uglify())
        .pipe(concat(outputFile))
        .pipe(gulp.dest(outputDir))


gulp.task 'clean:vendorScripts', -> del('public/scripts/vendor.min.js')
gulp.task 'vendorScripts', ['clean:vendorScripts'], ->
    outputDir = 'public/scripts/'
    outputFile = 'vendor.min.js'
    gulp.src('./vendor.coffee', read: false)
        .pipe(browserify({}))
        .pipe(uglify())
        .pipe(concat(outputFile))
        .pipe(gulp.dest(outputDir))


gulp.task 'clean:css', -> del('public/styles/styles.min.css')
gulp.task 'css', ['clean:css'], ->
    outputDir = 'public/styles/'
    outputFile = 'styles.min.css'
    gulp.src('client/styles/*.sass')
        .pipe(sass().on('error', sass.logError))
        .pipe(concat(outputFile))
        .pipe(autoprefixer(browsers: ['> 0%']))
        .pipe(csso())
        .pipe(gulp.dest(outputDir))


gulp.task 'clean:vendorCss', -> del('public/styles/vendor.min.css')
gulp.task 'vendorCss', ['clean:vendorCss'], ->
    outputDir = 'public/styles/'
    outputFile = 'vendor.min.css'
    gulp.src([
        './node_modules/jquery-ui-bundle/jquery-ui.min.css'
        './node_modules/angularjs-color-picker/dist/angularjs-color-picker.min.css'
        './node_modules/angularjs-color-picker/dist/themes/angularjs-color-picker-bootstrap.min.css'])
        .pipe(concat(outputFile))
        .pipe(csso())
        .pipe(gulp.dest(outputDir))


gulp.task 'watch', ->
    gulp.watch('./client/scripts/*.coffee', ['scripts'])
    gulp.watch(['./vendor.coffee', './package.json'], ['vendorScripts', 'vendorCss'])
    gulp.watch(['./package.json', './client/styles/*.sass'], ['css'])


gulp.task 'start', ->
    nodemon({
        script: 'server.coffee'
    })


gulp.task 'default', [
    'watch'
    'vendorCss'
    'vendorScripts'
    'css'
    'scripts'
    'start'
]
