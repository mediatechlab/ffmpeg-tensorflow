Important: the file espcn.model has to be in the same directory as ffmpeg in order for the super resolution filter to work

**ffmpeg super-resolution example**

ffmpeg -i input.MXF -vf yadif=3:0,mcdeint=mode=medium:0:qp=10,colormatrix=bt601:bt709,crop=692:479:9:33,bm3d=sigma=5,sr=dnn_backend=tensorflow:model=espcn.model:scale_factor=2,scale=1920*0.75:1080,pad=1920:1080:"(ow-iw)/2:(oh-ih)/2",setdar=16:9,setsar=1:1,interlace -flags +ildct+ilme -framerate 30000/1001 -movflags write_colr -c:v v210 -color_primaries smpte170m -color_trc bt709 -colorspace smpte170m -color_range mpeg -metadata:s:v:0 "encoder=Uncompressed 10-bit 4:2:2" -f mov -shortest -y output.MOV

In this example the SD file input.MXF is upconverted to a HD uncompressed Quicktime V210 output.MOV file with the following transformations:

yadif=3:0,mcdeint=mode=medium:0:qp=10   -> Deinterlace

colormatrix=bt601:bt709 -> colorspace conversion from SD to HD

crop=692:479:9:33 -> Crop with window size of 692x479 pixels 9 pixels to the right of origin and 33 pixels bellow the origin

bm3d=sigma=5 -> Denoise BM3D with sigma 5, depends on the noise state of the input video

sr=dnn_backend=tensorflow:model=espcn.model:scale_factor=2 -> ESPCN Superresolution with tensorflow doubling effective width and height

scale=1920*0.75:1080,pad=1920:1080:"(ow-iw)/2:(oh-ih)/2",setdar=16:9,setsar=1:1 -> Final rescale to a pillarbox 1920x1080 keeping aspect ratio

interlace -flags +ildct+ilme -framerate 30000/1001 -> intelaced 29.97 output

-movflags write_colr -c:v v210 -color_primaries smpte170m -color_trc bt709 -colorspace smpte170m -color_range mpeg -metadata:s:v:0 "encoder=Uncompressed 10-bit 4:2:2" -f mov -> output Quicktime v210 uncompressed
