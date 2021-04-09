@echo off

rem Sets makefile source code for the different platforms
rem Based on fix.bat of Allegro.
rem Modified By Kronoman - In loving memory of my father.
rem Modified By Guillermo "¥u¤o" Mart¡nez.

if [%1] == [dos] goto dos
if [%1] == [dos32] goto dos32
if [%1] == [linux] goto linux
if [%1] == [win] goto win
goto help



:dos
echo Configuring for DOS/FPC...
echo # Warning! This file will be overwritten by configuration routines! > target.os
echo TARGET=DOS>> target.os
goto done



:dos32
echo Configuring for DOS GO32V2/FPC...
echo # Warning! This file will be overwritten by configuration routines! > target.os
echo TARGET=DOS32>> target.os
goto done



:win
echo Configuring for Windows/FPC...
echo # Warning! This file will be overwritten by configuration routines! > target.os
echo TARGET=WIN>> target.os
goto done



:linux
echo Configuring for GNU/Linux...
echo # Warning! This file will be overwritten by configuration routines! > target.os
echo TARGET=LINUX>> target.os
goto done



:help
echo Usage: fix platform
echo.
echo Where platform is one of: dos, dos32, win or linux.
echo.
goto end

:done
echo Done!

:end
