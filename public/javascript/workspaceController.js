// Generated by CoffeeScript 1.9.3
var scrollAtBottom, scrollToBottom, updateScrollState;

scrollAtBottom = true;

angular.module('runwayApp').controller('workspaceController', function($scope) {
  var $dropzone, addPicture, dataURLtoBlob, drop, maxx, maxy, mouseX, mouseY, myDropzone, reader, socket;
  $dropzone = $('#dropzone');
  mouseX = void 0;
  mouseY = void 0;
  maxx = function() {
    return $dropzone.outerWidth();
  };
  maxy = function() {
    return $dropzone.outerHeight();
  };
  myDropzone = new Dropzone("#dropzone", {
    url: '/api/fileUpload',
    method: "post",
    uploadMultiple: false,
    maxFilesize: 9,
    clickable: false,
    createImageThumbnails: false,
    autoProcessQueue: true,
    accept: function(file, done) {
      this.options.url = '/api/fileUpload?group=' + $scope.groupName + '&x=' + mouseX * 100.0 / maxx() + '&y=' + mouseY * 100.0 / maxy();
      return done();
    }
  });
  myDropzone.on('complete', function(file) {
    return myDropzone.removeFile(file);
  });
  socket = io();
  $scope.init = function(username, groupName) {
    $scope.username = username;
    $scope.groupName = groupName;
    return socket.emit('groupConnect', username, groupName);
  };
  socket.on('setupComplete', function() {
    socket.emit('getInitialMessages');
    return socket.emit('getInitialPictures');
  });
  socket.on('initialMessages', function(messages) {
    $scope.messages = messages;
    $scope.$apply();
    return scrollToBottom();
  });
  socket.on('newMessage', function(message) {
    $scope.messages.push(message);
    $scope.$apply();
    return scrollToBottom();
  });
  socket.on('removeMessage', function(timestamp) {
    $scope.messages = $scope.messages.filter(function(message) {
      return message.timestamp !== timestamp;
    });
    return $scope.$apply();
  });
  socket.on('initialPictures', function(pictureInfos) {
    var i, len, pictureInfo;
    for (i = 0, len = pictureInfos.length; i < len; i++) {
      pictureInfo = pictureInfos[i];
      addPicture(pictureInfo);
    }
    return $scope.$apply();
  });
  socket.on('updatePicture', function(pictureInfo) {
    return $('#' + pictureInfo.fileName).offset({
      top: pictureInfo.y / 100.0 * maxy(),
      left: pictureInfo.x / 100.0 * maxx()
    });
  });
  socket.on('newPicture', function(pictureInfo) {
    return addPicture(pictureInfo);
  });
  $scope.$on('$destroy', function() {
    return socket.removeListener();
  });
  reader = new FileReader;
  dataURLtoBlob = function(dataurl) {
    var arr, bstr, mime, n, u8arr;
    arr = dataurl.split(',');
    mime = arr[0].match(/:(.*?);/)[1];
    bstr = atob(arr[1]);
    n = bstr.length;
    u8arr = new Uint8Array(n);
    while (n--) {
      u8arr[n] = bstr.charCodeAt(n);
    }
    return new Blob([u8arr], {
      type: mime
    });
  };
  $scope.buttonClicked = function(str) {
    var tCtx;
    tCtx = $('<canvas/>')[0].getContext('2d');
    tCtx.font = '20px Arial';
    tCtx.canvas.width = tCtx.measureText(str).width;
    tCtx.canvas.height = 25;
    tCtx.font = '20px Arial';
    tCtx.fillText(str, 0, 20);
    reader.onload = function(arrayBuffer) {
      return $.ajax({
        method: 'POST',
        url: '/api/picture?group=' + $scope.groupName + '&x=1&y=1',
        data: arrayBuffer.target.result,
        processData: false,
        contentType: 'application/binary'
      });
    };
    return reader.readAsArrayBuffer(dataURLtoBlob(tCtx.canvas.toDataURL()));
  };
  addPicture = function(pictureInfo) {
    return $('<img/>', {
      src: '/api/picture?fileToGet=' + pictureInfo.fileName + '&groupName=' + $scope.groupName
    }).appendTo($dropzone).wrap('<div id=' + pictureInfo.fileName + ' style=\'position:absolute;\'></div>').parent().offset({
      top: pictureInfo.y / 100.0 * maxy(),
      left: pictureInfo.x / 100.0 * maxx()
    }).draggable({
      containment: 'parent',
      cursor: 'move',
      stop: function(event, ui) {
        return socket.emit('updatePictureLocation', $(this).attr('id'), ui.offset.left * 100.0 / maxx(), ui.offset.top * 100.0 / maxy());
      }
    }).on('resize', function() {
      var height, width;
      width = $(this).outerWidth();
      return height = $(this).outerHeight();
    });
  };
  drop = function(e, hover) {
    if (hover) {
      $(e.target).addClass('hover');
      return $('#dndText').text('Drop to upload');
    } else {
      $(e.target).removeClass('hover');
      return $('#dndText').text('Drag and drop files here');
    }
  };
  $dropzone.on('dragover', function(e) {
    mouseX = e.originalEvent.offsetX;
    mouseY = e.originalEvent.offsetY;
    return drop(e, true);
  });
  $dropzone.on('dragleave', function(e) {
    return drop(e, false);
  });
  $scope.chatVisible = true;
  $scope.messages = [];
  $scope.sendMessage = function() {
    if ($scope.newMessage && $scope.newMessage.trim().length > 0) {
      socket.emit('postNewMessage', $scope.newMessage);
      return $scope.newMessage = '';
    }
  };
  $scope.removeMessage = function(timestamp) {
    return socket.emit('postRemoveMessage', timestamp);
  };
  $scope.hideChat = function() {
    $scope.chatVisible = false;
    return document.getElementById('dropzone').style.width = '100%';
  };
  return $scope.showChat = function() {
    $scope.chatVisible = true;
    return document.getElementById('dropzone').style.width = '75%';
  };
});

updateScrollState = function() {
  return scrollAtBottom = msgpanel.scrollTop === (msgpanel.scrollHeight - msgpanel.offsetHeight);
};

scrollToBottom = function() {
  if (scrollAtBottom) {
    return msgpanel.scrollTop = msgpanel.scrollHeight;
  }
};
