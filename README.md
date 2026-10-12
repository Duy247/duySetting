# duySetting

A Windows terminal development setup for hobby projects: Windows Terminal,
PowerShell, Yazi and Neovim with LazyVim. Browse files, edit code, follow
definitions, inspect diagnostics and open links without switching editors.

## Included

- LazyVim configuration and plugin lockfile.
- Language support for Python, TypeScript/JavaScript, Java, C/C++, Markdown,
  JSON and CMake, with formatters, linters and debugging plugins.
- Yazi opens text/code files in blocking Neovim sessions; `yazi.nvim` embeds
  the file picker inside the current editor.
- PowerShell `y` function returns to the directory visited in Yazi, plus
  `vim`/`vi` aliases, zoxide integration and history completion.
- Windows Terminal starts maximized, uses an available font, and keeps
  Ctrl+V available to terminal applications.
- Installer backs up existing configurations and merges Terminal settings.

This repository contains configuration, not application binaries, plugin caches,
Mason packages, project files, credentials or PowerToys account settings.

## Prerequisites

Use Windows 11 and PowerShell 7. Install applications from their official
sources or with WinGet. These commands install applications but do not install
every language runtime or compiler:

```powershell
winget install --id Microsoft.PowerShell --exact
winget install --id Microsoft.WindowsTerminal --exact
winget install --id Git.Git --exact
winget install --id Neovim.Neovim --exact
winget install --id sxyazi.yazi --exact
winget install --id BurntSushi.ripgrep.MSVC --exact
winget install --id sharkdp.fd --exact
winget install --id junegunn.fzf --exact
winget install --id ajeetdsouza.zoxide --exact
winget install --id GitHub.cli --exact
```

Also install Node.js/npm, Python, a Java JDK compatible with the installed
JDTLS, a C/C++ compiler, and tree-sitter CLI for your languages. LazyVim
currently requires Neovim 0.11.2 or later. Mason installs editor tooling;
it does not replace your project's compiler or runtime.

For icons, install **0xProto Nerd Font Mono** from
[Nerd Fonts](https://github.com/ryanoasis/nerd-fonts/releases).
Restart Terminal after installation. The installer falls back to another
installed font if 0xProto is unavailable.

## Install

Run from a regular PowerShell 7 session in Windows Terminal. Close Neovim/Yazi
before replacing their configuration.

```powershell
git clone https://github.com/Duy247/duySetting.git
cd duySetting
pwsh -NoProfile -File .\scripts\Install.ps1
```

The installer targets `%LOCALAPPDATA%\nvim`, `%APPDATA%\yazi\config`,
PowerShell AllHosts profiles and stable Windows Terminal settings. Existing
Neovim/Yazi configurations are moved intact into a timestamped backup under
`%LOCALAPPDATA%\duySetting\backups`. Existing shell profile content is retained;
a marked block loads the shared profile. Terminal profiles/settings are merged.
Terminal Preview installations can use `-SkipTerminal` and apply the included
Terminal template manually.

Open a new Terminal window and start `nvim`. Allow Lazy and Mason to finish
downloading plugins and language tools. The lockfile records plugin revisions;
Mason tools and application versions are not pinned by this repository.

```powershell
pwsh -File .\scripts\Check.ps1
```

Inside Neovim, run `:checkhealth` and `:Mason`. Missing optional providers are
only required when a plugin uses them. Run and debug configuration may still
be needed for each project.

To inspect the install without touching your live setup:

```powershell
pwsh -NoProfile -File .\scripts\Install.ps1 -TargetRoot .\.local\preview
pwsh -NoProfile -File .\scripts\Check.ps1 -TargetRoot .\.local\preview
```

## Daily use

| Action | Command/key |
| --- | --- |
| Browse and return to visited folder | `y` |
| Browse without shell directory integration | `yazi` |
| Edit selected text/code in Yazi | Enter or `e` |
| Choose an opener in Yazi | Shift+O |
| Quit Yazi and return directory | `q` |
| Quit Yazi without changing directory | Shift+Q |
| Yazi at current file inside Neovim | Space, `e` |
| Yazi at working directory | Space, Shift+E |
| Resume embedded Yazi | Space, `f`, `y` |
| Go to definition | `gd` or Ctrl+left click |
| Return from definition | Ctrl+O or Ctrl+right click |
| Open URL/file under cursor | `gx` |
| Read full diagnostic | Space, `c`, `d` |
| Next/previous diagnostic | `]d` / `[d` |
| Toggle diagnostic display | Space, `u`, `d` |
| Clipboard paste through Terminal | Ctrl+Shift+V |

These editor shortcuts use normal mode; press Esc first. Inside embedded Yazi,
selection returns to the existing Neovim instance.

## PowerToys launcher

PowerToys is optional. Enable **PowerToys Run**, enable startup, and set its
activation shortcut to **Alt+Space** in PowerToys Settings. A configured shortcut
does not work if the module or PowerToys itself is disabled. This repository
does not overwrite the rest of your PowerToys settings.

## Troubleshooting

- **Yazi offers VS Code:** restart Yazi from a new Terminal tab; check
  `$env:YAZI_CONFIG_HOME` and run the check script.
- **Font warning:** install the named font or rerun the installer to choose an
  available fallback. Nerd Font family names must match Windows exactly.
- **Definition navigation fails:** inspect `:LspInfo` and `:Mason`, open the
  project root and verify its runtime/build dependencies. C++ projects often
  need `compile_commands.json`.
- **Inline diagnostic is cut off:** Space `c d` opens a wrapped diagnostic popup.
- **Shell tools missing:** open a new Terminal window after installation.
- **Restore:** close affected applications, move the installed nvim/Yazi config
  aside, and copy its matching backup to the original location. Restore Terminal
  settings from `terminal-settings.json`, and shell profiles from the named
  profile backups. Keep the backups until the restored setup works.

## Validation and limits

The source machine passed definition navigation checks for Python, TypeScript,
C++ and Java, native link opening, both standalone and embedded Yazi editing,
the `y` directory wrapper, and parser/highlight checks for seven languages.
Those results validate the source setup, not every Windows machine. The new
installer is tested against an isolated directory, including repeated installs
and preservation of existing Terminal settings. Debugging and Java test adapters
still need project-level validation.

## Credits and license

Based on [LazyVim](https://github.com/LazyVim/LazyVim) and its starter, with
[Yazi](https://github.com/sxyazi/yazi) and
[yazi.nvim](https://github.com/mikavilpas/yazi.nvim).
Repository configuration is provided under Apache-2.0; see LICENSE and NOTICE.
External applications, fonts and plugins retain their own licenses.
