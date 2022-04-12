# Run this makefile on the KMC Crypto Service server

kmc_server_setup:
	$(MAKE) -C ./kmc_install
	$(MAKE) -C ./crypto_service_config

clean:
	$(MAKE) -C ./kmc_install clean
	$(MAKE) -C ./crypto_service_config clean
