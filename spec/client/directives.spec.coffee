describe 'Directives', ->

    beforeEach(module('runwayAppDirectives'))

    Constants = undefined
    $rootScope = undefined
    $compile = undefined
    scope = undefined
    element = undefined
    MessageService = undefined
    ItemService = undefined

    beforeEach inject (_$compile_, _$rootScope_, _Constants_, _MessageService_, _ItemService_) ->
        $compile = _$compile_
        $rootScope = _$rootScope_
        Constants = _Constants_
        ItemService = _ItemService_
        MessageService = _MessageService_


    describe 'runwayDropzone', ->

        deferredGroup = undefined

        beforeEach inject ($q) ->
            deferredGroup = $q.defer()

        describe 'setup', ->

            beforeEach ->
                $rootScope.socket = {
                    on: ->
                    _group: deferredGroup.promise
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
                    _group: deferredGroup.promise
                }
                element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()

            it 'should call new Dropzone with the correct params', ->
                expect(window.Dropzone).toHaveBeenCalledWith($(element).get(0), {
                    url: '/api/items/fileUpload'
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
                    _group: deferredGroup.promise
                }
                element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()

            describe 'options', ->

                options = undefined

                beforeEach ->
                    options = scope.myDropzone.options

                it 'should set the url', ->
                    expect(options.url).toEqual('/api/items/fileUpload')

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
                    scope._group = 'testGroupId'
                    spyOn(scope, 'maxx').and.callFake -> 5
                    spyOn(scope, 'maxy').and.callFake -> 15
                    scope.mouseX = 2
                    scope.mouseY = 236

                it 'should set the headers _group to the scope._group', (done) ->
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
                    _group: deferredGroup.promise
                }
                element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()
                spyOn(ItemService, 'getInitialItems').and.callFake -> {
                    then: (callback) -> callback(['item1', 'item2'])
                }
                spyOn(scope, 'addNewItem').and.callFake ->
                deferredGroup.resolve('testResolvedGroupId')
                $rootScope.$digest()

            it 'should set scope._group to the resolved scoket.group', ->
                expect(scope._group).toEqual('testResolvedGroupId')

            it 'should call ItemService.getInitialItems', ->
                expect(ItemService.getInitialItems).toHaveBeenCalledWith('testResolvedGroupId')

            it 'should call scope.addNewItem with each new item', ->
                expect(scope.addNewItem).toHaveBeenCalledWith('item1')
                expect(scope.addNewItem).toHaveBeenCalledWith('item2')

        describe 'socket.on', ->

            socketCallbacksByName = {}

            beforeEach ->
                $rootScope.socket = {
                    on: (callName, callback) ->
                        socketCallbacksByName[callName] = callback
                    _group: deferredGroup.promise
                }

            describe 'newItem', ->

                describe 'type: text', ->

                    it 'should create a runway-draggable item of type text', ->
                        element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                        $rootScope.$digest()
                        scope = element.isolateScope()
                        socketCallbacksByName['newItem']({ type: 'text', text: 'test text' })
                        expect(element.html()).toContain('test text')
                        expect(element.html()).toContain('<p')
                        expect(element.html()).toContain('</p>')
                        expect(element.html()).toContain('ui-draggable')
                        expect(element.html()).toContain('runway-draggable=')


                describe 'type: image', ->

                    it 'should create a runway-draggable item of type image', ->
                        element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                        $rootScope.$digest()
                        scope = element.isolateScope()
                        socketCallbacksByName['newItem']({ type: 'image/anything', _id: 'imageId' })
                        expect(element.html()).toContain('<img')
                        expect(element.html()).toContain('src="/api/items/file?_file=imageId"')
                        expect(element.html()).toContain('ui-draggable')
                        expect(element.html()).toContain('runway-draggable=')


                describe 'type: image', ->

                    it 'should create a runway-draggable item of type image', ->
                        element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                        $rootScope.$digest()
                        scope = element.isolateScope()
                        socketCallbacksByName['newItem']({ type: 'application/pdf', _id: 'pdfId' })
                        expect(element.html()).toContain('<object')
                        expect(element.html()).toContain('data="/api/items/file?_file=pdfId"')
                        expect(element.html()).toContain('runway-draggable=')
                        expect(element.html()).toContain('ui-draggable')
                        expect(element.html()).toContain('</object>')

                describe 'type: other', ->

                    it 'should not add anything to the DOM', ->
                        element = $compile('<div runway-dropzone="testRunway" socket="socket"></div>')($rootScope)
                        $rootScope.$digest()
                        scope = element.isolateScope()
                        socketCallbacksByName['newItem']({ type: 'other', _id: 'otherId', text: 'some text' })
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

        describe 'socket.on', ->

            socketCallbacksByName = {}

            beforeEach ->
                $rootScope.socket = {
                    on: (callName, callback) ->
                        socketCallbacksByName[callName] = callback
                }

            describe 'updateItem', ->

                describe 'with this item', ->

                    it 'adjust the position of this item', ->
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
                        socketCallbacksByName['updateItem']({ _id: 321123, x: 789, y: 987 })
                        expect(element.css('top')).toEqual('987%')
                        expect(element.css('left')).toEqual('789%')


                describe 'with another item', ->

                    it 'should do nothing', ->
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
                        socketCallbacksByName['updateItem']({ _id: 123321, x: 789, y: 987 })
                        expect(element.css('top')).toEqual('55%')
                        expect(element.css('left')).toEqual('14%')


        describe 'drag the element', ->

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
                $rootScope.maxx = -> 102
                $rootScope.maxy = -> 703

                spyOn(ItemService, 'updateItemLocation')

                element = $compile('<div runway-draggable=' + JSON.stringify(itemsInfo) + '></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()

            it 'should call ItemService.updateItemLocation with the item id, maxx and maxy', ->
                mockEvent = $.Event('dragstop')
                ui = {
                    offset: {
                        left: 1000
                        top: 200
                    }
                }
                $(element).triggerHandler(mockEvent, ui)
                expect(ItemService.updateItemLocation).toHaveBeenCalledWith(321123, 100000.0 / 102, 20000 / 703)


    describe 'chatPanel', ->

        deferredGroup = undefined

        beforeEach inject ($q, $templateCache) ->
            deferredGroup = $q.defer()
            $templateCache.put('/partials/chatPanel.html', '<div></div>')

        describe 'setup', ->

            beforeEach inject ->
                $rootScope.socket = {
                    on: ->
                    _group: deferredGroup.promise
                }
                element = $compile('<div chat-panel socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()

            it 'should set scope.messagesLoading to true', ->
                expect(scope.messagesLoading).toEqual(true)

            it 'should initialize scope.messages to []', ->
                expect(scope.messages).toEqual([])

            it 'should define scope.addMessageContent', ->
                expect(scope.addMessageContent).toEqual(jasmine.any(Function))

            it 'should define scope.addMessageToWorkspace', ->
                expect(scope.addMessageToWorkspace).toEqual(jasmine.any(Function))

            it 'should define scope.sendMessage', ->
                expect(scope.sendMessage).toEqual(jasmine.any(Function))

            it 'should define scope.removeMessage', ->
                expect(scope.removeMessage).toEqual(jasmine.any(Function))


        describe 'resolve scoket.group', ->

            toReturn = undefined
            beforeEach (done) ->
                toReturn = ['these', 'are', 'some', 'test', 'messages']
                $rootScope.socket = {
                    on: ->
                    _group: deferredGroup.promise
                }
                element = $compile('<div chat-panel socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()
                spyOn(scope, 'addMessageContent').and.callFake (addFunction) -> addFunction()
                spyOn(MessageService, 'getInitialMessages').and.callFake -> {
                    then: (callback) -> callback(toReturn)
                }
                deferredGroup.resolve('testResolvedGroupId')
                $rootScope.$digest()
                setTimeout ->
                    done()
                , 1

            it 'should set scope._group to the resolved scoket.group', ->
                expect(scope._group).toEqual('testResolvedGroupId')

            it 'should call MessageService.getInitialMessages', ->
                expect(MessageService.getInitialMessages).toHaveBeenCalledWith('testResolvedGroupId')

            it 'should call scope.addMessageContent with the add function and true', ->
                expect(scope.addMessageContent).toHaveBeenCalledWith(jasmine.any(Function), true)

            it 'should set scope.messages to the given messages when scope.addMessageContent calls the add function', ->
                expect(scope.messages).toEqual(toReturn)


        describe 'scope.getDomAttribute', ->

            beforeEach inject ($templateCache) ->
                $templateCache.put('/partials/chatPanel.html', '<div></div>')
                $rootScope.socket = {
                    on: ->
                    _group: deferredGroup.promise
                }
                element = $compile('<div chat-panel socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()

            it 'should return the requested attribute of the given element', ->
                expect(scope.getDomAttribute({ testAttr: 'test value' }, 'testAttr')).toEqual('test value')


        describe 'scope.addMessageContent', ->

            beforeEach inject ($templateCache) ->
                $templateCache.put('/partials/chatPanel.html', "<div><div class='chatBody'></div></div>")
                $rootScope.socket = {
                    on: ->
                    _group: deferredGroup.promise
                }
                element = $compile('<div chat-panel socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()


            describe 'when scrollAtBottom will be false', ->

                it 'should set scope.messagesLoading to false', ->
                    scope.messagesLoading = true
                    callback = ->
                    scope.addMessageContent(callback, false)
                    expect(scope.messagesLoading).toEqual(false)

                it 'should call the passed in addFunction', ->
                    callback = jasmine.createSpy()
                    scope.addMessageContent(callback)
                    expect(callback).toHaveBeenCalled()


            describe 'when scrollAtBottom will be true', ->

                beforeEach ->
                    spyOn(scope, 'getDomAttribute').and.callFake (elmt, attr) ->
                        if attr is 'scrollTop'
                            51
                        else if attr is 'scrollHeight'
                            1
                        else if attr is 'offsetHeight'
                            0

                it 'should set scope.messagesLoading to true', ->
                    scope.messagesLoading = true
                    callback = ->
                    scope.addMessageContent(callback, true)
                    expect(scope.messagesLoading).toEqual(false)

                it 'should call the passed in addFunction', ->
                    callback = jasmine.createSpy()
                    scope.addMessageContent(callback)
                    expect(callback).toHaveBeenCalled()


        describe 'socket.on', ->

            socketCallbacksByName = {}

            beforeEach inject ($templateCache) ->
                $templateCache.put('/partials/chatPanel.html', "<div><div class='chatBody'></div></div>")
                $rootScope.socket = {
                    on: (callName, callback) ->
                        socketCallbacksByName[callName] = callback
                    _group: deferredGroup.promise
                }
                element = $compile('<div chat-panel socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()


            describe 'newMessage', ->

                it 'should call scope.addMessageContent with the add function and true', ->
                    spyOn(scope, 'addMessageContent').and.callFake ->
                    socketCallbacksByName['newMessage']()
                    expect(scope.addMessageContent).toHaveBeenCalledWith(jasmine.any(Function))

                it 'should set scope.messages to the given messages when scope.addMessageContent calls the add function', ->
                    initialMessages = ['some', 'initial', 'messages']
                    newMessage = 'new message'
                    finalMessages = initialMessages.concat([newMessage])
                    spyOn(scope, 'addMessageContent').and.callFake (addFunction) -> addFunction()
                    scope.messages = initialMessages
                    socketCallbacksByName['newMessage'](newMessage)
                    expect(scope.messages).toEqual(finalMessages)


            describe 'removeMessage', ->

                it 'should call scope.addMessageContent with the add function and true', ->
                    spyOn(scope, 'addMessageContent').and.callFake ->
                    socketCallbacksByName['removeMessage']()
                    expect(scope.addMessageContent).toHaveBeenCalledWith(jasmine.any(Function))

                it 'should remove the message matching the given message id from scope.messages', ->
                    initialMessages = [{ _id: 321, content: 'first' }, { _id: 22, content: 'message to remove' }, { _id: 3, content: 'last' }]
                    messageIdToRemove = 22
                    finalMessages = [{ _id: 321, content: 'first' }, { _id: 3, content: 'last' }]
                    spyOn(scope, 'addMessageContent').and.callFake (addFunction) -> addFunction()
                    scope.messages = initialMessages
                    socketCallbacksByName['removeMessage'](messageIdToRemove)
                    expect(scope.messages).toEqual(finalMessages)


        describe 'scope.addMessageToWorkspace', ->

            beforeEach ->
                $rootScope.socket = {
                    on: (callName, callback) ->
                    _group: deferredGroup.promise
                }
                element = $compile('<div chat-panel socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()

            it 'should post to /api/items/text with the group id and the given text', inject ($httpBackend) ->
                item = { _group: 321123, text: 'some text from a message' }
                $httpBackend.expectPOST('/api/items/text', item).respond('')
                scope._group = item._group
                scope.addMessageToWorkspace(item.text)
                $httpBackend.flush()

        describe 'scope.sendMessage', ->

            beforeEach ->
                $rootScope.socket = {
                    on: (callName, callback) ->
                    _group: deferredGroup.promise
                }
                element = $compile('<div chat-panel socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()
                scope._group = 'testGroupId'

            describe 'scope.newMessage is defined and contains at least 1 non-whitespace', ->

                beforeEach ->
                    spyOn(MessageService, 'addNewMessageToChat')
                    scope.newMessage = 'test message'
                    scope.sendMessage()

                it 'should call MessageService.addNewMessageToChat with the group id and newMessage postNewMessage', ->
                    expect(MessageService.addNewMessageToChat).toHaveBeenCalledWith('testGroupId', 'test message')

                it 'should clear scope.newMessage', ->
                    expect(scope.newMessage).toEqual('')

            describe 'scope.newMessage is defined and is empty', ->

                beforeEach ->
                    spyOn(MessageService, 'addNewMessageToChat')
                    scope.newMessage = ''
                    scope.sendMessage()

                it 'should not not call MessageService.addNewMessageToChat', ->
                    expect(MessageService.addNewMessageToChat).not.toHaveBeenCalled()

            describe 'scope.newMessage is defined and contains only spaces', ->

                beforeEach ->
                    spyOn(MessageService, 'addNewMessageToChat')
                    scope.newMessage = '      '
                    scope.sendMessage()

                it 'should not call MessageService.addNewMessageToChat', ->
                    expect(MessageService.addNewMessageToChat).not.toHaveBeenCalled()

            describe 'scope.newMessage is not defined', ->

                beforeEach ->
                    spyOn(MessageService, 'addNewMessageToChat')
                    scope.newMessage = undefined
                    scope.sendMessage()

                it 'should not call MessageService.addNewMessageToChat', ->
                    expect(MessageService.addNewMessageToChat).not.toHaveBeenCalled()


        describe 'scope.removeMessage', ->

            beforeEach ->
                $rootScope.socket = {
                    on: (callName, callback) ->
                    _group: deferredGroup.promise
                }
                element = $compile('<div chat-panel socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()

            it 'should call MessageService.removeMessage with the given message id', ->
                spyOn(MessageService, 'removeMessage')
                scope.removeMessage(987789)
                expect(MessageService.removeMessage).toHaveBeenCalledWith(987789)


        describe "$('.chatBody', element).on 'scoll'", ->

            mockEvent = undefined

            beforeEach inject ($templateCache) ->
                $templateCache.put('/partials/chatPanel.html', "<div><div class='chatBody'></div></div>")
                $rootScope.socket = {
                    on: (callName, callback) ->
                    emit: ->
                    _group: deferredGroup.promise
                }
                element = $compile('<div chat-panel socket="socket"></div>')($rootScope)
                $rootScope.$digest()
                scope = element.isolateScope()
                mockEvent = $.Event('scroll')
                scope.messages = [{ _id: 321, date: 'date1' }, { _id: 22, date: 'date2' }, { _id: 3, date: 'date3' }]


            describe 'scope.allMessagesLoaded = false and chatBody.scrollTop is 0', ->

                toReturn = undefined

                beforeEach ->
                    toReturn = []
                    scope.allMessagesLoaded = false
                    spyOn(MessageService, 'getMoreMessages').and.callFake -> {
                        then: (callback) -> callback(toReturn)
                    }

                it 'should set scope.messagesLoading to true', ->
                    scope.messagesLoading = false
                    $('.chatBody', element).triggerHandler(mockEvent)
                    expect(scope.messagesLoading).toEqual(true)

                it 'should set scope.preLoadScrollHeight to chatBody.scrollHeight', ->
                    scope.preLoadScrollHeight = undefined
                    $('.chatBody', element).triggerHandler(mockEvent)
                    expect(scope.preLoadScrollHeight).toEqual(0)

                it 'should call MessageService.getMoreMessages with the group id and the date of the last message', ->
                    toReturn = []
                    scope._group = 'testGroupId'
                    $('.chatBody', element).triggerHandler(mockEvent)
                    $rootScope.$digest()
                    expect(MessageService.getMoreMessages).toHaveBeenCalledWith('testGroupId', 'date3')

                it 'should set scope.allMessagesLoaded to true if the given messages length is 0', (done) ->
                    toReturn = []
                    $('.chatBody', element).triggerHandler(mockEvent)
                    $rootScope.$digest()
                    setTimeout ->
                        expect(scope.allMessagesLoaded).toEqual(true)
                        done()
                    , 5

                it 'should set scope.allMessagesLoaded to false if the given messages length is 0', (done) ->
                    toReturn = ['only one message']
                    $('.chatBody', element).triggerHandler(mockEvent)
                    $rootScope.$digest()
                    setTimeout ->
                        expect(scope.allMessagesLoaded).toEqual(false)
                        done()
                    , 5

                it 'should call scope.addMessageContent with the add function', (done) ->
                    spyOn(scope, 'addMessageContent').and.callFake ->
                    toReturn = []
                    $('.chatBody', element).triggerHandler(mockEvent)
                    $rootScope.$digest()
                    setTimeout ->
                        expect(scope.addMessageContent).toHaveBeenCalledWith(jasmine.any(Function))
                        done()
                    , 5

                it 'should add the given messages to scope.message when scope.addMessageContent calls the add function', (done) ->
                    intialMessages = ['some', 'initial', 'messages']
                    testMessages = ['these', 'are', 'some', 'test', 'messages']
                    finalMessages = intialMessages.concat(testMessages)
                    spyOn(scope, 'addMessageContent').and.callFake (addFunction) -> addFunction()
                    scope.messages = intialMessages
                    toReturn = testMessages
                    $('.chatBody', element).triggerHandler(mockEvent)
                    $rootScope.$digest()
                    setTimeout ->
                        expect(scope.messages).toEqual(finalMessages)
                        done()
                    , 5


            describe 'scope.allMessagesLoaded = true and chatBody.scrollTop is 0', ->

                beforeEach ->
                    scope.allMessagesLoaded = true

                it 'should set scope.messagesLoading to true', ->
                    scope.messagesLoading = false
                    $('.chatBody', element).triggerHandler(mockEvent)
                    expect(scope.messagesLoading).toEqual(false)

                it 'should set scope.preLoadScrollHeight to chatBody.scrollHeight', ->
                    scope.preLoadScrollHeight = undefined
                    $('.chatBody', element).triggerHandler(mockEvent)
                    expect(scope.preLoadScrollHeight).toEqual(undefined)

                it 'should emit getMoreMessages with the date of the last message', ->
                    spyOn($rootScope.socket, 'emit')
                    $('.chatBody', element).triggerHandler(mockEvent)
                    expect($rootScope.socket.emit).not.toHaveBeenCalled()
