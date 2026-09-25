# Install every skill globally for universal, Pi, and Claude Code.
# Run from any directory in Windows PowerShell or PowerShell 7.
$ErrorActionPreference = 'Stop'

Push-Location $PSScriptRoot
try
{
    & npx.cmd skills add . -g -y -a universal -a pi -a claude-code
    if ($LASTEXITCODE -ne 0)
    {
        throw "skills installation failed with exit code $LASTEXITCODE"
    }
}
finally
{
    Pop-Location
}
