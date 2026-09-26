# Install every skill globally for Pi.
# Run from any directory in Windows PowerShell or PowerShell 7.
$ErrorActionPreference = 'Stop'

Push-Location $PSScriptRoot
try
{
    & npx.cmd skills add . -g -y -a pi
    if ($LASTEXITCODE -ne 0)
    {
        throw "skills installation failed with exit code $LASTEXITCODE"
    }
}
finally
{
    Pop-Location
}
