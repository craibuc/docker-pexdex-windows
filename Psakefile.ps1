<#
.EXAMPLE
PS> invoke-psake build

Creates the pexdex:latest image.

.EXAMPLE
PS> invoke-psake terminal

Starts a PowerShell (v5) session in the container

.NOTES

To use the build-automation file (Psakefile.ps1), the Psake module needs to be installed, then imported.

PS> install-module psake -scope currentuser
PS> import-module psake
#>

Properties {
    $Email = 'first.last@domain.org'
    $Volume = "$( $env:USERPROFILE )\output:c:\app\output"
    $User = "$( $env:APPDATA )\pexdex\user:c:\app\user"
    $SiteId = 'ABCD'
    $Study = 'registry'
    $PIN = '123456'
    $PublicKey = 'ssh-rsa AAAA...' # need to load key from file and remove ending CRLF
    $xmlPath = '.\output\ABCD_2019-03-01_to_2019-03-31.xml'
    $pidPath = '.\output\PID_ABCD_2019-03-01_to_2019-03-31.txt'
    $deidXmlPath = '.\output\ABCD_2019-03-01_to_2019-03-31xml'
}

Task Clean {
    Remove-Item .\install -Recurse -ErrorAction:Ignore
}

Task Copy -Depends Clean {
    # Copy-Item -Path "$env:APPDATA\pexdex" -Destination .\install\pexdex-user -Recurse
    Copy-Item -Path 'C:\Program Files\PEXDEX' -Destination .\install\PEXDEX -Recurse
    Copy-Item -Path "$env:APPDATA\pexdex\perl" -Destination .\install\PEXDEX\deid -Recurse
}

Task Build {
    docker build --tag "pexdex:latest" .
}

Task Terminal {
    docker run -it --rm --entrypoint powershell -v "$( $env:USERPROFILE )\output:c:\app\output" -v "$( $env:APPDATA )\pexdex:c:\app\user" 'pexdex:latest'
}

Task Run {
    # generates the help text
    docker run -it --rm -v "$( $env:USERPROFILE )\output:c:\app\output" -v "$( $env:APPDATA )\pexdex:c:\app\user" 'pexdex:latest'
}

Task Register {
    docker run --rm 'pexdex:latest' --register --siteid $SiteId --study $Study --email $Email
}

Task ConfirmRegister {
    docker run --rm 'pexdex:latest' --confirmregister --siteid $SiteId --study $Study --pin $PIN --publickey $PublicKey
}

<#
# create an ephemoral container from the pexdex:latest image
docker run -it --rm --volume pexdex:latest

# command to be passed to the container:
--validate --siteid ABCD --study registry --file .\output\ABCD_2019-03-01_to_2019-03-31.xml 
#>
Task Validate {
    docker run -it --rm --volume "$( $env:USERPROFILE )\output:c:\app\output" pexdex:latest --validate --siteid $SiteId --study $Study --file $xmlPath
}

Task Deidentify {
    docker run -it --rm --volume "$( $env:USERPROFILE )\output:c:\app\output" pexdex:latest --deidentify --siteid $SiteId --study $Study --submissiontype 1 --file $xmlPath --pidtxt $pidPath
}

Task Submit -Depends Deidentify {
    docker run -it --rm --volume "$( $env:USERPROFILE )\output:c:\app\output" pexdex:latest --submit --siteid $siteid --study $Study --file $deidXmlPath
}

