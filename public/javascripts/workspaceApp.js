// Generated by CoffeeScript 1.9.3
var app, scrollAtBottom, scrollToBottom, updateScrollState;

app = angular.module('workspaceApp', []);

scrollAtBottom = true;

app.controller('workspaceController', function($scope) {
  var $dropzone, drop, hoverTextOff, hoverTextOn, maxx, maxy, mouseX, mouseY, myDropzone, socket;
  $dropzone = $('#dropzone');
  mouseX = void 0;
  mouseY = void 0;
  maxx = function() {
    return $dropzone.outerWidth();
  };
  maxy = function() {
    return $dropzone.outerHeight();
  };
  myDropzone = new Dropzone('#dropzone', {
    url: '/api/fileUpload',
    method: 'post',
    uploadMultiple: false,
    maxFilesize: 9,
    clickable: false,
    createImageThumbnails: false,
    autoProcessQueue: true,
    accept: function(file, done) {
      this.options.url = '/api/fileUpload?group=' + $scope.groupName + '&x=' + mouseX * 100.0 / maxx() + '&y=' + mouseY * 100.0 / maxy() + '&type=image/jpeg';
      hoverTextOff();
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
    return socket.emit('getInitialItems');
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
  socket.on('updateItem', function(itemInfo) {
    return $('#' + itemInfo.fileName).offset({
      top: itemInfo.y / 100.0 * maxy(),
      left: itemInfo.x / 100.0 * maxx()
    });
  });
  socket.on('newItem', function(itemInfo) {
    var innerContent;
    innerContent = void 0;
    if (itemInfo.type === 'text') {
      innerContent = $('<p/>', {
        "class": 'noselect'
      }).text(itemInfo.text);
    } else if (itemInfo.type === 'image/jpeg') {
      innerContent = $('<img/>', {
        src: '/api/picture?fileToGet=' + itemInfo.fileName + '&groupName=' + $scope.groupName
      });
    } else {

    }
    if (innerContent) {
      return innerContent.appendTo($dropzone).wrap('<div id=' + itemInfo.fileName + ' style=\'position:absolute;\'></div>').parent().offset({
        top: itemInfo.y / 100.0 * maxy(),
        left: itemInfo.x / 100.0 * maxx()
      }).draggable({
        containment: 'parent',
        cursor: 'move',
        stop: function(event, ui) {
          return socket.emit('updateItemLocation', $(this).attr('id'), ui.offset.left * 100.0 / maxx(), ui.offset.top * 100.0 / maxy());
        }
      }).on('resize', function() {
        var height, width;
        width = $(this).outerWidth();
        return height = $(this).outerHeight();
      });
    }
  });
  $scope.buttonClicked = function(string) {
    var data;
    data = {
      'text': string
    };
    return $.ajax({
      method: 'POST',
      url: '/api/text?group=' + $scope.groupName,
      data: JSON.stringify(data),
      processData: false,
      contentType: 'application/json; charset=utf-8'
    });
  };
  drop = function(e, hover) {
    if (hover) {
      return hoverTextOn();
    } else {
      return hoverTextOff();
    }
  };
  hoverTextOn = function(e) {
    $('#dropzone').addClass('hover');
    return $('#dndText').text('Drop to upload');
  };
  hoverTextOff = function(e) {
    $('#dropzone').removeClass('hover');
    return $('#dndText').text('Drag and drop files here');
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

window.onload = function() {
  var msgpanel;
  msgpanel = document.getElementById('msgpanel');
  return msgpanel.scrollTop = msgpanel.scrollHeight;
};

updateScrollState = function() {
  return scrollAtBottom = msgpanel.scrollTop === (msgpanel.scrollHeight - msgpanel.offsetHeight);
};

scrollToBottom = function() {
  if (scrollAtBottom) {
    return msgpanel.scrollTop = msgpanel.scrollHeight;
  }
};
