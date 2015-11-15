
$(function(){
    var $dropzone=$('#dropzone')
    var mousex,mousey;
    var reader = new FileReader();
    function _arrayBufferToBase64( buffer ) {
        var binary = '';
        var bytes = new Uint8Array( buffer );
        var len = bytes.byteLength;
        for (var i = 0; i < len; i++) {
            binary += String.fromCharCode( bytes[ i ] );
        }
        return window.btoa( binary );
    }
    function drop(e,hover){
        e.preventDefault();
        e.stopPropagation();
        if(hover){
            $(e.target).addClass('hover')
            $('#dndText').text("Drop to upload")
        }
        else{
            $(e.target).removeClass('hover')
            $('#dndText').text("Drag and drop files here")
        }
    }
    $(document).on('mousemove',function(e){
        mousex=e.pageX
        mousey=e.pageY
    })
    $dropzone.on('dragover',function(e) {
        drop(e,1)
    })
    $dropzone.on('dragleave',function(e) {
        drop(e,0)
    })
    $dropzone.on('drop',function(e){
        drop(e,0)
        if(e.originalEvent.dataTransfer){
            if(e.originalEvent.dataTransfer.files.length) {
                //console.log(e.originalEvent.dataTransfer.files);
                f=e.originalEvent.dataTransfer.files[0]
                reader.onload=function(dataURL) {
                    //$('#img').attr('src',reader.result)
                    $('<img/>', {
                        //id: 'foo',
                        src: dataURL.target.result,
                        //title: 'Become a Googler',
                        //rel: 'external',
                        //text: 'Go to Google!'
                    }).appendTo($dropzone).offset({top:mousey,left:mousex}).draggable();

                    //reader.onload=function(arrayBuffer){
                        $.ajax({
                            method:"POST",
                            url:"/api/picture",
                            data:{"data":dataURL.target.result},
                            //processData:false,
                            //contentType:"application/binary"
                        })
                    //}
                    //reader.readAsArrayBuffer(f);
                }
                reader.readAsDataURL(f);

            }
        }
    })
    //$('#img').draggable();
})