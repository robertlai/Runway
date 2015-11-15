var temp
$(function(){
    var $dropzone=$('#dropzone')
    var mousex,mousey;
    var reader = new FileReader();
    var total=[]
    var maxx,maxy
    function queryDropZone(){
        maxy=$dropzone.outerHeight()
        maxx=$dropzone.outerWidth()
    }
    queryDropZone()
    console.log(maxx+" "+maxy)
    function poll(){
        $.ajax({
            url:"/api/pictures",
            success:function(data,textStatus,jqXHR){
                if(textStatus=="success"){
                    for(var x=0;x<data.length;x++){
                        var value=data[x]
                        queryDropZone()
                        if(total.indexOf(value.fileName)!=-1){
                            $('#'+value.fileName).offset({top:(value.y/100.0)*maxy,left:(value.x/100.0)*maxx})
                            console.log({top:(value.y/100.0)*maxy,left:(value.x/100.0)*maxx})
                        }
                        else{
                            total.push(value.fileName)
                            console.log({top:(value.y/100.0)*maxy,left:(value.x/100.0)*maxx})
                            $('<img/>', {
                            src: "/api/picture?fileToGet="+value.fileName
                            //style: "position:r;"
                            }).appendTo($dropzone).wrap("<div id="+value.fileName+" style='position:absolute;'></div>").parent().offset({top:(value.y/100.0)*maxy,left:(value.x/100.0)*maxx}).draggable({
                                containment:'parent',
                                cursor:'move',
                                stop:function(event,ui){
                                    $.ajax({
                                        method:"PUT",
                                        url:"/api/picture?fileName="+$(this).attr('id')+"&x="+ui.offset.left*100.0/maxx+"&y="+ui.offset.top*100.0/maxy
                                    })
                                    console.log("&x="+ui.offset.left*100.0/maxx+"&y="+ui.offset.left*100.0/maxy)
                                }
                            }).on('resize',function(){
                                var width=$(this).outerWidth();
                                var height=$(this).outerHeight();
                                console.log(width+" "+height)
                            });
                        }
                    }
                }
            },
            complete:function(jqXHR,textStatus){
                setTimeout(poll,1000)
            }
        })
    }
    poll()
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
        temp=e
        drop(e,0)
        if(e.originalEvent.dataTransfer){
            if(e.originalEvent.dataTransfer.files.length) {
                f=e.originalEvent.dataTransfer.files[0]
                reader.onload=function(arrayBuffer){
                    queryDropZone()
                    $.ajax({
                        method:"POST",
                        url:"/api/picture/?x="+mousex*100/maxx+"&y="+mousey*100/maxy,
                        data:arrayBuffer.target.result,
                        processData:false,
                        contentType:"application/binary",
                    })
                    console.log("/api/picture/?x="+mousex*100/maxx+"&y="+mousey*100/maxy)
                }
                reader.readAsArrayBuffer(f);
            }
        }
    })
})