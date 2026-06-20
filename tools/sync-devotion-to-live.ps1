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

.PARAMETER BackupRoot
    Directory where non-dry-run syncs create a timestamped copy of the live
    Devotion artifacts before writing. Defaults to generated/live-devotion-backups.

.EXAMPLE
    .\tools\sync-devotion-to-live.ps1
    .\tools\sync-devotion-to-live.ps1 -DryRun
    .\tools\sync-devotion-to-live.ps1 -DevotionRoot "E:\Games\Devotion"
#>

[CmdletBinding()]
param(
    [string]$DevotionRoot = "D:\Wabbajack\modlists\Anvil\mods\Devotion",
    [string]$BackupRoot = "",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ([string]::IsNullOrWhiteSpace($BackupRoot)) {
    $BackupRoot = Join-Path $RepoRoot "generated\live-devotion-backups"
}

$Map = @(
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\app.js";     Dst = "PrismaUI\views\Devotion\app.js" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\index.html"; Dst = "PrismaUI\views\Devotion\index.html" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\styles.css"; Dst = "PrismaUI\views\Devotion\styles.css" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\fonts\IMFellEnglish-Italic.ttf"; Dst = "PrismaUI\views\Devotion\fonts\IMFellEnglish-Italic.ttf" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\fonts\IMFellEnglish-Italic.woff2"; Dst = "PrismaUI\views\Devotion\fonts\IMFellEnglish-Italic.woff2" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\fonts\IMFellEnglish-Regular.ttf"; Dst = "PrismaUI\views\Devotion\fonts\IMFellEnglish-Regular.ttf" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\fonts\IMFellEnglish-Regular.woff2"; Dst = "PrismaUI\views\Devotion\fonts\IMFellEnglish-Regular.woff2" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\fonts\OFL-IMFellEnglish.txt"; Dst = "PrismaUI\views\Devotion\fonts\OFL-IMFellEnglish.txt" },
    @{ Src = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_RaceMap.json";       Dst = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_RaceMap.json" },
    @{ Src = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_TemporaryRaceMap.json"; Dst = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_TemporaryRaceMap.json" },
    @{ Src = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_RaceMap_README.txt"; Dst = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_RaceMap_README.txt" }
)

Write-Host "Repo root   : $RepoRoot"
Write-Host "Devotion    : $DevotionRoot"
Write-Host "Backup root : $BackupRoot"
if ($DryRun) {
    Write-Host "MODE        : DRY RUN (no files written)" -ForegroundColor Yellow
}
Write-Host ""

function Fail-Sync {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}

function Assert-LiveDevotionRootHealthy {
    param([string]$Root)

    if (-not (Test-Path -LiteralPath $Root)) {
        Fail-Sync "Devotion root not found: $Root. This script copies into an existing live mod only."
    }

    $resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
    $espPath = Join-Path $resolvedRoot "Devotion.esp"
    if (-not (Test-Path -LiteralPath $espPath)) {
        Fail-Sync "Devotion.esp is missing from $resolvedRoot. Refusing to write into an empty or damaged live mod."
    }

    $esp = Get-Item -LiteralPath $espPath
    if ($esp.Length -lt 1024) {
        Fail-Sync "Devotion.esp is unexpectedly small ($($esp.Length) bytes). Refusing to overwrite around a damaged primary plugin."
    }

    $fileCount = (Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
    if ($fileCount -lt 3) {
        Fail-Sync "Live Devotion folder has only $fileCount file(s). Refusing to treat this as a healthy live mod."
    }

    return $resolvedRoot
}

function Copy-IfPresent {
    param(
        [string]$Root,
        [string]$RelativePath,
        [string]$BackupDir
    )

    $source = Join-Path $Root $RelativePath
    if (-not (Test-Path -LiteralPath $source)) {
        return
    }

    $destination = Join-Path $BackupDir $RelativePath
    $destinationParent = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $destinationParent)) {
        New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
    }

    Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force
}

function New-LiveDevotionBackup {
    param(
        [string]$Root,
        [string]$DestinationRoot
    )

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupDir = Join-Path $DestinationRoot "pre-sync-$stamp"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

    Copy-IfPresent $Root "Devotion.esp" $backupDir
    Copy-IfPresent $Root "Seq" $backupDir
    Copy-IfPresent $Root "Scripts" $backupDir
    Copy-IfPresent $Root "SKSE\Plugins\StorageUtilData\PlayerDevotion" $backupDir
    Copy-IfPresent $Root "PrismaUI\views\Devotion" $backupDir

    $backupEsp = Join-Path $backupDir "Devotion.esp"
    if (-not (Test-Path -LiteralPath $backupEsp)) {
        Fail-Sync "Live backup did not capture Devotion.esp; refusing to continue."
    }

    return $backupDir
}

$DevotionRoot = Assert-LiveDevotionRootHealthy $DevotionRoot

if (-not $DryRun) {
    $backupPath = New-LiveDevotionBackup $DevotionRoot $BackupRoot
    Write-Host "BACKUP: $backupPath" -ForegroundColor Cyan
    Write-Host ""
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

$postSyncEsp = Join-Path $DevotionRoot "Devotion.esp"
if (-not (Test-Path -LiteralPath $postSyncEsp)) {
    Fail-Sync "Devotion.esp disappeared during sync. Check the backup before launching MO2."
}

Write-Host ""
Write-Host "Done. $copied file(s) handled, $missing missing." -ForegroundColor Cyan
if ($touchedPsc -and -not $DryRun) {
    Write-Host "REMINDER: a .psc was synced - compile it in the Creation Kit before launching." -ForegroundColor Yellow
}
