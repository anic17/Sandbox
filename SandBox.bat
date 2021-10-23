@echo off

if "%~1"=="" (
	echo.Missing arguments. See '%~n0 --help'
	exit /b 1
)

for %%A in (--help /?) do if /i "%%A"=="%~1" goto help


setlocal EnableDelayedExpansion
cd /d "%~dp0"

set fake_computername=1
set fake_username=1


set "__old_username=%username%"
set "__old_temp=%temp%"
:: Create a fake user and computer name
set /a random_name_number=(%random%%%(999999-100000+1))+100000

if "%fake_username%"=="1" (
	set "username=SandBoxUser-%random_name_number%"
)

if "%fake_computername%"=="1" (
	for %%A in (computername userdomain userdomain_roamingprofile) do set "%%A=DESKTOP-%random_name_number%"
	set "logonserver=\\DESKTOP-%random_name_number%"
)

set "user_prof=!userprofile::=!"
set "user_prof=!user_prof:%__old_username%=%username%!"
set "__old_username="

md "fs\temp" > nul 2>&1
md "fs\c\Program Files\Common Files\system" > nul 2>&1
md "fs\c\Program Files (x86)\Common Files\system" > nul 2>&1
md "fs\c\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" > nul 2>&1
for %%A in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
	md "fs\%%A\System Volume Information\Chkdsk" > nul 2>&1
	md "fs\%%A\$Recycle.Bin\S-1-5-18" > nul 2>&1
	<nul set /p ="{01234567-89AB-CDEF-0123-456789ABCDEF}"> "fs\%%A\System Volume Information\IndexerVolumeGuid" 2>nul
	<nul set /p ="ÿ`-'O Q° ª"> "fs\%%A\System Volume Information\WPSettings.dat" 2>nul
)
md "fs\c\Windows\System32\drivers\driverdata" > nul 2>&1
md "fs\c\Users\Public" > nul 2>&1

md "fs\!user_prof!" > nul 2>&1

for %%A in (Desktop Downloads Documents Pictures Videos Favorites Links Music AppData\Local\Temp 
"Appdata\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
) do md "fs\!user_prof!\%%~A" > nul 2>&1


:: Change the path variable to a fake one
for %%A in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
	set "path=!path:%%A:=%~dp0fs\%%A!"
)



for %%A in (
	"appdata,!user_prof!\Appdata\Roaming" "localappdata,!user_prof!\Appdata\Local" "windir,c\Windows" "systemroot,c\Windows" "temp,!user_prof!\Appdata\Local\Temp" "tmp,!user_prof!\Appdata\Local\Temp"
	"programfiles,c\Program Files" "programfiles(x86),c\Program Files (x86)" "systemdrive,C" "allusersprofile,c\ProgramData" "homepath,!user_prof!"
	"homedrive,C" "driverdata,c\Windows\System32\drivers\driverdata" "userprofile,!user_prof!"
	"commonprogramfiles,c\Program Files\Common Files" "commonprogramfiles(x86),c\Program Files (x86)\Common Files"
	"CommonProgramW6432,c\Program Files\Common Files", "CommonProgramFiles,c\Program Files\Common Files"
) do (
	for /f "tokens=1,2 delims=," %%X in ("%%A") do (
		set "%%~X=%~dp0fs\%%~Y"
	)
)

for %%A in (
"os,Windows_NT"
"sessionname,Console_SandBox"
) do (
	for /f "tokens=1,2 delims=," %%X in ("%%A") do (
		set "%%~X=%%~Y"
	)
)

set > "%__old_temp%\sandbox.%random_name_number%.tmp"
for /f "usebackq delims=" %%A in ("%__old_temp%\sandbox.%random_name_number%.tmp") do (
	set "__temp=%%A"
	set "__temp=!__temp:"=!"
	set !__temp!
)
set __temp=
del "%__old_temp%\sandbox.%random_name_number%.tmp" /q > nul 2>&1

set "__old_temp="

echo.[Saving old tree files] 1>&2
dir /s /b "%~dp0fs" > "%~dp0fs\temp\index1"


echo.[Sandboxing "%~f1"] 1>&2
if "%fake_computername%"=="1" echo.[Using fake computer name !computername!] 1>&2
if "%fake_username%"=="1" echo.[Using fake user name !username!] 1>&2

echo.

:: Need to have this in an isolated space
setlocal DisableDelayedExpansion

pushd "%~dp1"
%*
popd
echo.[Process exited with error code %errorlevel%] 1>&2
echo.[Saving new tree files] 1>&2
dir /s /b "%~dp0fs" > "%~dp0fs\temp\index2"
fc "%~dp0fs\temp\index1" "%~dp0fs\temp\index2" > nul 2>&1 && (
	echo.[No file system activity detected]
) || (
	echo.[File system modification detected]
)
endlocal 

endlocal
exit /b %errorlevel%


:help
echo.
echo.Batch sandbox
echo.
echo.Usage:
echo.
echo.sandbox ^<file^>
echo.
echo.Example:
echo.
echo.sandbox "script.bat"
echo.Will sandbox and run the file script.bat
echo.
echo.Sandbox works by changing every path environment variable to a fake
echo.file system located on the directory 'fs' where the sandbox is being runned
echo.Doesn't work will full paths yet.
echo.
echo.Copyright ^(c^) 2021 anic17 Software
exit /b 0
