
$(function(){
    var $dropzone=$('#dropzone')
    var mousex,mousey;
    var f
    var reader = new FileReader();

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
                reader.onload=function(e) {
                    $('<img/>', {
                        //id: 'foo',
                        src: reader.result,
                        //title: 'Become a Googler',
                        //rel: 'external',
                        //text: 'Go to Google!'
                    }).appendTo($dropzone).offset({top:mousey,left:mousex}).draggable();
                    $.post(
                    "/api/picture",
                    reader.result
                    )
                    //$('#img').attr('src',reader.result)
                }
                reader.readAsDataURL(e.originalEvent.dataTransfer.files[0]);

            }   
        }
    })
    //$('#img').draggable();
})