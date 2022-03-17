# AIT-Deploy

Makefile, dockerfile, and Anaconda configuration to quickly deploy AIT projects.

# Introduction
This script is a collection of Makefiles in three layers. 
1. The Makefile at the root of the repo is for configurating and deploying AIT.
2. The Makefile in sql_scripts is for the configuration of the kmc SADB database tables.
[SQL Config](sql_scripts/README.md)

3. The Makefiles in the kmc directory are for the configuration and deployment of KMC-Crypto-Service and KMC-Crypto-Client.
[KMC Deployment](kmc/README.md)

# Dependencies

- make
- git
- bash
- wget
- A web browser (For AIT-GUI)
- python
  + pyjks (for key-dump target, not run by default for convenience)
    
# Production Deployment

Within the repo, run `make`.
Make will handle cloning, configuring, and installing necessary repos.

# Developer Mode
Run make with the flag DEV=true (i.g. make AIT-Core DEV=true).
You can optionally modify the DEV variable within the makefile, which lets you omit passing the DEV flag.

## Tox
Run make with the flags DEV=true TOX=true.

## Useful Make Targets

| Target | Description |
| --- | --- |
| interactive | Runs ait-server, simulators, and firefox
|server| Runs ait-server and will fork to the background. Useful for servers|
|nofork| Runs ait-server and does not fork. Useful for development, monitoring, testing, docker.|
|AIT-Core TEST=true| Run AIT-Core pytest tests|
|AIT-Core DEV=true| Install AIT-Core with Poetry and other development dependencies|
|AIT-Core DEV=true TOX=true | Run the AIT-Core Tox pipeline | 
|clean| Kills all ait-server instances, sims, and deletes conda evironments.|

# Customization

## Makefile 

| Variable | Effect |
| --- | --- |
|project_url | url to the project AIT Customization and deployment repository. Comment the line to use AIT defaults.| 
|miniconda_url | URL to the installer of the miniconda python distribution installer. This is mandatory. |
|ait_core_url | Url to the AIT-core repository. This variable is mandatory.|
|ait_gui_url | Url to the AIT GUI repository. Comment this line to disable the plugin. |
|ait_dsn_url | Url to the AIT DSN repository. Comment this line to disable the plugin. |
|python_version| Version of python to use. Must be compatible across all plugins and AIT-Core. |
| DEV | When true, installs AIT-Core using Poetry, along with extra dependencies. |
| TOX | When true, runs tox if DEV is passed. | 

# Docker

Build the image and then run the container with the `-d` option.

## Options:

1. Run docker build. The make file will perform the setup automatically.
2. Run make locally and then docker build. The docker build file will copy your local deployment into the container. This is perferred if your project repo is not public or requires authentication.

# AWS Autostart on Reboot

While logged into the EC2 instance:
`crontab -e`
Add an entry: `@reboot cd ~/AIT_Quick_Deploy/ && make`

ait-server will automatically start and fork on the next reboot.
You can now restart the EC2 instance or start ait-server by running run `make` and then logging out of the instance.

# Ports
| Port | Protocol | Purpose |
| --- | --- | --- |
| 8080 | TCP | AIT-GUI |
| 8443 | TCP + mtls | KMC-Crypto-Service |
| 3306 | TCP + mtls-option | KMC-Crypto-Client mariadb | 
| ???? | UDP/TCP | Customizable AIT ports |

