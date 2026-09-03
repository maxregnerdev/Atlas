@echo off

:: Windows 11 29H1 Enable Notifications
:: Optimized for 25H2 to 29H1 transformation

:: Check for 29H1 mode
reg query "HKLM\SOFTWARE\AtlasOS" /v "29H1_Mode" > nul 2>&1 && (
    echo 29H1 Mode detected - Enabling notifications for 29H1
)

@echo off

:: 29H1: Revert Registry changes
echo Enabling 29H1 notification registry settings...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /f > nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" /v "Value" /t REG_SZ /d "Allow" /f > nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND" /t REG_DWORD /d "1" /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "1" /f > nul
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoCloudApplicationNotification" /f > nul 2>&1

:: 29H1: Unhide Settings pages
echo Unhiding 29H1 Settings pages...
for %%a in (
	"notifications"
	"privacy-notifications"
) do (
	call "%windir%\29H1AtlasModules\Scripts\settingsPages.cmd" /unhide %%~a /silent
)

:: 29H1: Enable notification services
echo Enabling 29H1 notification services...
call "%windir%\29H1AtlasModules\Scripts\setSvc.cmd" "WpnUserService" 2
sc config WpnService start=auto > nul

:: Set 29H1 notifications enabled flag
reg add "HKLM\SOFTWARE\AtlasOS" /v "29H1_Notifications_Enabled" /t REG_DWORD /d "1" /f > nul 2>&1

echo 29H1 Notifications enabled