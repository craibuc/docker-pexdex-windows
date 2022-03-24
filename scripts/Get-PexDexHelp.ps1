<#
.SYNOPSIS
Displays the PexDex CLI's help text.

.EXAMPLE
PS> Get-PexDexHelp

#>
function Get-PexDexHelp {

    [CmdletBinding()]
    param ()

    $Command = "java ""-Dproperties.dir=/app"" -jar .\CLI\pexdexCLI.jar --spring.profiles.active=error --help"
    Write-Debug "Command: $Command"

    Invoke-Expression -Command $Command

}