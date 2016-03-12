module.exports = (config) ->
    config.set
        basePath: ''
        frameworks: ['jasmine']
        files: ['dist/scripts/vendor.min.js',
        'node_modules/angular-mocks/angular-mocks.js'
        'dist/scripts/client.js',
        'spec/client/**/*.spec.coffee']
        exclude: []
        preprocessors: {
            'dist/scripts/client.js': 'coverage'
            'spec/**/*.spec.coffee': 'coffee'
        }
        reporters: ['progress', 'kjhtml', 'coverage']
        coverageReporter: {
            dir: 'spec/coverage',
            reporters: [
                { type: 'html', subdir: 'report-html' },
            ]
        }
        port: 9872
        colors: true
        logLevel: config.LOG_WARN
        autoWatch: true
        browsers: [
            # 'Chrome'
            # 'Firefox'
            'PhantomJS'
            # 'IE'
        ]
        singleRun: false
        concurrency: Infinity
