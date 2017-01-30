@echo off
setlocal enabledelayedexpansion

rem Build Dr. MinGW

echo build.cmd: Building Dr. MinGW
call thirdparty\drmingw_build_mingw.cmd
if errorlevel 1 exit /b 1

rem Find MSBuild

if not defined MSBUILD for %%a in (msbuild.exe) do if not [%%~$PATH:a] == [] set MSBUILD=%%~$PATH:a
if not defined MSBUILD if exist "%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe" set MSBUILD=%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe
if not defined MSBUILD if exist "%ProgramFiles(x86)%\MSBuild\12.0\Bin\MSBuild.exe" set MSBUILD=%ProgramFiles(x86)%\MSBuild\12.0\Bin\MSBuild.exe
if not defined MSBUILD if exist %WinDir%\Microsoft.NET\Framework64\v4.0.30319\msbuild.exe set MSBUILD=%WinDir%\Microsoft.NET\Framework64\v4.0.30319\msbuild.exe
if not defined MSBUILD echo build.cmd: Can't find msbuild! & exit /b 1
echo build.cmd: Found msbuild at: %MSBUILD%

rem Build Very Sleepy

if not defined CONFIGURATION set CONFIGURATION=Release

for %%p in (Win32 x64) do (
	set PLATFORM=%%p

	echo build.cmd: Building !CONFIGURATION! ^| !PLATFORM!

	rem For some inane reason, the MSBuild on AppVeyor machines
	rem fails to configure the library search path for x64 builds.
	rem This results in errors such as:
	rem LINK : fatal error LNK1181: cannot open input file 'comctl32.lib'
	rem For an example build that fails in this manner, see:
	rem https://ci.appveyor.com/project/CyberShadow/verysleepy/build/1.0.10
	rem As a workaround, call SetEnv manually before invoking MSBuild.
	if defined APPVEYOR if !PLATFORM! == Win32 call "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /!CONFIGURATION! /x86
	if defined APPVEYOR if !PLATFORM! == x64   call "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /!CONFIGURATION! /x64

	"%MSBUILD%" /p:Configuration="!CONFIGURATION! - Wow64" /p:Platform=!PLATFORM! sleepy.sln
	if errorlevel 1 exit /b 1

	"%MSBUILD%" /p:Configuration=!CONFIGURATION! /p:Platform=!PLATFORM! sleepy.sln
	if errorlevel 1 exit /b 1
)

echo build.cmd: Done!
