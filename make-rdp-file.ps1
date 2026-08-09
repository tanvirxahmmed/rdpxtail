<#
.SYNOPSIS
    Generates a ready-to-open .rdp file from a Tailscale IP + credentials.

.EXAMPLE
    .\make-rdp-file.ps1 -IP 100.64.1.5 -Username runneradmin
#>
param(
    [Parameter(Mandatory)][string]$IP,
    [string]$Username  = "runneradmin",
    [int]   $Width     = 1920,
    [int]   $Height    = 1080,
    [string]$OutFile   = "github-runner.rdp"
)

$rdp = @"
full address:s:$IP
username:s:$Username
screen mode id:i:2
desktopwidth:i:$Width
desktopheight:i:$Height
session bpp:i:32
winposstr:s:0,1,0,0,$Width,$Height
compression:i:1
keyboardhook:i:2
audiocapturemode:i:0
videoplaybackmode:i:1
connection type:i:7
networkautodetect:i:1
bandwidthautodetect:i:1
displayconnectionbar:i:1
enableworkspacereconnect:i:0
disable wallpaper:i:0
allow font smoothing:i:1
allow desktop composition:i:1
disable full window drag:i:1
disable menu anims:i:0
disable themes:i:0
disable cursor setting:i:0
bitmapcachepersistenable:i:1
audiomode:i:0
redirectprinters:i:1
redirectcomports:i:0
redirectsmartcards:i:1
redirectwebauthn:i:1
redirectclipboard:i:1
redirectposdevices:i:0
autoreconnection enabled:i:1
authentication level:i:2
prompt for credentials:i:1
negotiate security layer:i:1
remoteapplicationmode:i:0
alternate shell:s:
shell working directory:s:
gatewayhostname:s:
gatewayusagemethod:i:4
gatewaycredentialssource:i:4
gatewayprofileusagemethod:i:0
promptcredentialonce:i:0
gatewaybrokeringtype:i:0
use redirection server name:i:0
rdgiskdcproxy:i:0
kdcproxyname:s:
"@

$rdp | Out-File -FilePath $OutFile -Encoding ASCII
Write-Host "Created: $OutFile"
Write-Host "Open it with:  Start-Process '$OutFile'"
