# Create Start Menu shortcuts with hotkeys, and optional Desktop shortcuts with
# an icon of your choice. Run once:
#   powershell -File install-shortcuts.ps1 -Target user@host
param(
    [string]$Target = $env:SNIP2SSH_HOST,
    [string]$Icon = "$PSScriptRoot\snip2ssh.ico",                  # Start Menu / taskbar: 'file.dll,index' or a .ico
    [string]$DesktopIcon = "$PSScriptRoot\snip2ssh-desktop.ico",   # Desktop shortcuts (dark tile, reads better on wallpaper)
    [switch]$Desktop                    # also create Desktop shortcuts
)
if (-not $Target) { Write-Error 'No host: pass -Target user@host or set SNIP2SSH_HOST'; exit 1 }

$sh = New-Object -ComObject WScript.Shell
function New-Link($dir, $name, $script, $hotkey, $icon) {
    $lnk = $sh.CreateShortcut((Join-Path $dir "$name.lnk"))
    $lnk.TargetPath  = 'powershell.exe'
    $lnk.Arguments   = "-STA -NoProfile -WindowStyle Hidden -File `"$PSScriptRoot\$script`" -Target `"$Target`""
    $lnk.WindowStyle = 7                      # minimized
    $lnk.IconLocation = $icon
    if ($hotkey) { $lnk.Hotkey = $hotkey }    # only honoured in Start Menu / Desktop
    $lnk.Save()
}

$start = [Environment]::GetFolderPath('Programs')
New-Link $start 'snip2ssh' 'snip2ssh.ps1' 'CTRL+ALT+X' $Icon
New-Link $start 'clip2ssh' 'clip2ssh.ps1' 'CTRL+ALT+S' $Icon
if ($Desktop) {
    $desk = [Environment]::GetFolderPath('Desktop')
    New-Link $desk 'snip2ssh' 'snip2ssh.ps1' $null $DesktopIcon
    New-Link $desk 'clip2ssh' 'clip2ssh.ps1' $null $DesktopIcon
}
Write-Host 'Shortcuts created. Hotkeys: Ctrl+Alt+X = snip and upload, Ctrl+Alt+S = upload clipboard.'
