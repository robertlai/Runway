describe 'Directives', ->

    beforeEach(module('runwayAppDirectives'))

    Constants = undefined
    $rootScope = undefined
    $compile = undefined
    scope = undefined
    element = undefined

    beforeEach inject (_$compile_, _$rootScope_, _Constants_) ->
        $compile = _$compile_
        $rootScope = _$rootScope_
        Constants = _Constants_


    describe 'runwayDropzone', ->

        deferredGroup = undefined
        q = undefined

        beforeEach inject ($q) ->
            q = $q
            deferredGroup = q.defer()

        describe 'setup', ->

            beforeEach ->
                $rootScope.socket = {
                    on: ->
                    group: deferredGroup.promise
                    emit: ->
                }
                element = $compile('<div runway-dropzone="testRunway" socket="socket" style="width: 250px; height: 500px;"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()

            it 'should add the d&d text to the dom', ->
                expect(element.html()).toEqual('<h1 class="dndText noselect">Drag and drop files here</h1>')

            it 'should set the id of the dropzone ot the given string', ->
                expect(element.attr('id')).toEqual('testRunway')

            it 'should initialize mouseX to null', ->
                expect(scope.mouseX).toEqual(null)

            it 'should define scope.maxx', ->
                expect(scope.maxx).toEqual(jasmine.any(Function))

            it 'should define scope.maxy', ->
                expect(scope.maxy).toEqual(jasmine.any(Function))

            it 'should define scope.hoverTextOn', ->
                expect(scope.hoverTextOn).toEqual(jasmine.any(Function))

            it 'should define scope.hoverTextOff', ->
                expect(scope.hoverTextOff).toEqual(jasmine.any(Function))


            describe 'scope.maxx', ->

                it 'should return the width of the element', ->
                    expect(scope.maxx()).toEqual(250)


            describe 'scope.maxy', ->

                it 'should return the height of the element', ->
                    expect(scope.maxy()).toEqual(500)


            describe 'scope.hoverTextOn', ->

                it 'should add the class dropzoneHover', ->
                    scope.hoverTextOn()
                    expect(element.hasClass('dropzoneHover')).toEqual(true)

                it "should set the text of the .dndText sub-element to 'Drop to upload'", ->
                    scope.hoverTextOn()
                    expect($('.dndText', element).text()).toEqual('Drop to upload')


            describe 'scope.hoverTextOff', ->

                it 'should remove the class dropzoneHover', ->
                    scope.hoverTextOff()
                    expect(element.hasClass('dropzoneHover')).toEqual(false)

                it "should set the text of the .dndText sub-element to 'Drag and drop files here'", ->
                    scope.hoverTextOff()
                    expect($('.dndText', element).text()).toEqual('Drag and drop files here')


            describe '$(element).on dragover', ->

                mockEvent = undefined

                beforeEach ->
                    mockEvent = $.Event('dragover')

                it 'should set scope.mouseX to the x location of the mouse', ->
                    mockEvent.clientX = 26
                    $(element).triggerHandler(mockEvent)
                    expect(scope.mouseX).toEqual(26)

                it 'should set scope.mouseY to the y location of the mouse', ->
                    mockEvent.clientY = 702
                    $(element).triggerHandler(mockEvent)
                    expect(scope.mouseY).toEqual(702)

                it 'should call scope.hoverTextOn', ->
                    spyOn(scope, 'hoverTextOn').and.callThrough()
                    $(element).triggerHandler(mockEvent)
                    expect(scope.hoverTextOn).toHaveBeenCalled()


            describe '$(element).on dragleave', ->

                mockEvent = undefined

                beforeEach ->
                    mockEvent = $.Event('dragleave')

                it 'should call scope.hoverTextOff', ->
                    spyOn(scope, 'hoverTextOff').and.callThrough()
                    $(element).triggerHandler(mockEvent)
                    expect(scope.hoverTextOff).toHaveBeenCalled()


        describe 'Dropzone creation', ->

            beforeEach ->
                spyOn(window, 'Dropzone').and.callFake ->
                    {
                        on: ->
                    }
                $rootScope.socket = {
                    on: ->
                    group: deferredGroup.promise
                }
                element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()

            it 'should call new Dropzone with the correct params', ->
                expect(window.Dropzone).toHaveBeenCalledWith($(element).get(0), {
                    url: '/api/fileUpload'
                    method: 'post'
                    uploadMultiple: false
                    maxFilesize: 9
                    clickable: false
                    createImageThumbnails: false
                    autoProcessQueue: true
                    acceptedFiles: 'image/*, application/pdf'
                    accept: jasmine.any(Function)
                })


        describe 'Dropzone created', ->

            beforeEach ->
                $rootScope.socket = {
                    on: ->
                    group: deferredGroup.promise
                }
                element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()

            describe 'options', ->

                options = undefined

                beforeEach ->
                    options = scope.myDropzone.options

                it 'should set the url', ->
                    expect(options.url).toEqual('/api/fileUpload')

                it 'should set the method', ->
                    expect(options.method).toEqual('POST')

                it 'should set the maxFilesize', ->
                    expect(options.maxFilesize).toEqual(9)

                it 'should set the paramName', ->
                    expect(options.paramName).toEqual('file')

                it 'should set the clickable', ->
                    expect(options.clickable).toEqual(false)

                it 'should set the ignoreHiddenFiles', ->
                    expect(options.ignoreHiddenFiles).toEqual(true)

                it 'should set the acceptedFiles', ->
                    expect(options.acceptedFiles).toEqual('image/*, application/pdf')

            describe 'accept file', ->

                beforeEach ->
                    scope.group = _id: 'testGroupId'
                    spyOn(scope, 'maxx').and.callFake -> 5
                    spyOn(scope, 'maxy').and.callFake -> 15
                    scope.mouseX = 2
                    scope.mouseY = 236

                it 'should set the headers _group to the scope.group._id', (done) ->
                    scope.myDropzone.options.accept 'fake file', ->
                        expect(scope.myDropzone.options.headers._group).toEqual('testGroupId')
                        done()

                it 'should set the headers.screenwidth to the scope.maxx', (done) ->
                    scope.myDropzone.options.accept 'fake file', ->
                        expect(scope.myDropzone.options.headers.screenwidth).toEqual(5)
                        done()

                it 'should set the headers.screenheight to the scope.maxy', (done) ->
                    scope.myDropzone.options.accept 'fake file', ->
                        expect(scope.myDropzone.options.headers.screenheight).toEqual(15)
                        done()

                it 'should set the headers.x to the scope.mouseX', (done) ->
                    scope.myDropzone.options.accept 'fake file', ->
                        expect(scope.myDropzone.options.headers.x).toEqual(2)
                        done()

                it 'should set the headers.y to the scope.mouseY', (done) ->
                    scope.myDropzone.options.accept 'fake file', ->
                        expect(scope.myDropzone.options.headers.y).toEqual(236)
                        done()


            describe 'file upload complete', ->

                it 'should remove the compleated file from queue', ->
                    spyOn(scope.myDropzone, 'removeFile')
                    completeFunction('fake file') for completeFunction in scope.myDropzone._callbacks.complete
                    expect(scope.myDropzone.removeFile).toHaveBeenCalledWith('fake file')


        describe 'resolve scoket.group', ->

            beforeEach ->
                $rootScope.socket = {
                    on: ->
                    group: deferredGroup.promise
                    emit: ->
                }
                element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()
                deferredGroup.resolve('testResolvedGroup')
                spyOn($rootScope.socket, 'emit')
                $rootScope.$digest()

            it 'should set scope.group to the resolved scoket.group', ->
                expect(scope.group).toEqual('testResolvedGroup')

            it "should emit 'getInitialItems'", ->
                expect($rootScope.socket.emit).toHaveBeenCalledWith('getInitialItems')


        describe 'socket.on newItem', ->

            describe 'type: text', ->

                it 'should create a runway-draggable item of type text', ->
                    newItem = { type: 'text', text: 'test text' }
                    $rootScope.socket = {
                        on: (callName, callback) ->
                            if callName is 'newItem'
                                callback(newItem)
                        group: deferredGroup.promise
                    }
                    element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                    $rootScope.$digest()
                    scope = element.isolateScope()
                    expect(element.html()).toContain('test text')
                    expect(element.html()).toContain('<p')
                    expect(element.html()).toContain('</p>')
                    expect(element.html()).toContain('ui-draggable')
                    expect(element.html()).toContain('runway-draggable=')


            describe 'type: image', ->

                it 'should create a runway-draggable item of type image', ->
                    newItem = { type: 'image/anything', _id: 'imageId' }
                    $rootScope.socket = {
                        on: (callName, callback) ->
                            if callName is 'newItem'
                                callback(newItem)
                        group: deferredGroup.promise
                    }
                    element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                    $rootScope.$digest()
                    scope = element.isolateScope()
                    expect(element.html()).toContain('<img')
                    expect(element.html()).toContain('src="/api/file?_file=imageId"')
                    expect(element.html()).toContain('ui-draggable')
                    expect(element.html()).toContain('runway-draggable=')


            describe 'type: image', ->

                it 'should create a runway-draggable item of type image', ->
                    newItem = { type: 'application/pdf', _id: 'pdfId' }
                    $rootScope.socket = {
                        on: (callName, callback) ->
                            if callName is 'newItem'
                                callback(newItem)
                        group: deferredGroup.promise
                    }
                    element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                    $rootScope.$digest()
                    scope = element.isolateScope()
                    expect(element.html()).toContain('<object')
                    expect(element.html()).toContain('data="/api/file?_file=pdfId"')
                    expect(element.html()).toContain('runway-draggable=')
                    expect(element.html()).toContain('ui-draggable')
                    expect(element.html()).toContain('</object>')

            describe 'type: other', ->

                it 'should not add anything to the DOM', ->
                    newItem = { type: 'other', _id: 'otherId', text: 'some text' }
                    $rootScope.socket = {
                        on: (callName, callback) ->
                            if callName is 'newItem'
                                callback(newItem)
                        group: deferredGroup.promise
                    }
                    element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                    $rootScope.$digest()
                    scope = element.isolateScope()
                    expect(element.html()).toEqual('<h1 class="dndText noselect">Drag and drop files here</h1>')


    describe 'runwayDraggable', ->

        describe 'setup with all params', ->

            beforeEach ->
                $rootScope.socket = {
                    on: ->
                }
                itemsInfo = {
                    _id: 321123
                    width: 68
                    height: 27
                    x: 14
                    y: 55
                }
                element = $compile('<div runway-draggable=' + JSON.stringify(itemsInfo) + '></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()

            it 'should set the top css to the given y percent', ->
                expect(element.css('top')).toEqual('55%')

            it 'should set the left css to the given x percent', ->
                expect(element.css('left')).toEqual('14%')

            it 'should set the position css to absolute', ->
                expect(element.css('position')).toEqual('absolute')

            it 'should set the width css to the given width', ->
                expect(element.css('width')).toEqual('68%')

            it 'should set the height css to the given height', ->
                expect(element.css('height')).toEqual('27%')

            it 'should set the max-height css to 50%', ->
                expect(element.css('max-height')).toEqual('50%')

            it 'should set the max-width css to 50%', ->
                expect(element.css('max-width')).toEqual('50%')


        describe 'setup without height and width params', ->

            beforeEach ->
                $rootScope.socket = {
                    on: ->
                }
                itemsInfo = {
                    _id: 321123
                    x: 14
                    y: 55
                }
                element = $compile('<div runway-draggable=' + JSON.stringify(itemsInfo) + '></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()

            it 'should set the width css to the given width', ->
                expect(element.css('width')).toEqual('')

            it 'should set the height css to the given height', ->
                expect(element.css('height')).toEqual('')


        describe 'socket.on updateItem', ->

            describe 'with this item', ->

                beforeEach ->
                    itemInfo = { _id: 321123, x: 789, y: 987 }
                    $rootScope.socket = {
                        on: (callName, callback) ->
                            if callName is 'updateItem'
                                callback(itemInfo)
                    }
                    itemsInfo = {
                        _id: 321123
                        width: 68
                        height: 27
                        x: 14
                        y: 55
                    }

                    element = $compile('<div runway-draggable=' + JSON.stringify(itemsInfo) + '></div>')($rootScope)
                    $rootScope.$digest()
                    scope = element.isolateScope()

                it 'adjust the position of this item', ->
                    expect(element.css('top')).toEqual('987%')
                    expect(element.css('left')).toEqual('789%')


            describe 'with another item', ->

                beforeEach ->
                    itemInfo = { _id: 123321, x: 789, y: 987 }
                    $rootScope.socket = {
                        on: (callName, callback) ->
                            if callName is 'updateItem'
                                callback(itemInfo)
                    }
                    itemsInfo = {
                        _id: 321123
                        width: 68
                        height: 27
                        x: 14
                        y: 55
                    }

                    element = $compile('<div runway-draggable=' + JSON.stringify(itemsInfo) + '></div>')($rootScope)
                    $rootScope.$digest()
                    scope = element.isolateScope()

                it 'should do nothing', ->
                    expect(element.css('top')).toEqual('55%')
                    expect(element.css('left')).toEqual('14%')


        describe 'drag the element', ->

            beforeEach ->
                itemInfo = { _id: 123321, x: 789, y: 987 }
                $rootScope.socket = {
                    on: (callName, callback) ->
                        if callName is 'updateItem'
                            callback(itemInfo)
                    emit: ->
                }
                itemsInfo = {
                    _id: 321123
                    width: 68
                    height: 27
                    x: 14
                    y: 55
                }
                $rootScope.maxx = -> 102
                $rootScope.maxy = -> 703

                spyOn($rootScope.socket, 'emit')

                element = $compile('<div runway-draggable=' + JSON.stringify(itemsInfo) + '></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()

            it 'should emit the changed location', ->
                mockEvent = $.Event('dragstop')
                ui = {
                    offset: {
                        left: 1000
                        top: 200
                    }
                }
                $(element).triggerHandler(mockEvent, ui)
                expect($rootScope.socket.emit).toHaveBeenCalledWith('updateItemLocation', 321123, 100000.0 / 102, 20000 / 703)
