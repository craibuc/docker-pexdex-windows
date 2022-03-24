<#
.SYNOPSIS
Submits a PECARN, XML file to the DCC.

.PARAMETER siteid
The four-letter, site or location id of the entity submitting data.

.PARAMETER xmlPath
Path to the de-identified XML file.

.PARAMETER study
Valid values: pedscreen, registry.

.EXAMPLE
PS> Submit-PecarnXmlFile -siteid 'ABCD' -xmlPath \path\to\output\ABCD\ABCD_2020-03-04_to_2020-03-14.xml -study registry
#>
function Submit-PecarnXmlFile {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$siteid,

        [Parameter(Mandatory)]
        [string]$xmlPath,

        [Parameter(Mandatory)]
        [ValidateSet('pedscreen','registry')]
        [string]$study
    )
    
    # if xmlPath doesn't exists, throw exception
    if ( (Test-Path -Path $xmlPath) -eq $false )
    {
        throw [System.IO.FileNotFoundException]::new("XML file not found", $xmlPath)
    }
    
    # $PexDexDirectory = $MyInvocation.MyCommand.Module.PrivateData.PexDexDirectory ? $MyInvocation.MyCommand.Module.PrivateData.PexDexDirectory : 'C:\Program Files\PEXDEX'
    $PexDexDirectory = 'C:\App'
    Write-Debug "PexDexDirectory: $PexDexDirectory"

    Push-Location -Path $PexDexDirectory

    $Command = "java ""-Dproperties.dir=C:\Program Files\PEXDEX"" -jar .\CLI\pexdexCLI.jar --spring.profiles.active=error --submit --siteid $siteid --file $xmlPath --study $study"
    Write-Debug "Command: $Command"

    if ($PSCmdlet.ShouldProcess("$siteid/$email",'register'))
    {
        Invoke-Expression -Command $Command
    }
    
    Pop-Location

}