<#
  PowerShell helper to create the `ecommerce_db` database and import schema.
  Usage:
    Open PowerShell as Administrator (or a user with MySQL access)
    ./init_db.ps1 -MySqlUser root -MySqlPassword "YourRootPassword"
#>

param(
  [string]$MySqlHost = 'localhost',
  [string]$MySqlUser = 'root',
  [string]$MySqlPassword = '',
  [string]$DbName = 'ecommerce_db'
)

if (-not (Get-Command mysql -ErrorAction SilentlyContinue)) {
  Write-Error "MySQL client 'mysql' not found in PATH. Please install MySQL client or add it to PATH."
  exit 1
}

Write-Host "Creating database '$DbName' on $MySqlHost ..."
$createCmd = "CREATE DATABASE IF NOT EXISTS $DbName;"
mysql --host=$MySqlHost --user=$MySqlUser --password=$MySqlPassword -e "$createCmd"
if ($LASTEXITCODE -ne 0) { Write-Error "Failed to create database."; exit 1 }

$schemaFile = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) -ChildPath "..\database\schema.sql"
$schemaFile = Resolve-Path $schemaFile
if (-not (Test-Path $schemaFile)) { Write-Error "schema.sql not found at $schemaFile"; exit 1 }

Write-Host "Importing schema from $schemaFile ..."
mysql --host=$MySqlHost --user=$MySqlUser --password=$MySqlPassword $DbName < $schemaFile
if ($LASTEXITCODE -ne 0) { Write-Error "Failed to import schema."; exit 1 }

Write-Host "Database $DbName created and schema imported successfully."