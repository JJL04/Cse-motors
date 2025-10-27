<#
Run Assignment 2 database rebuild and Task 1 queries.

Usage (PowerShell):
  # Set DATABASE_URL as an env var, or pass it as the first argument
  $env:DATABASE_URL = 'postgres://user:pass@host:5432/dbname'
  ./scripts/run_assignment2.ps1

  # Or pass connection string as argument
  ./scripts/run_assignment2.ps1 'postgres://user:pass@host:5432/dbname'

Notes:
 - Requires `psql` available in PATH (Postgres client).
 - `database/rebuild.sql` will create required type/tables and insert sample data.
 - `database/assignment2.sql` contains the six Task 1 queries.
 - This script runs both files and then prints SELECT output for verification.
#>

param(
  [string]$DatabaseUrl = $env:DATABASE_URL
)

if (-not $DatabaseUrl) {
  Write-Host "No DATABASE_URL provided. Please enter the Postgres connection string (psql ""postgres://user:pass@host:port/dbname""):" -ForegroundColor Yellow
  $DatabaseUrl = Read-Host "DATABASE_URL"
}

if (-not $DatabaseUrl) {
  Write-Error "Database connection string is required. Aborting."
  exit 1
}

function Run-PsqlFile($file) {
  Write-Host "\n== Running: $file ==" -ForegroundColor Cyan
  $rc = & psql.exe $DatabaseUrl -v ON_ERROR_STOP=1 -f $file
  if ($LASTEXITCODE -ne 0) {
    Write-Error "psql returned exit code $LASTEXITCODE while running $file"
    exit $LASTEXITCODE
  }
}

function Run-PsqlQuery($sql, $label) {
  Write-Host "\n== $label ==" -ForegroundColor Green
  & psql.exe $DatabaseUrl -v ON_ERROR_STOP=1 -c $sql
}

try {
  $root = Resolve-Path "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)\.." | Select-Object -ExpandProperty Path
  $rebuild = Join-Path $root "database\rebuild.sql"
  $assignment = Join-Path $root "database\assignment2.sql"

  if (-not (Test-Path $rebuild)) { Write-Error "Missing $rebuild"; exit 1 }
  if (-not (Test-Path $assignment)) { Write-Error "Missing $assignment"; exit 1 }

  Run-PsqlFile $rebuild
  Run-PsqlFile $assignment

  # Verification selects
  Run-PsqlQuery "SELECT * FROM classification;" "classification rows"
  Run-PsqlQuery "SELECT inv_id, inv_make, inv_model, inv_description, inv_image, inv_thumbnail FROM inventory ORDER BY inv_id;" "inventory rows"
  Run-PsqlQuery "SELECT account_id, account_firstname, account_lastname, account_email, account_type FROM account ORDER BY account_id;" "account rows"

  Write-Host "\nAll scripts ran successfully. Review the output above for verification." -ForegroundColor Magenta
} catch {
  Write-Error "An error occurred: $_"
  exit 1
}
