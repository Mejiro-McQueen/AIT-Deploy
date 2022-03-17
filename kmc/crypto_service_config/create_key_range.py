#!/usr/bin/env python3
import sys
import os

if len(sys.argv) < 4:
    msg = "USAGE:\n"
    msg += f"{sys.argv[0]} low_key_range high_key_range storename "
    msg += "storepass key_alias_prefix\n"
    msg += f"Example: {sys.argv[0]} 1 180 a-crypto-keystore.pk12 "
    msg += "testtest kmc/test/key"
    print(msg)
    exit()

low = int(sys.argv[1])
high = int(sys.argv[2])
storename = sys.argv[3]
storepass = sys.argv[4]
key_alias_prefix = sys.argv[5]

for i in range(low, high+1):
    cmd = (f"keytool -genseckey -alias {key_alias_prefix}{i} -keyalg aes "
           f"-keysize 256 -keystore {storename} -storetype PKCS12"
           f" -storepass {storepass}")
    os.system(cmd)
    print(cmd)
