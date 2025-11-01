#!/usr/bin/env pwsh
<#
Lightweight helper to run the database rebuild and assignment SQL files.

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
    Write-Host "ERROR: No DATABASE_URL provided." -ForegroundColor Red
    Write-Host "Set the environment variable or pass the URL as an argument." -ForegroundColor Yellow
    exit 2
}

# Parse the URL into components
$regex = 'postgres(?:ql)?:\/\/(?<user>[^:]+):(?<pass>[^@]+)@(?<host>[^:\/]+):(?<port>\d+)\/(?<db>.+)'
$m = [regex]::Match($DatabaseUrl, $regex)
if (-not $m.Success) {
    Write-Host "ERROR: DATABASE_URL not in expected format." -ForegroundColor Red
    exit 3
}

$dbUser = $m.Groups['user'].Value
$dbPass = $m.Groups['pass'].Value
$dbHost = $m.Groups['host'].Value
$dbPort = $m.Groups['port'].Value
$dbName = $m.Groups['db'].Value

# Verify psql is available
if (-not (Get-Command psql -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: 'psql' not found on PATH. Install PostgreSQL client tools." -ForegroundColor Red
    exit 4
}

# Put password into PGPASSWORD for psql (cleared at the end)
$env:PGPASSWORD = $dbPass

try {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $repoRoot = Resolve-Path -Path (Join-Path $scriptDir '..')
    Set-Location $repoRoot

    $rebuildFile = Join-Path $repoRoot 'database\rebuild.sql'
    $assignmentFile = Join-Path $repoRoot 'database\assignment2.sql'

    Write-Host "Running: rebuild.sql -> assignment2.sql against $dbHost/$dbName as $dbUser" -ForegroundColor Cyan

    Write-Host "-> Running rebuild.sql ..." -NoNewline
    & psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -f $rebuildFile
    if ($LASTEXITCODE -ne 0) { throw "rebuild.sql failed (exit $LASTEXITCODE)" }
    Write-Host " done." -ForegroundColor Green

    Write-Host "-> Running assignment2.sql ..." -NoNewline
    & psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -f $assignmentFile
    if ($LASTEXITCODE -ne 0) { throw "assignment2.sql failed (exit $LASTEXITCODE)" }
    Write-Host " done." -ForegroundColor Green

    Write-Host "\nVerification queries:" -ForegroundColor Cyan
    & psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -c "SELECT COUNT(*) AS classification_count FROM classification;"
    & psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -c "SELECT COUNT(*) AS inventory_count FROM inventory;"
    & psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -c "SELECT COUNT(*) AS account_count FROM account;"

    & psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -c "SELECT * FROM classification ORDER BY classification_id;"
    & psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -c "SELECT inv_id, inv_make, inv_model, inv_description, inv_image, inv_thumbnail FROM inventory ORDER BY inv_id LIMIT 10;"
    & psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -c "SELECT account_id, account_firstname, account_lastname, account_email, account_type FROM account ORDER BY account_id LIMIT 10;"

    Write-Host "\nAll done." -ForegroundColor Green
}
catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    exit 5
}
finally {
    # clear password from environment to avoid leaking it in this session
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}
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
