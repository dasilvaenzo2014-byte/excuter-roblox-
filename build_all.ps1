$msbuild = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\amd64\MSBuild.exe"
$root    = "C:\Users\dasil\Downloads\LInjector-master\LInjector-master"

Write-Host "=== Compilation du DLL executor ===" -ForegroundColor Cyan
& $msbuild "$root\libs\executor_src\executor.vcxproj" /p:Configuration=Release /p:Platform=x64 /v:minimal
if ($LASTEXITCODE -ne 0) { Write-Host "ECHEC executor DLL" -ForegroundColor Red; exit 1 }
Write-Host "Executor DLL OK -> $root\libs\injector.dll" -ForegroundColor Green

# Copie la DLL dans le répertoire que l'exe cherche en premier
$dllDst = "$root\LInjector\x64\Release\libs\injector.dll"
New-Item -ItemType Directory -Force -Path (Split-Path $dllDst) | Out-Null
Copy-Item -Path "$root\libs\injector.dll" -Destination $dllDst -Force
Write-Host "DLL copiée -> $dllDst" -ForegroundColor Green

Write-Host ""
Write-Host "=== Compilation de LInjector.exe ===" -ForegroundColor Cyan
& $msbuild "$root\LInjector\LInjector.vcxproj" /p:Configuration=Release /p:Platform=x64 /v:minimal
if ($LASTEXITCODE -ne 0) { Write-Host "ECHEC LInjector" -ForegroundColor Red; exit 1 }
Write-Host "LInjector.exe OK -> $root\x64\Release\LInjector.exe" -ForegroundColor Green

Write-Host ""
Write-Host "=== Tout est compile ! ===" -ForegroundColor Green
Write-Host "Lance x64\Release\LInjector.exe en admin pour tester." -ForegroundColor Yellow
