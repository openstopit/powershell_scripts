
function Get-PasswordExpirationDate {
    $user = [ADSI]"WinNT://$env:USERDOMAIN/$env:USERNAME,user"
    $passwordExpireDate = $user.PasswordExpirationDate

    if ($passwordExpireDate -eq $null) {
        return "Password does not expire."
    }
    else {        
        $passwordExpireDateTime = [DateTime]$passwordExpireDate
        return $passwordExpireDateTime
    }
}

# Function to check if password will expire within 30 days
function Check-PasswordExpiration {
    $passwordExpirationDate = Get-PasswordExpirationDate
    $today = Get-Date
    $notificationDate = $today.AddDays(30)

    if ($passwordExpirationDate -le $notificationDate) {
        $daysLeft = ($passwordExpirationDate - $today).Days
        if ($daysLeft -gt 0) {
            return "Your password will expire in $daysLeft days!"
        }
        else {
            return "Your password has expired."
        }
    }
    else {
        return $null
    }
}

$passwordExpirationDate = Get-PasswordExpirationDate

$notification = Check-PasswordExpiration


$computerName = $env:COMPUTERNAME


$domainName = (Get-WmiObject Win32_ComputerSystem).Domain


$ipAddress = Test-Connection -ComputerName $computerName -Count 1 | Select-Object -ExpandProperty IPV4Address


$username = $env:USERNAME


$text = @"
Computer Name: $computerName
Domain Name: $domainName
IP Address: $ipAddress
Username: $username

$notification
"@


Add-Type -AssemblyName System.Drawing


$imagePath = "C:\wallpaper\background.jpg"
$originalImage = [System.Drawing.Image]::FromFile($imagePath)


$desiredWidth = 1920
$desiredHeight = 1080


$ratio = [math]::Min($desiredWidth / $originalImage.Width, $desiredHeight / $originalImage.Height)
$newWidth = [math]::Round($originalImage.Width * $ratio)
$newHeight = [math]::Round($originalImage.Height * $ratio)


$croppedBitmap = New-Object System.Drawing.Bitmap($desiredWidth, $desiredHeight)


$croppedGraphic = [System.Drawing.Graphics]::FromImage($croppedBitmap)


$croppedGraphic.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic


$croppedGraphic.DrawImage($originalImage, 0, 0, $desiredWidth, $desiredHeight)


$originalImage.Dispose()
$croppedGraphic.Dispose()


$font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)


$textBitmap = New-Object System.Drawing.Bitmap($croppedBitmap)


$textGraphic = [System.Drawing.Graphics]::FromImage($textBitmap)


$textSize = $textGraphic.MeasureString($text, $font)


$positionX = $desiredWidth - $textSize.Width - 20
$positionY = 40


$textGraphic.DrawString($text, $font, $brush, $positionX, $positionY)


$modifiedImagePath = "C:\wallpaper\modified_background.png"
$textBitmap.Save($modifiedImagePath, [System.Drawing.Imaging.ImageFormat]::Png)


$textBitmap.Dispose()
$textGraphic.Dispose()

#Write-Host "Image with text overlay saved to: $modifiedImagePath"

# Start-Sleep -Seconds 1

# $regKey = "HKCU:\Control Panel\Desktop"
# Set-ItemProperty -Path $regKey -Name Wallpaper -Value $modifiedImagePath
# rundll32.exe user32.dll, UpdatePerUserSystemParameters
# Write-Host "Desktop background updated successfully."

Write-Host "Image with text overlay saved to: $modifiedImagePath"

# Use .NET to set the wallpaper directly
Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    
    public class Wallpaper {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
        
        public const int SPI_SETDESKWALLPAPER = 0x0014;
        public const int SPIF_UPDATEINIFILE = 0x01;
        public const int SPIF_SENDCHANGE = 0x02;
        
        public static void SetWallpaper(string path) {
            SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
        }
    }
"@

# Set the modified wallpaper using the Wallpaper class
[Wallpaper]::SetWallpaper($modifiedImagePath)
Write-Host "Desktop background updated successfully."
