
$(function(){
    var $dropzone=$('#dropzone')
    var mousex,mousey;
    var reader = new FileReader();
    var lastFile=-1
    var total=[]
    //$('#img').draggable({containment:'parent'})
    function poll(){
        $.ajax({
            url:"/api/pictures",
            //data:{'lastFile':lastFile},
            success:function(data,textStatus,jqXHR){
                if(textStatus=="success"){
                    //$('#img').attr('src',data)
                    //console.log(jqXHR.getAllResponseHeaders())
                    //var temp=jqXHR.getResponseHeader("fileName")
                    //if(temp)
                    //    fileName=temp
                    for(var x=0;x<data.length;x++){
                        var value=data[x]
                        if(total.indexOf(value.fileName)!=-1){
                            $('#'+value.fileName).offset({top:value.x,left:value.y})
                        }
                        else{
                            total.push(value.fileName)
                            $('<img/>', {
                            id: value.fileName,
                            src: "/api/picture?fileToGet="+value.fileName,
                            //title: 'Become a Googler',
                            //rel: 'external',
                            //text: 'Go to Google!'
                        }).appendTo($dropzone).offset({top:value.x,left:value.y}).draggable({containment:'parent'});
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
        drop(e,0)
        if(e.originalEvent.dataTransfer){
            if(e.originalEvent.dataTransfer.files.length) {
                //console.log(e.originalEvent.dataTransfer.files);
                f=e.originalEvent.dataTransfer.files[0]
                reader.onload=function(dataURL) {
                    //$('#img').attr('src',reader.result)

                    reader.onload=function(arrayBuffer){
                        $.ajax({
                            method:"POST",
                            url:"/api/picture/?x="+mousex+"&y="+mousey,
                            data:arrayBuffer.target.result,
                            processData:false,
                            contentType:"application/binary"
                        })
                    }
                    reader.readAsArrayBuffer(f);
                }
                reader.readAsDataURL(f);

            }
        }
    })
    //$('#img').draggable();
})