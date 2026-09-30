@echo off
set PATH=C:\msys64\mingw64\bin;%PATH%
set BLOOM_NO_SINGLE_INSTANCE=1
cd /d "%~dp0build"
Bloom.exe
echo EXIT=%ERRORLEVEL%
pause
