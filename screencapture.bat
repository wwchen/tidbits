start /D"c:\Program Files (x86)\VideoLAN\VLC\" vlc.exe screen:// :screen-fps=25 :sout=#transcode{venc=x264{bframes=0,nocabac,ref=1,nf,level=13,crf=24,partitions=none},vcodec=h264,fps=25,vb=3000,scale=1,acodec=none}:duplicate{dst=std{mux=mp4,access=file,dst=c:\temp\output.mp4}}
