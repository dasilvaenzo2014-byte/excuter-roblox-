# setup_luau.ps1 - Telecharge et prepare les sources Luau Compiler
# Usage: PowerShell -ExecutionPolicy Bypass -File setup_luau.ps1
#
# Place les sources sous:
#   libs\executor_src\luau\Compiler\
#   libs\executor_src\luau\Parser\
#   libs\executor_src\luau\Ast\
#   libs\executor_src\luau\Common\

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dest = Join-Path $root "libs\executor_src\luau"

Write-Host "[Luau] Destination : $dest"

$releaseTag = "0.747"
$zipUrl     = "https://github.com/luau-lang/luau/archive/refs/tags/$releaseTag.zip"
# Format sans 'v' prefix pour les tags luau (ex: 0.747 pas v0.747)
$zipTmp     = Join-Path $env:TEMP "luau_src.zip"
$extractTmp = Join-Path $env:TEMP "luau_extract"

Write-Host "[Luau] Telechargement $zipUrl ..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipTmp -UseBasicParsing
Write-Host "[Luau] Extraction ..."
if (Test-Path $extractTmp) { Remove-Item $extractTmp -Recurse -Force }
Expand-Archive -LiteralPath $zipTmp -DestinationPath $extractTmp
Remove-Item $zipTmp

$srcRoot = Get-ChildItem $extractTmp | Where-Object { $_.PSIsContainer } | Select-Object -First 1 -ExpandProperty FullName
Write-Host "[Luau] Source racine : $srcRoot"

$components = @("Compiler", "Parser", "Ast", "Common")
foreach ($comp in $components) {
    $src = Join-Path $srcRoot $comp
    $dst = Join-Path $dest    $comp
    if (Test-Path $src) {
        Write-Host "[Luau] Copie $comp -> $dst"
        if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
        Copy-Item $src $dst -Recurse
    } else {
        Write-Warning "[Luau] Composant manquant dans l'archive : $comp"
    }
}

Remove-Item $extractTmp -Recurse -Force

$required = @(
    "luau\Compiler\include\luacode.h",
    "luau\Compiler\src\Compiler.cpp",
    "luau\Parser\src\Parser.cpp",
    "luau\Ast\src\Ast.cpp"
)
Write-Host ""
Write-Host "[Luau] Verification des fichiers cles :"
$ok = $true
foreach ($rel in $required) {
    $full = Join-Path (Join-Path $root "libs\executor_src") $rel
    if (Test-Path $full) {
        Write-Host "  OK  $rel"
    } else {
        Write-Warning "  MANQUANT : $rel"
        $ok = $false
    }
}

if ($ok) {
    Write-Host ""
    Write-Host "[Luau] Configuration terminee ! Compilez maintenant executor.vcxproj."
} else {
    Write-Warning "[Luau] Certains fichiers sont manquants - verifiez la version de Luau."
}
