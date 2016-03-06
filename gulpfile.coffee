gulp = require('gulp')
del = require('del')
browserify = require('gulp-browserify')
coffeelint = require('gulp-coffeelint')
uglify = require('gulp-uglify')
concat = require('gulp-concat')
sass = require('gulp-sass')
autoprefixer = require('gulp-autoprefixer')
csso = require('gulp-csso')
jade = require('gulp-jade')
nodemon = require('gulp-nodemon')


gulp.task 'coffeelint', ->
    gulp.src('./src/scripts/*.coffee')
        .pipe(coffeelint())
        .pipe(coffeelint.reporter())


gulp.task 'clean:scripts', -> del('dist/scripts/scripts.min.js')
gulp.task 'scripts', ['coffeelint', 'clean:scripts'], ->
    outputDir = 'dist/scripts/'
    outputFile = 'scripts.min.js'
    gulp.src('./src/scripts/index.coffee', read: false)
        .pipe(browserify({transform: ['coffeeify'], extensions: ['.coffee']}))
        .pipe(uglify())
        .pipe(concat(outputFile))
        .pipe(gulp.dest(outputDir))


gulp.task 'clean:vendorScripts', -> del('dist/scripts/vendor.min.js')
gulp.task 'vendorScripts', ['clean:vendorScripts'], ->
    outputDir = 'dist/scripts/'
    outputFile = 'vendor.min.js'
    gulp.src('./vendor.coffee', read: false)
        .pipe(browserify({}))
        .pipe(uglify())
        .pipe(concat(outputFile))
        .pipe(gulp.dest(outputDir))


gulp.task 'clean:css', -> del('dist/styles/styles.min.css')
gulp.task 'css', ['clean:css'], ->
    outputDir = 'dist/styles/'
    outputFile = 'styles.min.css'
    gulp.src('src/styles/*.sass')
        .pipe(sass().on('error', sass.logError))
        .pipe(concat(outputFile))
        .pipe(autoprefixer(browsers: ['> 0%']))
        .pipe(csso())
        .pipe(gulp.dest(outputDir))


gulp.task 'clean:vendorCss', -> del('dist/styles/vendor.min.css')
gulp.task 'vendorCss', ['clean:vendorCss'], ->
    outputDir = 'dist/styles/'
    outputFile = 'vendor.min.css'
    gulp.src([
        './node_modules/jquery-ui-bundle/jquery-ui.min.css'
        './node_modules/angularjs-color-picker/dist/angularjs-color-picker.min.css'
        './node_modules/angularjs-color-picker/dist/themes/angularjs-color-picker-bootstrap.min.css'])
        .pipe(concat(outputFile))
        .pipe(csso())
        .pipe(gulp.dest(outputDir))


gulp.task 'clean:jade', -> del('dist/partials')
gulp.task 'jade', ['clean:jade'], ->
    outputDir = 'dist/partials'
    gulp.src('views/partials/*.jade')
        .pipe(jade())
        .pipe(gulp.dest(outputDir))


gulp.task 'clean:images', -> del('dist/images')
gulp.task 'images', ['clean:images'], ->
    outputDir = 'dist/images'
    gulp.src(['./src/images/**/*.*'])
        .pipe(gulp.dest(outputDir))

# todo: cleanup all paths

allTasks = ['vendorCss', 'css', 'vendorScripts', 'scripts', 'jade', 'images']

gulp.task 'dev', allTasks, ->
    gulp.watch('./src/scripts/*.coffee', ['scripts'])
    gulp.watch(['./vendor.coffee', './package.json'], ['vendorScripts', 'vendorCss'])
    gulp.watch(['./package.json', './src/styles/*.sass'], ['css'])
    gulp.watch('views/partials/*.jade', ['jade'])
    gulp.watch('./src/images/**/*.*', ['images'])
    nodemon({
        script: 'server.coffee'
    })

gulp.task 'release', allTasks
