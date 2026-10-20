$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$compiler = Join-Path $PSScriptRoot 'inklecate/inklecate.exe'
$source = Join-Path $projectRoot 'story/day1.ink'
$output = Join-Path $projectRoot 'story/day1.json'
$tempOutput = Join-Path $projectRoot 'story/day1.building.json'
if (!(Test-Path -LiteralPath $compiler)) { throw 'Missing tools/inklecate/inklecate.exe' }
& $compiler -c -o $tempOutput $source
if ($LASTEXITCODE -ne 0 -or !(Test-Path -LiteralPath $tempOutput)) {
    throw 'Ink compilation failed. Existing compiled story was kept.'
}
$compiled = Get-Content -LiteralPath $tempOutput -Raw -Encoding UTF8 | ConvertFrom-Json
if (!$compiled.inkVersion) { throw 'Compiler produced invalid Ink JSON.' }
Move-Item -LiteralPath $tempOutput -Destination $output -Force
Write-Host 'OK: story/day1.json updated. Restart the running game to use the new dialogue.'
