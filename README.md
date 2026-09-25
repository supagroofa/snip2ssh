# snip2ssh

Take a screenshot on Windows and get it onto a remote Linux/macOS box in one
keystroke, with the remote path on your clipboard. Built for pasting screenshots
into terminal tools such as Claude Code running over SSH: paste the path and the
tool attaches the image.

Two small PowerShell scripts, nothing runs in the background:

| Script | What it does |
|---|---|
| `snip2ssh.ps1` | Opens the snipping overlay, waits for your snip, uploads it, puts the remote path on the clipboard |
| `clip2ssh.ps1` | Uploads the image already on the clipboard (e.g. after `Win+Shift+S`) |

## Setup

1. Make sure `scp` works to your host **without a password prompt** (SSH key or agent).
2. Clone this repo, then run once (`-Desktop` adds Desktop shortcuts too):

   ```powershell
   powershell -File install-shortcuts.ps1 -Target user@host -Desktop
   ```

   This creates Start Menu shortcuts with hotkeys: **Ctrl+Alt+X** snip and upload,
   **Ctrl+Alt+S** upload the clipboard image.

Or run a script directly:

```powershell
powershell -STA -File snip2ssh.ps1 -Target user@host
```

The host can also be set once with the `SNIP2SSH_HOST` environment variable.
Other parameters: `-RemoteDir` (default `/tmp`), `-TimeoutSeconds` (snip only, default 30).

## Icon

The shortcuts use `snip2ssh.ico` (a green `>` that doubles as scissors, with a `_` cursor). To use your own,
pass any `file.dll,index` or a path to a `.ico`:

```powershell
powershell -File install-shortcuts.ps1 -Target user@host -Desktop -Icon "C:\icons\party-parrot.ico"
```

Browse the built-in icons via a shortcut's *Properties → Change Icon* (try `shell32.dll` or `imageres.dll`).

## Caveats

- The Windows clipboard holds one item. If you copy text between taking the screenshot and running `clip2ssh`, the image is gone.
- `snip2ssh` clears the clipboard before the snip starts.
- Scripts need an STA thread (`-STA`), which the shortcuts set for you.
- Shortcuts run hidden, so errors are not shown; run the script in a console to debug.
- Uploads land in `/tmp` by default (world-readable, cleared on reboot). Use `-RemoteDir` for somewhere private, or `chmod 600` the files.
- Tested on Windows 11 with Windows PowerShell 5.1, uploading to Linux. Untested elsewhere.

## Credits

Inspired by [samuellawrentz/clipssh](https://github.com/samuellawrentz/clipssh), which is macOS/Linux only. This is an independent Windows implementation and shares no code with it.

## License

MIT
