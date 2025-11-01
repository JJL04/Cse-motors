#!/usr/bin/env pwsh
<#
Run the rebuild script and the cleaned assignment SQL file.
Usage:
  $env:DATABASE_URL = 'postgres://USER:PASSWORD@HOST:PORT/DBNAME'
  ./scripts/run_assignment2_clean.ps1
#>

param([string]$DatabaseUrl)
if (-not $DatabaseUrl) { $DatabaseUrl = $env:DATABASE_URL }
if (-not $DatabaseUrl) { Write-Host 'Provide DATABASE_URL' -ForegroundColor Red; exit 2 }

$regex = 'postgres(?:ql)?:\/\/(?<user>[^:]+):(?<pass>[^@]+)@(?<host>[^:\/]+):(?<port>\d+)\/(?<db>.+)'
$m = [regex]::Match($DatabaseUrl, $regex)
if (-not $m.Success) { Write-Host 'Bad DATABASE_URL' -ForegroundColor Red; exit 3 }

$dbUser = $m.Groups['user'].Value
$dbPass = $m.Groups['pass'].Value
$dbHost = $m.Groups['host'].Value
$dbPort = $m.Groups['port'].Value
$dbName = $m.Groups['db'].Value

if (-not (Get-Command psql -ErrorAction SilentlyContinue)) { Write-Host "psql not found" -ForegroundColor Red; exit 4 }
$env:PGPASSWORD = $dbPass

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoRoot = Resolve-Path -Path (Join-Path $scriptDir '..')
Set-Location $repoRoot

$rebuild = Join-Path $repoRoot 'database\rebuild.sql'
$assignment = Join-Path $repoRoot 'database\assignment2_clean.sql'

Write-Host "Running rebuild and cleaned assignment SQL..."
& psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -f $rebuild
& psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -f $assignment

Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
