@echo off
setlocal

set "VSDEVCMD=C:\Program Files\Microsoft Visual Studio\18\Enterprise\Common7\Tools\VsDevCmd.bat"
set "CMAKE_EXE=C:\Program Files\Microsoft Visual Studio\18\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
set "CTEST_EXE=C:\Program Files\Microsoft Visual Studio\18\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\ctest.exe"

call "%VSDEVCMD%" -arch=x64 -host_arch=x64 >nul
if errorlevel 1 exit /b %errorlevel%

"%CMAKE_EXE%" --build out/build/x64-Debug --config Debug
if errorlevel 1 exit /b %errorlevel%

"%CTEST_EXE%" --test-dir out/build/x64-Debug --output-on-failure -C Debug
exit /b %errorlevel%
