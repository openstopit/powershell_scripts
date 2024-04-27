# Create desired folder for company wallpaper
    mkdir c:\wallpaper
# Copy wallpaper and rename background.jpg
    Copy-Item "C:\photos\wallpapers\photos_wallpaper.jpg" -Destination "C:\wallpaper"
    Rename-Item -Path "c:\wallpaper\photos_wallpaper.jpg" -NewName "background.jpg"

# Copy script to the scripts folder
    mkdir c:\ps_scripts
    Copy-Item "C:\users\user\Desktop\password_notification.ps1" -Destination "C:\ps_scripts"

# Run Script in powershell:
    powershell -ExecutionPolicy Bypass -File C:\ps_scripts\password_notification.ps1

# create auto-run script on user login:
    Win + R
    taskschd.msc
    Create Basic Task
        Give your task a name and description
        Choose "When I log on" as the trigger
        Select "Start a program" as the action    
        powershell.exe -ExecutionPolicy Bypass -File "C:\ps_scripts\password_notification.ps1"
    Finish
