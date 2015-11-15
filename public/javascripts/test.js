$(function(){
    var $dropzone=$('#dropzone')
    console.log("HI")
    function drop(e,hover){
        e.preventDefault();
        e.stopPropagation();
        if(hover)
            $(e.target).addClass('hover')
        else
            $(e.target).removeClass('hover')
    }
    $dropzone.on(
    'dragover',
    function(e) {
        drop(e,1)
    }
    )
    $dropzone.on(
    'dragleave',
    function(e) {
        drop(e,0)
    }
    )
    $dropzone.on('drop',function(e){
        if(e.originalEvent.dataTransfer){
            if(e.originalEvent.dataTransfer.files.length) {
                drop(e,0)
                console.log(e.originalEvent.dataTransfer.files);
            }   
        }
    })
})