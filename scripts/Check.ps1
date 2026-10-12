#Requires -Version 7.0
[CmdletBinding()]
param([string]$TargetRoot)
$ErrorActionPreference = 'Stop'
$local = if ($TargetRoot) { Join-Path ([IO.Path]::GetFullPath($TargetRoot)) 'LocalAppData' } else { $env:LOCALAPPDATA }
$roaming = if ($TargetRoot) { Join-Path ([IO.Path]::GetFullPath($TargetRoot)) 'AppData' } else { $env:APPDATA }
$failed = $false
function Check([string]$Name, [bool]$Passed) {
  if (-not $Passed) { $script:failed = $true }
  [pscustomobject]@{ Check=$Name; Passed=$Passed }
}
if (-not $TargetRoot) {
  foreach ($command in @('git','pwsh','nvim','yazi','rg','fd','fzf','zoxide','node','npm','python','java','tree-sitter')) {
    Check "Executable: $command" ([bool](Get-Command $command -ErrorAction SilentlyContinue))
  }
}
Check 'Neovim init' (Test-Path -LiteralPath (Join-Path $local 'nvim\init.lua'))
Check 'Plugin lockfile' (Test-Path -LiteralPath (Join-Path $local 'nvim\lazy-lock.json'))
$yazi = Join-Path $roaming 'yazi\config\yazi.toml'
Check 'Yazi Neovim opener' ((Test-Path -LiteralPath $yazi) -and ((Get-Content -LiteralPath $yazi -Raw) -match 'nvim %s'))
Check 'Shared PowerShell profile' (Test-Path -LiteralPath (Join-Path $local 'duySetting\profile.ps1'))
$terminal = Join-Path $local 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
if (-not (Test-Path -LiteralPath $terminal)) { $terminal = Join-Path $local 'Microsoft\Windows Terminal\settings.json' }
if (Test-Path -LiteralPath $terminal) {
  $settings = Get-Content -LiteralPath $terminal -Raw | ConvertFrom-Json
  Check 'Terminal maximized' ($settings.launchMode -eq 'maximized')
  Check 'Visible Terminal profile' ([bool]($settings.profiles.list | Where-Object { -not $_.hidden }))
} else { Check 'Terminal settings' $false }
if ($failed) { exit 1 }
