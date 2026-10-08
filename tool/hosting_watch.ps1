$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$projectId = 'appfinanzas-aa642'
$quietSeconds = 3
$pollMilliseconds = 1000
$watchedDirectories = @('lib', 'web', 'assets')
$watchedFiles = @('pubspec.yaml', 'pubspec.lock', 'firebase.json')

Set-Location -LiteralPath $projectRoot

$firebaseConfig = Get-Content -LiteralPath 'firebase.json' -Raw |
    ConvertFrom-Json
if ($firebaseConfig.hosting.public -ne 'build/web') {
    throw 'firebase.json debe configurar Hosting con public: build/web.'
}

function Get-SourceSnapshot {
    $snapshot = @{}

    foreach ($directory in $watchedDirectories) {
        $directoryPath = Join-Path $projectRoot $directory
        if (-not (Test-Path -LiteralPath $directoryPath -PathType Container)) {
            continue
        }

        foreach ($file in Get-ChildItem -LiteralPath $directoryPath -File -Recurse) {
            $relativePath = $file.FullName.Substring($projectRoot.Length)
            $snapshot[$relativePath] = '{0}:{1}' -f `
                $file.Length, $file.LastWriteTimeUtc.Ticks
        }
    }

    foreach ($fileName in $watchedFiles) {
        $filePath = Join-Path $projectRoot $fileName
        if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
            continue
        }
        $file = Get-Item -LiteralPath $filePath
        $relativePath = $file.FullName.Substring($projectRoot.Length)
        $snapshot[$relativePath] = '{0}:{1}' -f `
            $file.Length, $file.LastWriteTimeUtc.Ticks
    }

    return $snapshot
}

function Test-SnapshotChanged {
    param(
        [hashtable]$Previous,
        [hashtable]$Current
    )

    if ($Previous.Count -ne $Current.Count) {
        return $true
    }
    foreach ($path in $Current.Keys) {
        if (-not $Previous.ContainsKey($path) -or
            $Previous[$path] -ne $Current[$path]) {
            return $true
        }
    }
    return $false
}

$lastSnapshot = Get-SourceSnapshot
$pendingSince = $null
Write-Host "Observando cambios de la app para Firebase Hosting: https://$projectId.web.app"
Write-Host 'Al guardar archivos en lib, web o assets, compilaré y publicaré la app.'
Write-Host 'Deja esta terminal abierta. Pulsa Ctrl+C para detener la publicación automática.'

while ($true) {
    Start-Sleep -Milliseconds $pollMilliseconds
    $currentSnapshot = Get-SourceSnapshot

    if (Test-SnapshotChanged -Previous $lastSnapshot -Current $currentSnapshot) {
        $lastSnapshot = $currentSnapshot
        $pendingSince = Get-Date
        Write-Host 'Cambio detectado; espero a que terminen las ediciones...'
        continue
    }

    if ($null -eq $pendingSince -or
        ((Get-Date) - $pendingSince).TotalSeconds -lt $quietSeconds) {
        continue
    }

    $pendingSince = $null
    Write-Host 'Compilando Flutter Web...'
    & flutter build web
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'La compilación falló; no se publicó. Corrige el error y guarda de nuevo.'
        continue
    }

    Write-Host 'Publicando solo Firebase Hosting...'
    & firebase.cmd deploy --only hosting --project $projectId
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'La publicación falló. Revisa la autenticación de Firebase CLI y guarda de nuevo.'
        continue
    }

    Write-Host "Listo. Recarga Chrome con F5: https://$projectId.web.app"
}
