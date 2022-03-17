# Crypto-Service Config Makefile

# Caveats
1. There are various hacks used to bypass some annoyances in the engineering build of KMC-Crypto-Service. 
2. make clean will attempt to revert all changes made by this script, including the deletion of crypto-keys. 
3. Running some targets in this script twice without running clean first will backup modified config files, replacing the originals. Running clean, and rerunning the installer Makefile will restore your installation
4. This script was written with the expectation that only the KMC-Crypto-Service will be deployed on the target machine. 
5. Currently, keystore passwords might be visible in ps while make is running. This might not be an issue if no one is logged in while make is running. This is not security advice: Consult your SCGI.


# Useful Targets

| Target | Description |
| | Creates and copies necessary keys, and server configs. The server will be enabled and started. |
| dumps-keys | Calls a python script which will copy the crypto-keystore.p12 keystore as a JCEKS keystore. The python script will then dump the JCEKS keystore as a CSV file. This target must be called explicitly. |
| clean | Deletes all keys and restores server to its original configuration; |
| crypto-keystore | Just generate the crypto-keystore.p12 file. Keys do not seem to be overwritten if they already exist. |

# Customization
The default values are sufficient for delpoyment. 

## Makefile 
| Variable | Effect |
| --- | --- |
| CA_PASS | desired password for self signed certifcate authority key |
| CSR_PASS | desired password for certificate signing request| 
| MTLS_PASS | desired password for MTLS key | 
| CRYPTO_PASS | desired password for crypto-keystore.p12 file | 
| --- | --- | 
| LOW_KEY_RANGE | This is the first crypto key number to generate. Set to 1 by default. |
| HIGH_KEY_RANGE | This is the last Crypto key number to generate. Set to 2 by default | 
| KEY_ALIAS_PREFIX | The alias prefix for your keys, example setting this to kmc/test/key will generate the keys {kmc/test/key1 ... kmc/test/key2} | 
| SUBJ | Extra info required for self signed cert. Not very important.| 

|File | Effect| 
|---|---|
|alma-kmc | Extra info for self signed certificates, not very important. This will be generalized in the future.|
