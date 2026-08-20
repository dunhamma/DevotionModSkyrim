<#
.SYNOPSIS
    Copy the repo's tracked Devotion mod files into the live Wabbajack/MO2 mod folder.

.DESCRIPTION
    This repo holds editable copies of the PrismaUI view files and core Devotion
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

.PARAMETER Only
    Optional exact source or destination paths from the sync map. Limits a sync
    to the named files while retaining the normal health check and full backup.

.EXAMPLE
    .\tools\sync-devotion-to-live.ps1
    .\tools\sync-devotion-to-live.ps1 -DryRun
    .\tools\sync-devotion-to-live.ps1 -Only "Scripts\Source\PDV_MCM.psc"
    .\tools\sync-devotion-to-live.ps1 -DevotionRoot "E:\Games\Devotion"
#>

[CmdletBinding()]
param(
    [string]$DevotionRoot = "D:\Wabbajack\modlists\Anvil\mods\Devotion",
    [string]$BackupRoot = "",
    [string[]]$Only = @(),
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ([string]::IsNullOrWhiteSpace($BackupRoot)) {
    $BackupRoot = Join-Path $RepoRoot "generated\live-devotion-backups"
}

$Map = @(
    @{ Src = "mod-data\CREDITS.md";                                            Dst = "Credits.txt"; Required = $true },
    @{ Src = "mod-data\PDV_Calian_DESC.ini";                                  Dst = "PDV_Calian_DESC.ini"; Required = $true },
    @{ Src = "mod-data\PDV_GreenPact_KID.ini";                               Dst = "PDV_GreenPact_KID.ini"; Required = $true },
    @{ Src = "mod-data\PDV_ItemRecognition_KID.ini";                          Dst = "PDV_ItemRecognition_KID.ini"; Required = $true },
    @{ Src = "mod-data\PDV_ReligiousRecognition_DISTR.ini";                   Dst = "PDV_ReligiousRecognition_DISTR.ini"; Required = $true },
    @{ Src = "mod-data\meshes\PDV\Clutter\PDV_AltmerCalian.nif";             Dst = "Meshes\PDV\Clutter\PDV_AltmerCalian.nif"; Required = $true },
    @{ Src = "mod-data\MS03 Calians\textures\calianjewelrybox.dds";          Dst = "MS03 Calians\textures\calianjewelrybox.dds"; Required = $true },
    @{ Src = "mod-data\MS03 Calians\textures\calianjewelrybox_n.dds";        Dst = "MS03 Calians\textures\calianjewelrybox_n.dds"; Required = $true },
    @{ Src = "mod-data\MS03 Calians\textures\cubemaps\shinyglass_e.dds";    Dst = "MS03 Calians\textures\cubemaps\shinyglass_e.dds"; Required = $true },
    @{ Src = "mod-data\MS03 Calians\textures\white\eggshell.dds";           Dst = "MS03 Calians\textures\white\eggshell.dds"; Required = $true },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\app.js";     Dst = "PrismaUI\views\Devotion\app.js" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\index.html"; Dst = "PrismaUI\views\Devotion\index.html" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\styles.css"; Dst = "PrismaUI\views\Devotion\styles.css" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\fonts\IMFellEnglish-Italic.ttf"; Dst = "PrismaUI\views\Devotion\fonts\IMFellEnglish-Italic.ttf" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\fonts\IMFellEnglish-Italic.woff2"; Dst = "PrismaUI\views\Devotion\fonts\IMFellEnglish-Italic.woff2" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\fonts\IMFellEnglish-Regular.ttf"; Dst = "PrismaUI\views\Devotion\fonts\IMFellEnglish-Regular.ttf" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\fonts\IMFellEnglish-Regular.woff2"; Dst = "PrismaUI\views\Devotion\fonts\IMFellEnglish-Regular.woff2" },
    @{ Src = "native\DevotionPrismaBridge\mod\PrismaUI\views\Devotion\fonts\OFL-IMFellEnglish.txt"; Dst = "PrismaUI\views\Devotion\fonts\OFL-IMFellEnglish.txt" },
    @{ Src = "live-source\Scripts\Source\PDV__ManagerQuest.psc";             Dst = "Scripts\Source\PDV__ManagerQuest.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_DevotionLedger.psc";            Dst = "Scripts\Source\PDV_DevotionLedger.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_RecognitionRuntime.psc";        Dst = "Scripts\Source\PDV_RecognitionRuntime.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_OriginRuntimeBase.psc";          Dst = "Scripts\Source\PDV_OriginRuntimeBase.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_OriginRuntime_Altmer.psc";       Dst = "Scripts\Source\PDV_OriginRuntime_Altmer.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_OriginRuntime_Argonian.psc";     Dst = "Scripts\Source\PDV_OriginRuntime_Argonian.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_OriginRuntime_Bosmer.psc";       Dst = "Scripts\Source\PDV_OriginRuntime_Bosmer.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_OriginRuntime_Breton.psc";       Dst = "Scripts\Source\PDV_OriginRuntime_Breton.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_OriginRuntime_Dunmer.psc";       Dst = "Scripts\Source\PDV_OriginRuntime_Dunmer.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_OriginRuntime_Imperial.psc";     Dst = "Scripts\Source\PDV_OriginRuntime_Imperial.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_OriginRuntime_Khajiit.psc";      Dst = "Scripts\Source\PDV_OriginRuntime_Khajiit.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_OriginRuntime_Nord.psc";         Dst = "Scripts\Source\PDV_OriginRuntime_Nord.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_OriginRuntime_Orc.psc";          Dst = "Scripts\Source\PDV_OriginRuntime_Orc.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_OriginRuntime_Redguard.psc";     Dst = "Scripts\Source\PDV_OriginRuntime_Redguard.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_AltmerPracticeFocus.psc";       Dst = "Scripts\Source\PDV_AltmerPracticeFocus.psc"; Required = $true },
    @{ Src = "live-source\Scripts\Source\PDV_T3DailyLowHealthSaveEffect.psc"; Dst = "Scripts\Source\PDV_T3DailyLowHealthSaveEffect.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_KhajiitAzurahPortentEffect.psc"; Dst = "Scripts\Source\PDV_KhajiitAzurahPortentEffect.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_KhajiitBaanDarRescueEffect.psc"; Dst = "Scripts\Source\PDV_KhajiitBaanDarRescueEffect.psc" },
    @{ Src = "live-source\Scripts\Source\TempleBlessingScript.psc";          Dst = "Scripts\Source\TempleBlessingScript.psc"; Required = $true },
    @{ Src = "live-source\Scripts\Source\PDV_QuestReactionRuntime.psc";      Dst = "Scripts\Source\PDV_QuestReactionRuntime.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_Deity_AuriEl.psc";              Dst = "Scripts\Source\PDV_Deity_AuriEl.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_DaedricPathBase.psc";          Dst = "Scripts\Source\PDV_DaedricPathBase.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_MCM.psc";                       Dst = "Scripts\Source\PDV_MCM.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_SubstrateBase.psc";             Dst = "Scripts\Source\PDV_SubstrateBase.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_Substrate_ImperialAncestor.psc"; Dst = "Scripts\Source\PDV_Substrate_ImperialAncestor.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_Substrate_DunmerAncestor.psc";   Dst = "Scripts\Source\PDV_Substrate_DunmerAncestor.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_Substrate_ArgonianHist.psc";     Dst = "Scripts\Source\PDV_Substrate_ArgonianHist.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_Substrate_NordAncestor.psc";     Dst = "Scripts\Source\PDV_Substrate_NordAncestor.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_Substrate_AltmerAncestor.psc";   Dst = "Scripts\Source\PDV_Substrate_AltmerAncestor.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_Substrate_KhajiitLunar.psc";     Dst = "Scripts\Source\PDV_Substrate_KhajiitLunar.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_ObserveMoonsEffect.psc";         Dst = "Scripts\Source\PDV_ObserveMoonsEffect.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_ActionRouter.psc";              Dst = "Scripts\Source\PDV_ActionRouter.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_EventBus.psc";                  Dst = "Scripts\Source\PDV_EventBus.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_PlayerEvents.psc";              Dst = "Scripts\Source\PDV_PlayerEvents.psc" },
    @{ Src = "live-source\Scripts\Source\PDV_DeityBase.psc";                 Dst = "Scripts\Source\PDV_DeityBase.psc" },
    @{ Src = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_RaceMap.json";       Dst = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_RaceMap.json" },
    @{ Src = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_TemporaryRaceMap.json"; Dst = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_TemporaryRaceMap.json" },
    @{ Src = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_RaceMap_README.txt"; Dst = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_RaceMap_README.txt" },
    @{ Src = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_QuestReactionCore.v2.json"; Dst = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_QuestReactionCore.v2.json"; Required = $true },
    @{ Src = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_QuestReactionPatches.v2.json"; Dst = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_QuestReactionPatches.v2.json"; Required = $true },
    @{ Src = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_AltmerPracticeLines.json"; Dst = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_AltmerPracticeLines.json"; Required = $true },
    @{ Src = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_KhajiitMoonObservations.json"; Dst = "SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_KhajiitMoonObservations.json" }
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

function Assert-SyncMap {
    param(
        [array]$Entries,
        [string]$SourceRoot,
        [string]$DestinationRoot
    )

    $seenDestinations = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in $Entries) {
        if ([string]::IsNullOrWhiteSpace($entry.Src) -or [string]::IsNullOrWhiteSpace($entry.Dst)) {
            Fail-Sync "Sync map entries must declare both Src and Dst."
        }

        $srcPath = [IO.Path]::GetFullPath((Join-Path $SourceRoot $entry.Src))
        $dstPath = [IO.Path]::GetFullPath((Join-Path $DestinationRoot $entry.Dst))
        if (-not $srcPath.StartsWith($SourceRoot + [IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
            Fail-Sync "Sync source escapes the repository root: $($entry.Src)"
        }
        if (-not $dstPath.StartsWith($DestinationRoot + [IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
            Fail-Sync "Sync destination escapes the live Devotion root: $($entry.Dst)"
        }
        if (-not $seenDestinations.Add($dstPath)) {
            Fail-Sync "Sync map has duplicate destination: $($entry.Dst)"
        }
        if ($entry.Required -and -not (Test-Path -LiteralPath $srcPath -PathType Leaf)) {
            Fail-Sync "Required sync source is missing: $($entry.Src)"
        }
    }
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
Assert-SyncMap $Map $RepoRoot $DevotionRoot

if ($Only.Count -gt 0) {
    $requested = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($path in $Only) {
        [void]$requested.Add($path)
    }
    $Map = @($Map | Where-Object { $requested.Contains($_.Src) -or $requested.Contains($_.Dst) })
    if ($Map.Count -ne $requested.Count) {
        $matched = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($entry in $Map) {
            if ($requested.Contains($entry.Src)) { [void]$matched.Add($entry.Src) }
            if ($requested.Contains($entry.Dst)) { [void]$matched.Add($entry.Dst) }
        }
        $unknown = @($requested | Where-Object { -not $matched.Contains($_) })
        Fail-Sync ("Unknown -Only sync-map path(s): " + ($unknown -join ", "))
    }
}

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
