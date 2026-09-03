@echo off

:: Windows 11 29H1 Disable Notifications
:: Optimized for 25H2 to 29H1 transformation

:: Check for 29H1 mode
reg query "HKLM\SOFTWARE\AtlasOS" /v "29H1_Mode" > nul 2>&1 && (
    echo 29H1 Mode detected - Disabling notifications for 29H1
)

@echo off

:: 29H1: Registry changes
echo Disabling 29H1 notification registry settings...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" /v "Value" /t REG_SZ /d "Deny" /f > nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND" /t REG_DWORD /d "0" /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f > nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoCloudApplicationNotification" /t REG_DWORD /d "1" /f > nul

:: 29H1: Hide Settings pages
echo Hiding 29H1 Settings pages...
for %%a in (
	"notifications"
	"privacy-notifications"
) do (
	call "%windir%\29H1AtlasModules\Scripts\settingsPages.cmd" /hide %%~a /silent
)

:: 29H1: Disable notification center
echo Disabling 29H1 notification center...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "1" /f > nul

:: 29H1: Disable notification services
echo Disabling 29H1 notification services...
sc config WpnService start=disabled > nul
sc stop WpnService > nul 2>&1
call "%windir%\29H1AtlasModules\Scripts\setSvc.cmd" "WpnUserService" 4
for /f "tokens=5 delims=\" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" ^| find "WpnUserService_"') do (
	call "%windir%\29H1AtlasModules\Scripts\setSvc.cmd" "%%a" 4
	sc stop "%%a" > nul
	sc delete "%%a" > nul
)

:: Set 29H1 notifications disabled flag
reg add "HKLM\SOFTWARE\AtlasOS" /v "29H1_Notifications_Disabled" /t REG_DWORD /d "1" /f > nul 2>&1

echo 29H1 Notifications disabled