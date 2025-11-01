#!/usr/bin/env pwsh
<#
Run the database rebuild and assignment SQL files using a DATABASE_URL environment variable.

Usage:
  $env:DATABASE_URL = 'postgres://USER:PASSWORD@HOST:PORT/DBNAME'
  ./scripts/run_assignment2.ps1

Or pass the URL as the first argument:
  ./scripts/run_assignment2.ps1 'postgres://USER:PASSWORD@HOST:PORT/DBNAME'
#>

param(
    [string]$DatabaseUrl
)

if (-not $DatabaseUrl) { $DatabaseUrl = $env:DATABASE_URL }
if (-not $DatabaseUrl) {
    Write-Error "DATABASE_URL not set and no argument provided. Set the env var or pass the URL as an argument."
    exit 2
}

$regex = 'postgres(?:ql)?:\/\/(?<user>[^:]+):(?<pass>[^@]+)@(?<host>[^:\/]+):(?<port>\d+)\/(?<db>.+)'
$m = [regex]::Match($DatabaseUrl, $regex)
if (-not $m.Success) {
    Write-Error "DATABASE_URL not in expected format. Expected: postgres://USER:PASSWORD@HOST:PORT/DBNAME"
    exit 3
}

$user = $m.Groups['user'].Value
$pass = $m.Groups['pass'].Value
$dbHost = $m.Groups['host'].Value
$dbPort = $m.Groups['port'].Value
$db = $m.Groups['db'].Value

# Set password for psql
$env:PGPASSWORD = $pass

try {
    $repoRoot = Resolve-Path -Path (Join-Path $PSScriptRoot '..')
    Set-Location $repoRoot

    $rebuild = Join-Path $repoRoot 'database\rebuild.sql'
    $assignment = Join-Path $repoRoot 'database\assignment2.sql'

    Write-Host "Running rebuild.sql against $dbHost/$db as $user..."
    & psql -h $dbHost -p $dbPort -U $user -d $db -f $rebuild
    if ($LASTEXITCODE -ne 0) { throw "rebuild.sql failed (exit $LASTEXITCODE)" }

    Write-Host "Running assignment2.sql against $dbHost/$db as $user..."
    & psql -h $dbHost -p $dbPort -U $user -d $db -f $assignment
    if ($LASTEXITCODE -ne 0) { throw "assignment2.sql failed (exit $LASTEXITCODE)" }

    Write-Host "Running verification queries..."
    & psql -h $dbHost -p $dbPort -U $user -d $db -c "SELECT COUNT(*) FROM classification;"
    & psql -h $dbHost -p $dbPort -U $user -d $db -c "SELECT COUNT(*) FROM inventory;"
    & psql -h $dbHost -p $dbPort -U $user -d $db -c "SELECT COUNT(*) FROM account;"
    & psql -h $dbHost -p $dbPort -U $user -d $db -c "SELECT * FROM classification ORDER BY classification_id;"
    & psql -h $dbHost -p $dbPort -U $user -d $db -c "SELECT inv_id, inv_make, inv_model, inv_description, inv_image, inv_thumbnail FROM inventory ORDER BY inv_id LIMIT 10;"
    & psql -h $dbHost -p $dbPort -U $user -d $db -c "SELECT account_id, account_firstname, account_lastname, account_email, account_type FROM account ORDER BY account_id LIMIT 10;"

    Write-Host "All done."
}
catch {
    Write-Error $_
    exit 4
}
finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}
