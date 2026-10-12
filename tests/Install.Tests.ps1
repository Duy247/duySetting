#Requires -Version 7.0
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$root = Join-Path ([IO.Path]::GetTempPath()) ('duySetting-test-' + [guid]::NewGuid())
$local = Join-Path $root 'LocalAppData'
$terminal = Join-Path $local 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
$profile = Join-Path $root 'Documents\PowerShell\profile.ps1'
$nvim = Join-Path $local 'nvim'
New-Item -ItemType Directory -Path (Split-Path $terminal -Parent), (Split-Path $profile -Parent), $nvim -Force | Out-Null
@{theme='light'; profiles=@{list=@(@{guid='{11111111-1111-1111-1111-111111111111}'; name='Keep me'; hidden=$false})}} | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $terminal
'function customFunction { "preserved" }' | Set-Content -LiteralPath $profile
'original configuration' | Set-Content -LiteralPath (Join-Path $nvim 'original.txt')
& (Join-Path $repo 'scripts\Install.ps1') -TargetRoot $root
$backup = Get-ChildItem -LiteralPath (Join-Path $local 'duySetting\backups') -Directory | Select-Object -First 1
if (-not (Test-Path -LiteralPath (Join-Path $backup.FullName 'nvim\original.txt'))) { throw 'Original config backup missing' }
if (Test-Path -LiteralPath (Join-Path $nvim 'original.txt')) { throw 'Old files mixed into new configuration' }
& (Join-Path $repo 'scripts\Install.ps1') -TargetRoot $root
$settings = Get-Content -LiteralPath $terminal -Raw | ConvertFrom-Json
if ($settings.theme -ne 'light') { throw 'Custom Terminal setting lost' }
if (-not ($settings.profiles.list | Where-Object name -eq 'Keep me')) { throw 'Existing Terminal profile lost' }
if (@($settings.profiles.list | Where-Object name -eq 'PowerShell (Dev)').Count -ne 1) { throw 'Duplicate dev profiles' }
if (@($settings.keybindings | Where-Object keys -eq 'ctrl+v').Count -ne 1) { throw 'Duplicate keybindings' }
$profileContent = Get-Content -LiteralPath $profile -Raw
if ($profileContent -notmatch 'customFunction') { throw 'Custom PowerShell profile lost' }
if ([regex]::Matches($profileContent, '# BEGIN duySetting').Count -ne 1) { throw 'Duplicate profile blocks' }
& (Join-Path $repo 'scripts\Check.ps1') -TargetRoot $root
Write-Host 'PASS: fresh installation, backups, settings preservation, repeated installation and structural checks'
