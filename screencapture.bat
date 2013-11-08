REM This cmd-let starts up VLC and starts video capturing your screen
REM To start recording, execute this bat file. To stop, close VLC.

@echo off set dst=c:\temp\output.mp4
start /D"c:\Program Files (x86)\VideoLAN\VLC\" vlc.exe screen:// :screen-fps=25 :sout=#transcode{venc=x264{bframes=0,nocabac,ref=1,nf,level=13,crf=24,partitions=none},vcodec=h264,fps=25,vb=3000,scale=1,acodec=none}:duplicate{dst=std{mux=mp4,access=file,dst=%dst%}}
