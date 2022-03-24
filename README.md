# README

## Purpose
To create a windows-based, Docker container for PexDex and its dependencies.  

## Usage

### Dependencies

Its dependencies are Java, Perl, and [deid](https://physionet.org/files/deid/1.1/).

### Prepare
Docker cannot access files that aren't in the project's directory (called its 'context').  Consequently, the PexDex application and the user-specific files need to be copied to the project's directory.

```powershell
# remove the install directory
Remove-Item .\install -Recurse -ErrorAction:Ignore

# copy the user's settings, which includes the deid (Perl script) and the .ssh public/private key pairs
Copy-Item -Path "$env:APPDATA\pexdex" -Destination .\install\pexdex-user -Recurse

# copy the application's file, including the Java and Perl (strawberry) runtimes.
Copy-Item -Path 'C:\Program Files\PEXDEX' -Destination .\install\PEXDEX -Recurse
```

### Build image

Copies PexDex and its dependencies to the image.

```powershell
 docker build --tag pexdex:latest .
```

Switch|Meaning
---|---
`--tag`|assign this tag to the image
`.`|use the `Dockerfile` in the current directory with the name 'Dockerfile'.

### Interactive, PowerShell terminal

This will create a container and start a PowerShell session.

```powershell
docker run -it --rm -v "$( $env:USERPROFILE )\output:c:\app\output" pexdex:latest
```
Switch|Meaning
---|---
`-it`|interactive terminal
`--rm`|delete the container when the session ends
`-v`|bind mount the `output` directory in the user's profile folder to `c:\app\output` in the container
`pexdex:latest`|create a container based on the image with this tag

### PSake
[Psake](https://github.com/psake/psake) ([documentation](https://psake.readthedocs.io/en/latest/)) is a build-automation tool, similar to `make` and `ant`.

#### Installation

```powershell
install-module psake -Scope CurrentUser
```

#### Usage

```powershell
# add the module to the current, powershell session
Import-Module psake

# lists all tasks
invoke-psake -docs
```

## pexdexCLI

```
usage: pexdexCLI [-a <arg>] [-c] [-d] [-e <arg>] [-f <arg>] [-i <arg>] [-k 
       <arg>] [-l <arg>] [-p <arg>] [-r] [-s] [-t <arg>] [-u <arg>] [-v]   
       [-y <arg>]
 -a,--apitoken <arg>         APIToken
 -c,--confirmregister        Confirm Register the site. require - Pin ,    
                             SiteId and sftp certificate
 -d,--deidentify             Deidentify the XML. require - XML file path,  
                             the pid.txt file path, the submissiontype and 
                             the SiteId incase the submissiontype is 0     
 -e,--email <arg>            The email address to register
 -f,--file <arg>             The XML filepath for validate or deid options 
 -i,--siteid <arg>           Four letter SiteId for the site
 -k,--publickey <arg>        SFTP Public key
 -l,--study <arg>            Study for the command - pedscreen or registry 
 -p,--pin <arg>              Four digit pin sent via email from Utah DCC   
 -r,--register               Register the site. require - siteId,
                             emailAddress
 -s,--submit                 Submit the deid file to Utah DCC. require -   
                             the deidXML file path and the siteId
 -t,--pidtxt <arg>           The pid text filepath for deid options        
 -u,--userid <arg>           User ID
 -v,--validate               Validate the xml against pedscreen XSD.
```

## Reference

- [PECARN eRoom](https://www.nedarcssl.org/eRoom/NDDP/Study-PECARNRegistry)
- [PexDex Installer](https://www.nedarcssl.org/eRoomReq/Files/NDDP/Study-PECARNRegistry/0_8d02a/pexdexclientinstallerTEST3.0.8.zip)
