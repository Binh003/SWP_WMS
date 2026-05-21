@echo off
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "PATH=%JAVA_HOME%\bin;%PATH%"
cd /d "%~dp0"
call "C:\Program Files\NetBeans-17\netbeans\extide\ant\bin\ant.bat" -noinput clean dist
pause
