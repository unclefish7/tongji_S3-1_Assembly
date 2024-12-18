set project=jetshoot

REM 删除旧文件
if exist %project%.obj del %project%.obj
if exist %project%.exe del %project%.exe

ml /c /coff %project%.asm
link /subsystem:console %project%.obj
%project%.exe