@echo off
set PATH=C:\msys64\mingw64\bin;%PATH%
set BLOOM_NO_SINGLE_INSTANCE=1
set QT_DEBUG_PLUGINS=0
cd /d "%~dp0build\Desktop_Qt_6_11_1_MinGW_64_bit_Debug"
Bloom.exe > "%~dp0bloom_stdout.log" 2>&1
echo EXIT=%ERRORLEVEL% > "%~dp0bloom_exit.log"
pause
