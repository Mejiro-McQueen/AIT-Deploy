# KMC Makefiles 

# Introduction 
The Makefile contained in this directory is used to deploy and configure the KMC-Crypto-Service. It functions by calling the Makefiles contained in the subdirectories.

Do not run this Makefile on the AIT server.

# kmc_install
Run this makefile on both AIT server and KMC-Crypto-Service server.

The Makefile contained in kmc_install will configure an RHEL8 compatible distro (Alma, Rocky, etc...) with the appropriate MGSS-ASIS repos and manifests, as well as some extra dependencies and open the appropriate ports. 

The current manifest installs both KMC-Crypto-Service and KMC-Crypto-Client.

Additional info found in the accompanying README

[kmc_install_readme](kmc_install/README.md)

# crypto_service_config
Run this makefile only on KMC-Crypto-Service
This makefile will generate crypto-keys, mtls keys, and configure KMC-Crypto-Service. 

The original keys will be dumped in this directory.
The state of the keys can not be guaranteed if this script is run twice! Backup the keys as necessary!

Additional info found in the accompanying README

[crypto_service config_readme](crypto_service_config/README.md)



