module.exports = (config) ->
    config.set
        basePath: ''
        frameworks: ['jasmine']
        files: ['dist/scripts/vendor.min.js',
        'node_modules/angular-mocks/angular-mocks.js'
        'dist/scripts/client.min.js',
        'spec/client/**/*.spec.coffee']
        exclude: []
        preprocessors: 'spec/**/*.spec.coffee': ['coffee']
        reporters: ['progress', 'kjhtml']
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
