param(
  [Parameter(Mandatory = $true)][string]$Name,
  [int]$SettleMs = 2500
)

# Captures a screenshot from the connected device into .\screenshots\<Name>.png
$ErrorActionPreference = 'Stop'
$serial = (adb devices | Select-String -Pattern '^\S+\s+device$' | Select-Object -First 1)
if (-not $serial) { throw 'No adb device connected.' }

$dir = Join-Path $PSScriptRoot '..\screenshots'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$remote = "/sdcard/__shot.png"
$local = Join-Path $dir "$Name.png"

Start-Sleep -Milliseconds $SettleMs
adb shell screencap -p $remote | Out-Null
adb pull $remote $local | Out-Null
adb shell rm $remote | Out-Null
Write-Output "saved $local"
