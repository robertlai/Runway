gulp = require('gulp')
del = require('del')
browserify = require('gulp-browserify')
concat = require('gulp-concat')
uglify = require('gulp-uglify')
nodemon = require('gulp-nodemon')

paths =
    scripts: 'public/scripts/*.coffee'

clean = (outputDir, outputFile) ->
    del([outputDir + outputFile])

gulp.task 'scripts', ->
    outputDir = 'public/scripts/'
    outputFile = 'index.min.js'
    clean(outputDir, outputFile)
    gulp.src('./client/scripts/index.coffee', read: false)
        .pipe(browserify({transform: ['coffeeify'], extensions: ['.coffee']}))
        .pipe(uglify())
        .pipe(concat(outputFile))
        .pipe(gulp.dest(outputDir))

gulp.task 'vendor', ->
    outputDir = 'public/scripts/'
    outputFile = 'vendor.min.js'
    clean(outputDir, outputFile)
    gulp.src('./vendor.coffee', read: false)
        .pipe(browserify({}))
        .pipe(uglify())
        .pipe(concat(outputFile))
        .pipe(gulp.dest(outputDir))

gulp.task 'watch', ->
    gulp.watch('./client/scripts/*.coffee', ['scripts'])
    gulp.watch(['./vendor.coffee', './package.json'], ['vendor'])

gulp.task 'start', ->
    nodemon({
        script: 'server.coffee'
    })

gulp.task 'default', [
    'watch'
    'scripts'
    'vendor'
    'start'
]
