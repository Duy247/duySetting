#Requires -Version 7.0
[CmdletBinding()]
param(
  # Use a separate root to inspect installation without changing your live setup.
  [string]$TargetRoot,
  [switch]$SkipTerminal
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$source = Join-Path $repo 'config'
$isolated = -not [string]::IsNullOrWhiteSpace($TargetRoot)
if ($isolated) {
  $TargetRoot = [IO.Path]::GetFullPath($TargetRoot)
  $local = Join-Path $TargetRoot 'LocalAppData'
  $roaming = Join-Path $TargetRoot 'AppData'
  $documents = Join-Path $TargetRoot 'Documents'
} else {
  if (-not $IsWindows) { throw 'This installer targets Windows. Run it in PowerShell 7 on Windows.' }
  $local = $env:LOCALAPPDATA
  $roaming = $env:APPDATA
  $documents = [Environment]::GetFolderPath('MyDocuments')
  foreach ($command in @('git','nvim','yazi','pwsh')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) { throw "Missing $command. See README.md prerequisites." }
  }
}
$backup = Join-Path $local ('duySetting\backups\' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
New-Item -ItemType Directory -Path $backup -Force | Out-Null
function Backup-File([string]$Path, [string]$Name) {
  if (Test-Path -LiteralPath $Path) { Copy-Item -LiteralPath $Path -Destination (Join-Path $backup $Name) -Recurse -Force }
}
foreach ($entry in @(@{Name='nvim'; Target=(Join-Path $local 'nvim')}, @{Name='yazi'; Target=(Join-Path $roaming 'yazi\config')})) {
  $target = [IO.Path]::GetFullPath($entry.Target)
  $parent = Split-Path $target -Parent
  New-Item -ItemType Directory -Path $parent -Force | Out-Null
  if (Test-Path -LiteralPath $target) {
    # Move the previous config intact; avoid mixing stale plugin files into the new config.
    $allowed = @([IO.Path]::GetFullPath((Join-Path $local 'nvim')), [IO.Path]::GetFullPath((Join-Path $roaming 'yazi\config')))
    if ($target -notin $allowed) { throw "Unexpected configuration target: $target" }
    Move-Item -LiteralPath $target -Destination (Join-Path $backup $entry.Name)
  }
  Copy-Item -LiteralPath (Join-Path $source $entry.Name) -Destination $target -Recurse
}
$sharedProfile = Join-Path $local 'duySetting\profile.ps1'
Backup-File $sharedProfile 'duySetting-profile.ps1'
Copy-Item -LiteralPath (Join-Path $source 'powershell\profile.ps1') -Destination $sharedProfile -Force
foreach ($name in @('PowerShell','WindowsPowerShell')) {
  $profileDirectory = Join-Path $documents $name
  New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
  $profilePath = Join-Path $profileDirectory 'profile.ps1'
  Backup-File $profilePath ($name + '-profile.ps1')
  $content = if (Test-Path -LiteralPath $profilePath) { Get-Content -LiteralPath $profilePath -Raw } else { '' }
  $block = "`n# BEGIN duySetting`n. (Join-Path `$env:LOCALAPPDATA 'duySetting\profile.ps1')`n# END duySetting`n"
  $content = [regex]::Replace([string]$content, '(?ms)^# BEGIN duySetting\r?\n.*?^# END duySetting\r?\n?', '')
  ($content.TrimEnd() + $block) | Set-Content -LiteralPath $profilePath -Encoding utf8
}
if (-not $SkipTerminal) {
  $terminal = Join-Path $local 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
  $unpackaged = Join-Path $local 'Microsoft\Windows Terminal\settings.json'
  if (-not $isolated -and -not (Test-Path -LiteralPath $terminal) -and (Test-Path -LiteralPath $unpackaged)) { $terminal = $unpackaged }
  New-Item -ItemType Directory -Path (Split-Path $terminal -Parent) -Force | Out-Null
  Backup-File $terminal 'terminal-settings.json'
  $template = Get-Content -LiteralPath (Join-Path $source 'terminal\settings.json') -Raw | ConvertFrom-Json -AsHashtable
  $settings = if (Test-Path -LiteralPath $terminal) { Get-Content -LiteralPath $terminal -Raw | ConvertFrom-Json -AsHashtable } else { @{} }
  $settings.launchMode = 'maximized'
  $settings.defaultProfile = $template.defaultProfile
  if (-not $settings.profiles) { $settings.profiles = @{} }
  if (-not $settings.profiles.defaults) { $settings.profiles.defaults = @{} }
  if (-not $settings.profiles.defaults.font) { $settings.profiles.defaults.font = @{} }
  $face = '0xProto Nerd Font Mono'
  if (-not $isolated) {
    Add-Type -AssemblyName System.Drawing
    $fonts = [System.Drawing.Text.InstalledFontCollection]::new()
    $families = @($fonts.Families | ForEach-Object Name)
    if ($face -notin $families) {
      $face = @('JetBrainsMono Nerd Font Mono','Cascadia Mono','Consolas') | Where-Object { $_ -in $families } | Select-Object -First 1
      if (-not $face) { throw 'No supported terminal font found.' }
      Write-Warning "Using $face. Install 0xProto Nerd Font Mono for all icons."
    }
  }
  $settings.profiles.defaults.font.face = $face
  $settings.profiles.defaults.font.size = 12
  $dev = $template.profiles.list[0]
  $shell = if ($isolated) { 'pwsh.exe' } else { Join-Path $PSHOME 'pwsh.exe' }
  $dev.commandline = '"' + $shell + '" -NoLogo'
  $list = @($settings.profiles.list | Where-Object { $_ -and $_.guid -ne $dev.guid })
  $settings.profiles.list = @($list) + @($dev)
  $bindings = @($settings.keybindings | Where-Object { $_ -and $_.keys -notin @('ctrl+v','ctrl+shift+v') })
  $settings.keybindings = @($bindings) + @($template.keybindings)
  $settings | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $terminal -Encoding utf8
}
Write-Host "Configuration installed. Backup: $backup"
Write-Host 'Open a new Terminal window. Launch nvim and let Lazy/Mason install dependencies.'
Write-Host 'Run scripts/Check.ps1 after installation; use :checkhealth inside Neovim.'
