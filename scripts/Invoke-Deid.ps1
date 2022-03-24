<#
.SYNOPSIS
De-identify the XML file.

.PARAMETER siteId
The four-letter, site or location id of the entity submitting data.

.PARAMETER submissionType
NoDeid or Deid

.PARAMETER study
Valid values: pedscreen, registry

.PARAMETER xmlPath
Path to the XML file.

.PARAMETER pidPath
Path to the PID file.

.EXAMPLE
PS> Invoke-Deid -siteId 'ABCD' -submissionType Deid  -study registry -xmlPath \path\to\output\ABCD\ABCD_2020-03-04_to_2020-03-14.xml -pidPath \path\to\output\ABCD\PID_ABCD_2020-03-04_to_2020-03-14.txt
#>

function Invoke-Deid {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$siteId,

        [Parameter(Mandatory)]
        [ValidateSet('NoDeid','Deid')]
        [string]$submissionType,

        [Parameter(Mandatory)]
        [ValidateSet('pedscreen','registry')]
        [string]$study,

        [Parameter(Mandatory)]
        [string]$xmlPath,

        [Parameter(Mandatory)]
        [string]$pidPath
    )

    Write-Debug "siteId: $siteId"
    Write-Debug "study: $study"
    Write-Debug "xmlPath: $xmlPath"

    try 
    {

        if ( (Test-Path -Path $xmlPath) -eq $false )
        {
            throw "XML file not found: $xmlPath"
        }
    
        if ( (Test-Path -Path $pidPath) -eq $false )
        {
            throw "PID file not found: $pidPath"
        }
    
        # $PexDexDirectory = $MyInvocation.MyCommand.Module.PrivateData.PexDexDirectory ? $MyInvocation.MyCommand.Module.PrivateData.PexDexDirectory : 'C:\Program Files\PEXDEX'
        $PexDexDirectory = 'c:\App'
        Write-Debug "PexDexDirectory: $PexDexDirectory"
    
        Push-Location -Path $PexDexDirectory
    
        $Command = "java ""-Dproperties.dir=C:\Program Files\PEXDEX"" -jar .\CLI\pexdexCLI.jar --spring.profiles.active=error --deidentify --siteid $siteid --study $study --submissiontype $( if ($submissionType -eq 'Deid') {1} else {0} ) --file $xmlPath --pidtxt $pidPath"
        Write-Debug "Command: $Command"
    
        if ($PSCmdlet.ShouldProcess("$siteid/$xmlPath",'de-identify'))
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