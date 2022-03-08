#!/usr/bin/env python3
import jks
import csv
import os
import sys


def main():
    if len(sys.argv) < 3:
        print("Usage: ./keydump.py ./keystore.jks keystore_password")
        return
    keystore_path = sys.argv[1]
    password = sys.argv[2]
    # x = './EC2/kmc/crypto_service_config/crypto-keystore.jks'
    columns = ['alias', 'algorithm', 'key_size', 'key_string', 'bin_md5']
    ks = jks.KeyStore.load(keystore_path, password)
    dump = []
    print("\n")
    for alias, sk in ks.secret_keys.items():
        print(f"Secret key: {sk.alias}")
        print(f"  Algorithm: {sk.algorithm}")
        print(f"  Key size: {sk.key_size}")
        keystr = "".join("{:02x}".format(b) for b in bytearray(sk.key))
        print(f"  Key: {keystr}")

        cmd = f'echo "{keystr}" | xxd -r -p - | md5sum'
        stream = os.popen(cmd)
        md5 = stream.read()
        md5 = md5.strip('-\n').strip("  ")

        print(f"  bin_md5: {md5}")
        print()

        dump.append([sk.alias, sk.algorithm, sk.key_size, keystr, md5])

    with open('crypto-keystore.csv', 'w') as csvfile:
        spamwriter = csv.writer(csvfile)
        spamwriter.writerow(columns)
        spamwriter.writerows(dump)

if __name__=="__main__":
    main()
