# Refresh persisted tool paths even when Terminal was started before installation.
$persistedPaths = ([Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')).Split(';')
$extraPaths = $env:Path.Split(';') | Where-Object { $_ -and $persistedPaths -notcontains $_ }
$env:Path = (@($persistedPaths | Where-Object { $_ }) + @($extraPaths)) -join ';'
if ($env:VIRTUAL_ENV) {
  $env:Path = (Join-Path $env:VIRTUAL_ENV 'Scripts') + ';' + $env:Path
}
if ($PSVersionTable.PSEdition -eq 'Core') { $env:NVIM_POWERSHELL = Join-Path $PSHOME 'pwsh.exe' }

# Terminal editing environment, shared by PowerShell hosts.
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
$env:YAZI_CONFIG_HOME = Join-Path $env:APPDATA 'yazi\config'
$gitFile = Join-Path $env:ProgramFiles 'Git\usr\bin\file.exe'
if (Test-Path -LiteralPath $gitFile) { $env:YAZI_FILE_ONE = $gitFile }
$realpath = Join-Path $env:ProgramFiles 'Git\usr\bin\realpath.exe'
if (Test-Path -LiteralPath $realpath) { $env:DUY_REALPATH = $realpath }
Set-Alias -Name vim -Value nvim
Set-Alias -Name vi -Value nvim

# Return to the directory visited in Yazi. Q exits without changing directory.
function y {
  $yaziCwdFile = [IO.Path]::GetTempFileName()
  try {
    & yazi.exe @args "--cwd-file=$yaziCwdFile"
    $yaziDirectory = [IO.File]::ReadAllText($yaziCwdFile).TrimEnd([char]0, [char]13, [char]10)
    if ($yaziDirectory -and (Test-Path -LiteralPath $yaziDirectory -PathType Container)) {
      Set-Location -LiteralPath $yaziDirectory
    }
  } finally { Remove-Item -LiteralPath $yaziCwdFile -ErrorAction SilentlyContinue }
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& zoxide init powershell | Out-String)
}
if (Get-Module -ListAvailable PSReadLine) {
  Import-Module PSReadLine
  Set-PSReadLineOption -EditMode Windows
  Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
  Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
}
