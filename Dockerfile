FROM mcr.microsoft.com/windows:1809 

#
# install PEXDEX-related files
#

WORKDIR /app

# powershell scripts
COPY ./profile.ps1 .
COPY ./scripts ./scripts

# client components
# COPY ./install/PEXDEXuser/perl /app/deid
COPY ./install/PEXDEX/deid /app/deid
# bind mount this folder instead
# COPY ./install/PEXDEXuser /app/user

# use the modified version
COPY ./pexdex-cli.properties .

# PEXDEX application
COPY ./install/PEXDEX/CLI ./CLI
COPY ./install/PEXDEX/IPC ./IPC
COPY ./install/PEXDEX/*.dll ./
COPY ./install/PEXDEX/log4net.* ./
COPY ./install/PEXDEX/Newtonsoft.* ./
COPY ./install/PEXDEX/pedscreen_schema ./pedscreen_schema
COPY ./install/PEXDEX/registry_schema ./registry_schema

# create logs directory to prevent `Unable to write to validator log` error
RUN mkdir .\logs

# java runtime
COPY ./install/PEXDEX/runtime ./java

# perl runtime
COPY ./install/PEXDEX/strawberry/perl ./perl

#
# add java and perl runtimes to the PATH environment variable
#

RUN setx path "%path%;C:\App\java\bin;C:\App\perl\bin"

#
# configure PowerShell (v5)
#

RUN powershell -Command Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# create $PROFILE file
RUN powershell -Command New-Item -ItemType File -Force $PROFILE
# overwrite file with configured one
RUN powershell -Command Move-Item -Force -Path .\Profile.ps1 -Destination $PROFILE

#
# testing
#

# CMD ["java.exe","--version"]
# CMD ["powershell"]

#
# HELP
#

# CMD java.exe "-Dproperties.dir=/app" -jar .\CLI\pexdexCLI.jar --spring.profiles.active=error --help
# CMD ["java.exe", "-Dproperties.dir=/app", "-jar", ".\\CLI\\pexdexCLI.jar", "--spring.profiles.active=error"]

#
# REGISTER
#

# CMD ["java.exe", "-Dproperties.dir=/app", "-jar", ".\\CLI\\pexdexCLI.jar", "--spring.profiles.active=error", "--register", "--emailAddress", $EMAIL_ADDRESS, "--siteid", $SITE_ID]

#
# REGISTER
#

# java "-Dproperties.dir=\app" -jar .\CLI\pexdexCLI.jar --spring.profiles.active=error --confirmregister --siteid "ABCD" --pin "123456" --study registry --publickey "ssh-rsa AAAA..."
# CMD ["java.exe", "-Dproperties.dir=/app", "-jar", ".\\CLI\\pexdexCLI.jar", "--spring.profiles.active=error", "--confirmregister", "--siteid", $SITE_ID, "--pin", $PIN, "--study", "registry", "--publickey", "ssh-rsa AAAA..."]

#
# VALIDATE
#

# java.exe "-Dproperties.dir=/app" -jar .\CLI\pexdexCLI.jar --spring.profiles.active=error --validate --siteid ABCD --study registry --file .\output\ABCD_2019-03-01_to_2019-03-31.xml
# CMD ["java.exe", "-Dproperties.dir=/app", "-jar", ".\\CLI\\pexdexCLI.jar", "--spring.profiles.active=error", "--validate", "--siteid", $SITE_ID, "--study", "registry", "--file", $XML_FILE_PATH]

#
# DEIDENTIFY
#

# java.exe "-Dproperties.dir=/app" -jar .\CLI\pexdexCLI.jar --spring.profiles.active=error --deidentify --siteid ABCD --submissiontype 1 --study registry --file .\output\ABCD_2019-03-01_to_2019-03-31.xml --pidtxt .\output\PID_ABCD_2019-03-01_to_2019-03-31.txt
# CMD ["java", "-jar", "pexdexCLI.jar", "--deidentify", "", SITE_ID, "--submissionType", "1", "--file", $XML_FILE_PATH, "--pidtxt", $PID_FILE_PATH]

#
# SUBMIT
#

# TODO

#
# CURRENT
#

# will always be run; displays help text
ENTRYPOINT ["java.exe", "-Dproperties.dir=/app", "-jar", ".\\CLI\\pexdexCLI.jar", "--spring.profiles.active=error"]

# will be overriden if parameters are passed to docker run; displays help text
# CMD ["java.exe", "-Dproperties.dir=/app", "-jar", ".\\CLI\\pexdexCLI.jar", "--spring.profiles.active=error"]
