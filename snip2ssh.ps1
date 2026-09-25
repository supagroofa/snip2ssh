# One-shot "snip and upload": open the Windows snipping overlay, wait for the
# screenshot, upload it over scp and put the remote path on the clipboard.
# Nothing keeps running: the script exits after the upload (or the timeout).
# Companion to clip2ssh.ps1, which uploads an image already on the clipboard.
#
# Usage (needs an STA thread; PowerShell 7 does not default to it):
#   powershell -STA -File snip2ssh.ps1 -Target user@host
# The host can also come from the SNIP2SSH_HOST environment variable.
# scp must work without a password prompt (SSH key or agent).
# NOTE: the clipboard is cleared before the snip starts.
param(
    [string]$Target = $env:SNIP2SSH_HOST,   # user@host or an ssh config alias
    [string]$RemoteDir = '/tmp',
    [int]$TimeoutSeconds = 30               # how long to wait for the snip
)
if (-not $Target) { Write-Error 'No host: pass -Target user@host or set SNIP2SSH_HOST'; exit 1 }
Add-Type -AssemblyName System.Windows.Forms, System.Drawing

try { [System.Windows.Forms.Clipboard]::Clear() } catch { }   # so only a new snip counts

Start-Process 'ms-screenclip:'   # same overlay as Win+Shift+S

$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
while (-not [System.Windows.Forms.Clipboard]::ContainsImage()) {
    if ((Get-Date) -gt $deadline) { Write-Error 'No snip within the timeout'; exit 1 }
    Start-Sleep -Milliseconds 200
}
Start-Sleep -Milliseconds 300   # let the snipping tool finish writing the clipboard

$img = [System.Windows.Forms.Clipboard]::GetImage()
if (-not $img) { Write-Error 'Could not read the snip from the clipboard'; exit 1 }

$name = "clip-$(Get-Date -Format yyyyMMdd-HHmmss).png"
$tmp  = Join-Path $env:TEMP $name
$img.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)

scp -q $tmp "${Target}:${RemoteDir}/$name"
if ($LASTEXITCODE -ne 0) { Remove-Item $tmp; Write-Error 'scp failed'; exit 1 }

Set-Clipboard -Value "$RemoteDir/$name"   # remote path, ready to paste
Remove-Item $tmp
Write-Host "Uploaded. Path on clipboard: $RemoteDir/$name"
