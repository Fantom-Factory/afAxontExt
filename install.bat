
copy C:\Projects\Fantom-Factory\AxontExt\build\afAxontExt.pod C:\Apps\skyspark-3.0.12\var\lib\fan

@echo off
cd C:\Apps\skyspark-3.0.12\bin
set FAN_ENV=
set FAN_HOME=
call fanlaunch.bat Fan skyarcd %*

pause
