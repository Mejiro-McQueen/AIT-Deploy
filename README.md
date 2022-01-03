# AIT-Deploy
Makefile, dockerfile, and Anaconda configuration to quickly deploy AIT projects

# Dependencies
- make
- git
- bash
- wget

# Production Deployment
Within the repo, run `make`.
Make will handle cloning, configuring, and installing necessary repos.

# Development
For development purposes, we usually perfer to use local version of git repos.

## environment.yml:

Comment the following lines:
```
      ## Uncomment for Deployment (Fetch from Repo)
      #- git+https://github.com/NASA-AMMOS/AIT-Core.git
      #- git+https://github.com/NASA-AMMOS/AIT-GUI.git
```

Uncomment the following lines
```
      ## Uncomment for Development (Prefer local clones made by make)
       - ./AIT-Project
       - ./AIT-Core
       - ./AIT-GUI
```

## Makefile
   Run `make` with the flag `DEV=true`, i.e. `make DEV=true`
   Optionally, setting `DEV?:=true` within the makefile, may be more convenient.

## Useful Make Targets

| Target | Description |
| --- | --- |
|server| Runs ait-server and will fork to the background. Useful for servers.|
|nofork| Runs ait-server and does not fork. Useful for development, monitoring, testing, docker.|
|clean| Kills all ait-server instances and deletes the conda evironment.|

# Customization

## Makefile 
| Variable | Effect |
| --- | --- |
|miniconda_url | URL to the installer of the miniconda python distribution installer
|ait_core_url | url to the AIT-core repository
|project_url | url to the project AIT Customization and deployment repository
|ait_gui_url | url to the AIT GUI repository
|project_name | Name of project_url repo name, must match the configuration.yaml file.
|DEV| If true, will clone and use repositories that aren't usually necessary for production, but useful for development.

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