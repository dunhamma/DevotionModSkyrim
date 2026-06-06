<#
.SYNOPSIS
    Copy the repo's tracked Devotion mod files into the live Wabbajack/MO2 mod folder.

.DESCRIPTION
    This repo holds editable copies of the PrismaUI view files and the PDV__ManagerQuest
    Papyrus source, but the game loads them from the Wabbajack mod folder, which is not in
    the repo. After git pull, run this script to push the repo copies to the live path in
    one step.

    The .psc source is COPIED, not compiled. Papyrus must still be compiled in the Creation
    Kit or with the Papyrus compiler after syncing. This script only moves the source.

.PARAMETER DevotionRoot
    Root of the live Devotion mod folder. Edit the default below or pass -DevotionRoot.

.PARAMETER DryRun
    Show what would be copied without writing anything.

.EXAMPLE
    .\tools\sync-devotion-to-live.ps1
    .\tools\sync-devotion-to-live.ps1 -DryRun
    .\tools\sync-devotion-to-live.ps1 -DevotionRoot "E:\Games\Devotion"
#>

[CmdletBinding()]
param(
    [string]$DevotionRoot = "D:\Wabbajack\modlists\Anvil\mods\Devotion",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$Map = @(
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\app.js";     Dst = "PrismaUI\views\Devotion\app.js" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\index.html"; Dst = "PrismaUI\views\Devotion\index.html" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\styles.css"; Dst = "PrismaUI\views\Devotion\styles.css" },
    @{ Src = "scratch\p2-toast-panel-fix\PDV__ManagerQuest.psc";                   Dst = "Scripts\Source\PDV__ManagerQuest.psc" }
)

Write-Host "Repo root   : $RepoRoot"
Write-Host "Devotion    : $DevotionRoot"
if ($DryRun) {
    Write-Host "MODE        : DRY RUN (no files written)" -ForegroundColor Yellow
}
Write-Host ""

if (-not (Test-Path -LiteralPath $DevotionRoot)) {
    Write-Host "ERROR: Devotion root not found: $DevotionRoot" -ForegroundColor Red
    Write-Host "Edit the DevotionRoot default at the top of this script, or pass -DevotionRoot." -ForegroundColor Red
    exit 1
}

$copied = 0
$missing = 0
$touchedPsc = $false

foreach ($entry in $Map) {
    $srcPath = Join-Path $RepoRoot $entry.Src
    $dstPath = Join-Path $DevotionRoot $entry.Dst

    if (-not (Test-Path -LiteralPath $srcPath)) {
        Write-Host "SKIP (missing in repo): $($entry.Src)" -ForegroundColor Yellow
        $missing++
        continue
    }

    $dstDir = Split-Path -Parent $dstPath
    if ($DryRun) {
        Write-Host "WOULD COPY: $($entry.Src)"
        Write-Host "        -> $dstPath"
    } else {
        if (-not (Test-Path -LiteralPath $dstDir)) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }
        Copy-Item -LiteralPath $srcPath -Destination $dstPath -Force
        Write-Host "COPIED: $($entry.Dst)" -ForegroundColor Green
    }

    if ($dstPath -like "*.psc") {
        $touchedPsc = $true
    }
    $copied++
}

Write-Host ""
Write-Host "Done. $copied file(s) handled, $missing missing." -ForegroundColor Cyan
if ($touchedPsc -and -not $DryRun) {
    Write-Host "REMINDER: a .psc was synced - compile it in the Creation Kit before launching." -ForegroundColor Yellow
}
