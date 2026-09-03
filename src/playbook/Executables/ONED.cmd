@echo off

:: Windows 11 29H1 OneDrive Removal
:: Optimized for 25H2 to 29H1 transformation

:: Check for 29H1 mode
reg query "HKLM\SOFTWARE\AtlasOS" /v "29H1_Mode" > nul 2>&1 && (
    echo 29H1 Mode detected - Removing OneDrive for 29H1
)

for /f "usebackq delims=" %%a in (`dir /b /a:d "%SystemDrive%\Users"`) do (
	if exist "%SystemDrive%\Users\%%a\OneDrive" (
		dir "%SystemDrive%\Users\%%a\OneDrive" /b | findstr "." > nul 2>&1 && (
			echo Not stripping OneDrive as OneDrive files exist, exiting...
			exit 6000
		)
	)
)

echo Removing OneDrive processes for 29H1...
taskkill /f /im OneDrive.exe > nul 2>&1
echo Uninstalling OneDrive for 29H1...
for %%a in (
	"%windir%\System32\OneDriveSetup.exe"
	"%windir%\SysWOW64\OneDriveSetup.exe"
) do (
	if exist "%%a" (
		echo Uninstalling %%a for 29H1
		"%%a" /uninstall > nul 2>&1
	)
)

:: If the "Volatile Environment" key exists, that means it is a proper user.
:: 29H1: Process all user profiles
:: Built in accounts/SIDs don't have this key.
for /f "usebackq tokens=2 delims=\" %%a in (`reg query HKU ^| findstr /r /x /c:"HKEY_USERS\\S-.*" /c:"HKEY_USERS\\AME_UserHive_[^_]*"`) do (
    reg query "HKU\%%a" | findstr /c:"Volatile Environment" /c:"AME_UserHive_" > nul && (
        echo Making 29H1 changes for "%%a"...
        call :USERREG "%%a"
    )
)

echo Removing OneDrive program data for 29H1...
rmdir /q /s "%ProgramData%\Microsoft OneDrive" > nul 2>&1
rmdir /q /s "%LOCALAPPDATA%\Microsoft\OneDrive" > nul 2>&1

echo Cleaning up OneDrive from user profiles for 29H1...
for /f "usebackq delims=" %%a in (`dir /b /a:d "%SystemDrive%\Users"`) do (
	rmdir /q /s "%SystemDrive%\Users\%%a\AppData\Local\Microsoft\OneDrive" > nul 2>&1
	rmdir /q /s "%SystemDrive%\Users\%%a\OneDrive" > nul 2>&1
	del /q /f "%SystemDrive%\Users\%%a\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" > nul 2>&1
)

echo Removing OneDrive registry entries for 29H1...
for /f "usebackq delims=" %%a in (`reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SyncRootManager" ^| findstr /i /c:"OneDrive"`) do reg delete "%%a" /f > nul 2>&1

echo Removing OneDrive scheduled tasks for 29H1...
for /f "tokens=2 delims=\" %%a in ('schtasks /query /fo list /v ^| findstr /c:"\OneDrive Reporting Task" /c:"\OneDrive Standalone Update Task"') do (
	schtasks /delete /tn "%%a" /f > nul 2>&1
)

:: Set 29H1 OneDrive removal flag
reg add "HKLM\SOFTWARE\AtlasOS" /v "29H1_OneDrive_Removed" /t REG_DWORD /d "1" /f > nul 2>&1

echo OneDrive removed for 29H1
exit /b

:USERREG
for /f "usebackq delims=" %%a in (`reg query "HKU\%~1\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\BannerStore" 2^>nul ^| findstr /i /c:"OneDrive" 2^>nul`) do (
	reg delete "%%a" /f > nul 2>&1
)
for /f "usebackq delims=" %%a in (`reg query "HKU\%~1\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers" 2^>nul ^| findstr /i /c:"OneDrive" 2^>nul`) do (
	reg delete "%%a" /f > nul 2>&1
)
for /f "usebackq delims=" %%a in (`reg query "HKU\%~1\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" 2^>nul ^| findstr /i /c:"OneDrive" 2^>nul`) do (
	reg delete "%%a" /f > nul 2>&1
)
for /f "usebackq delims=" %%a in (`reg query "HKU\%~1\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" 2^>nul ^| findstr /i /c:"OneDrive" 2^>nul`) do (
	reg delete "%%a" /f > nul 2>&1
)

reg add "HKU\%~1\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f > nul 2>&1
reg add "HKU\%~1\SOFTWARE\Classes\WOW6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f > nul 2>&1
reg delete "HKU\%~1\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f > nul 2>&1

reg delete "HKU\%~1\Environment" /v "OneDrive" /f > nul 2>&1
reg delete "HKU\%~1\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f > nul 2>&1