<#
.SYNOPSIS
Tests the validity of a PECARN, XML file.

.PARAMETER siteId
The four-letter, site or location id of the entity submitting data.

.PARAMETER study
Valid values: pedscreen, registry.

.PARAMETER xmlPath
Path to the XML file.

.EXAMPLE
PS> Test-PecarnXmlFile -siteId 'ABCD' -study registry -xmlPath \path\to\output\ABCD\ABCD_2020-03-14_to_2020-03-14.xml

#>
function Test-PecarnXmlFile {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$siteId,

        [Parameter(Mandatory)]
        [ValidateSet('pedscreen','registry')]
        [string]$study,

        [Parameter(Mandatory)]
        [string]$xmlPath
    )

    Write-Debug "siteId: $siteId"
    Write-Debug "study: $study"
    Write-Debug "xmlPath: $xmlPath"
    Write-Debug "pidPath: $pidPath"

    try 
    {
        # $PexDexDirectory = $MyInvocation.MyCommand.Module.PrivateData.PexDexDirectory ? $MyInvocation.MyCommand.Module.PrivateData.PexDexDirectory : 'C:\Program Files\PEXDEX'
        $PexDexDirectory = 'c:\App'
        Write-Debug "PexDexDirectory: $PexDexDirectory"
    
        Push-Location -Path $PexDexDirectory

        if ( (Test-Path -Path $xmlPath) -eq $false )
        {
            throw "XML file not found: $xmlPath"
        }
        
        $Command = "java ""-Dproperties.dir=/app"" -jar .\CLI\pexdexCLI.jar --spring.profiles.active=error --validate --siteid $siteId --study $study --file $xmlPath"
        Write-Debug "Command: $Command"
    
        if ($PSCmdlet.ShouldProcess("$siteId/$xmlPath",'validate'))
        {
            Invoke-Expression -Command $Command
        }
    }
    catch 
    {
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally
    {
        Pop-Location
    }

}