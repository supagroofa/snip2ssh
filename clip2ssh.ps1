# Upload the screenshot that is already on the Windows clipboard to a remote
# host over scp, then put the remote path on the clipboard.
#
# Usage (needs an STA thread; PowerShell 7 does not default to it):
#   powershell -STA -File clip2ssh.ps1 -Target user@host
# The host can also come from the SNIP2SSH_HOST environment variable.
# scp must work without a password prompt (SSH key or agent).
param(
    [string]$Target = $env:SNIP2SSH_HOST,   # user@host or an ssh config alias
    [string]$RemoteDir = '/tmp'
)
if (-not $Target) { Write-Error 'No host: pass -Target user@host or set SNIP2SSH_HOST'; exit 1 }
Add-Type -AssemblyName System.Windows.Forms, System.Drawing

$img = [System.Windows.Forms.Clipboard]::GetImage()
if (-not $img) { Write-Error 'No image on the clipboard'; exit 1 }

$name = "clip-$(Get-Date -Format yyyyMMdd-HHmmss).png"
$tmp  = Join-Path $env:TEMP $name
$img.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)

scp -q $tmp "${Target}:${RemoteDir}/$name"
if ($LASTEXITCODE -ne 0) { Remove-Item $tmp; Write-Error 'scp failed'; exit 1 }

Set-Clipboard -Value "$RemoteDir/$name"   # remote path, ready to paste
Remove-Item $tmp
Write-Host "Uploaded. Path on clipboard: $RemoteDir/$name"
