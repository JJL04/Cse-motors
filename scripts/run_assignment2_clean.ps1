#!/usr/bin/env pwsh
<#
Run the rebuild and cleaned assignment SQL files for Assignment 2.

Usage:
  $env:DATABASE_URL = 'postgres://USER:PASSWORD@HOST:PORT/DBNAME'
  ./scripts/run_assignment2_clean.ps1
#>

param([string]$DatabaseUrl)

# Get the database URL from parameter or environment
if (-not $DatabaseUrl) { $DatabaseUrl = $env:DATABASE_URL }
if (-not $DatabaseUrl) {
  Write-Host 'Error: Please provide DATABASE_URL environment variable.' -ForegroundColor Red
  exit 2
}

# Parse connection string
$regex = 'postgres(?:ql)?:\/\/(?<user>[^:]+):(?<pass>[^@]+)@(?<host>[^:\/]+):(?<port>\d+)\/(?<db>.+)'
$m = [regex]::Match($DatabaseUrl, $regex)
if (-not $m.Success) {
  Write-Host 'Error: Invalid DATABASE_URL format.' -ForegroundColor Red
  exit 3
}

$dbUser = $m.Groups['user'].Value
$dbPass = $m.Groups['pass'].Value
$dbHost = $m.Groups['host'].Value
$dbPort = $m.Groups['port'].Value
$dbName = $m.Groups['db'].Value

# Ensure psql exists
if (-not (Get-Command psql -ErrorAction SilentlyContinue)) {
  Write-Host "Error: psql command not found in PATH." -ForegroundColor Red
  exit 4
}

# Temporarily store password for psql
$env:PGPASSWORD = $dbPass

# Navigate to repository root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoRoot = Resolve-Path -Path (Join-Path $scriptDir '..')
Set-Location $repoRoot

# Define file paths
$rebuild = Join-Path $repoRoot 'database\rebuild.sql'
$assignment = Join-Path $repoRoot 'database\assignment2_clean.sql'

Write-Host "Running rebuild.sql..." -ForegroundColor Cyan
& psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -f $rebuild

Write-Host "`nRunning assignment2_clean.sql..." -ForegroundColor Cyan
& psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -f $assignment

Write-Host "`nAll scripts executed successfully." -ForegroundColor Green

# Clean up
Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
