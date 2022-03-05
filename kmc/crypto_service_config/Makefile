export CA_PASS=testtest
export CSR_PASS=testtest
export MTLS_PASS=testtest
export CRYPTO_PASS=testtest

K?=130 131

SUBJ= "/C=US/ST=California/L=Pasadena/O=Jet Propulsion Laboratory/OU=<Project>/CN=cmdenc-user/emailAddress=<email address>"

#------------SYSTEMCTL-----------------------#

kmc-start: crypto fix-target
	sudo systemctl enable kmc-crypto-service
	sudo systemctl restart kmc-crypto-service
	sudo systemctl status kmc-crypto-service

kmc-stop:
	sudo systemctl stop kmc-crypto-service
	sudo systemctl disable kmc-crypto-service
# Edit /usr/lib/systemd/system/kmc-crypto-service.service
# Remove condition statements

fix-target:
	sudo cp -p /usr/lib/systemd/system/kmc-crypto-service.service /usr/lib/systemd/system/kmc-crypto-service.service.bak
	sudo sed -i 's|ConditionFileNotEmpty=/ammos/etc/pki/tls/certs/ammos-truststore.jks|#ConditionFileNotEmpty=/ammos/etc/pki/tls/certs/ammos-mtls-keystore.jks|g' /usr/lib/systemd/system/kmc-crypto-service.service
	sudo sed -i 's|/ammos/etc/pki/tls/private/ammos-server-keystore.p12|#ammos/etc/pki/tls/private/ammos-server-keystore.p12|g' /usr/lib/systemd/system/kmc-crypto-service.service


#---------------CRYPTO SERVER--------------------#

crypto: mtls crypto-store crypto-setup hack-fix-tomcat-cert-pw

crypto-store:
	for num in $(K) ; do \
	keytool -genseckey -alias kmc/test/key$$num -keyalg aes -keysize 256 -keystore crypto-keystore.p12 -storetype PKCS12 -storepass $(CRYPTO_PASS); \
	done
#TODO EXPORT KEYS
# openssl pkcs12 -in crypto-keystore.p12 -nokeys -out cert.pem
# openssl pkcs12 -in crypto-keystore.p12 -nodes -password env:CRYPTO_PASS -nocerts -out key.pem
	sudo cp -p crypto-keystore.p12 /ammos/kmc-crypto-service/etc/crypto-keystore.p12
	sudo chown crypto:crypto /ammos/kmc-crypto-service/etc/crypto-keystore.p12
	sudo chmod 400 /ammos/kmc-crypto-service/etc/crypto-keystore.p12


crypto-setup:
	sudo cp -p /ammos/kmc-crypto-service/etc/kmc-crypto.cfg /ammos/kmc-crypto-service/etc/kmc-crypto.cfg.bak
	sudo sed -i 's/#crypto_keystore_type=PKCS12/crypto_keystore_type=PKCS12/g' /ammos/kmc-crypto-service/etc/kmc-crypto.cfg
	sudo sed -i 's|#crypto_keystore_location=/ammos/kmc-crypto-service/etc/kmc-all-keys.p12|crypto_keystore_location=/ammos/kmc-crypto-service/etc/crypto-keystore.p12|g' /ammos/kmc-crypto-service/etc/kmc-crypto.cfg
	sudo sed -i 's|keystore_file=/ammos/etc/pki/tls/private/ammos-server-keystore.jks|keystore_file=/ammos/etc/pki/tls/private/ammos-server-keystore.p12|g' /ammos/kmc-crypto-service/etc/kmc-crypto.cfg
	sudo sed -i 's/#crypto_keystore_password=kmcstorepass/crypto_keystore_password=$(CRYPTO_PASS)/g' /ammos/kmc-crypto-service/etc/kmc-crypto.cfg
	sudo sed -i 's/keystore_password=changeit/keystore_password=$(MTLS_PASS)/g' /ammos/kmc-crypto-service/etc/kmc-crypto.cfg

#------------------ MTS-------------#

mtls:  self-signed-ca server-keystore move-mtls-keys client-key change-java-opts

server-keystore: self-signed-ca
	openssl pkcs12 -export -in ammos-server-cert.pem -inkey ammos-server-key.pem -out ammos-server-keystore.p12 -passout env:MTLS_PASS

sign-with-ca: setup-ca
	openssl x509 -req -CA rootCA.crt -CAkey rootCA.key -in ammos-server-key.csr -out ammos-server-cert.pem -days 365 -CAcreateserial -extfile alma-kmc -passin env:CA_PASS

csr:
	openssl req -newkey rsa:2048 -days 365 -nodes -keyout ammos-server-key.pem -out ammos-server-key.csr -passout env:CSR_PASS -subj $(SUBJ)

setup-ca:
	openssl req -x509 -sha256 -days 1825 -newkey rsa:2048 -keyout rootCA.key -out rootCA.crt -passout env:CA_PASS -subj $(SUBJ)

self-signed-ca: csr setup-ca sign-with-ca

move-mtls-keys:
#Certs
	sudo cp ammos-server-cert.pem /ammos/etc/pki/tls/certs
	sudo chown crypto:crypto /ammos/etc/pki/tls/certs/ammos-server-cert.pem
	sudo chmod 444 /ammos/etc/pki/tls/certs/ammos-server-cert.pem
# Private
	sudo cp -p ammos-server-key.pem ammos-server-keystore.p12 /ammos/etc/pki/tls/private
	sudo chown crypto:crypto /ammos/etc/pki/tls/private/ammos-server-key.pem
	sudo chown crypto:crypto /ammos/etc/pki/tls/private/ammos-server-keystore.p12
	sudo chmod 400 /ammos/etc/pki/tls/private/ammos-server-key.pem
	sudo chmod 400 /ammos/etc/pki/tls/private/ammos-server-keystore.p12


client-key:
	openssl genrsa -out client-key.pem 2048
	openssl req -new -x509 -extensions v3_ca -nodes -days 365 -key client-key.pem -out client-cert.pem -subj $(SUBJ)
# new truststore
	keytool -import -file client-cert.pem -alias client -keystore ammos-mtls-keystore.jks -storepass $(MTLS_PASS) -trustcacerts -noprompt

#Is this not right?
	sudo cp ammos-mtls-keystore.jks /ammos/etc/pki/tls/private
	sudo chown crypto:crypto /ammos/etc/pki/tls/private/ammos-mtls-keystore.jks
	sudo chmod 400 /ammos/etc/pki/tls/private/ammos-mtls-keystore.jks

#According to systemd
	sudo cp ammos-mtls-keystore.jks /ammos/etc/pki/tls/certs
	sudo chown crypto:crypto /ammos/etc/pki/tls/certs/ammos-mtls-keystore.jks
	sudo chmod 400 /ammos/etc/pki/tls/certs/ammos-mtls-keystore.jks

change-java-opts:
	sudo cp -p /etc/sysconfig/kmc-crypto-service /etc/sysconfig/kmc-crypto-service.bak
	sudo sed -i "s/-Djavax.net.ssl.keyStorePassword='changeit'/-Djavax.net.ssl.keyStorePassword='$(MTLS_PASS)'/g" /etc/sysconfig/kmc-crypto-service
	sudo sed -i "s/-Djavax.net.ssl.trustStorePassword='changeit'/-Djavax.net.ssl.trustStorePassword='$(MTLS_PASS)'/g" /etc/sysconfig/kmc-crypto-service
	sudo sed -i "s#-Djavax.net.ssl.trustStore=/ammos/etc/pki/tls/certs/ammos-truststore.jks#-Djavax.net.ssl.trustStore=/ammos/etc/pki/tls/certs/ammos-mtls-keystore.jks#g" /etc/sysconfig/kmc-crypto-service #MIGHT NOT BE RIGHT
	#HACK Complains about bad password if the keystore doesn't actually exist
	sudo sed -i 's|/ammos/etc/pki/tls/private/ammos-server-keystore.p12 /ammos/etc/pki/tls/certs/ammos-truststore.jks"| /ammos/etc/pki/tls/private/ammos-server-keystore.p12 | g' /etc/sysconfig/kmc-crypto-service
clean: undo-hack-tomcat-cer-pw
	git clean -xfd
	sudo rm -rf /ammos/etc/pki/tls/certs/ammos-server-cert.pem
	sudo rm -rf /ammos/etc/pki/tls/private/ammos-server-key.pem
	sudo rm -rf /ammos/etc/pki/tls/private/ammos-server-keystore.p12
	sudo rm -rf /ammos/etc/pki/tls/private/ammos-mtls-keystore.jks
	sudo rm -rf /ammos/etc/pki/tls/certs/ammos-mtls-keystore.jks
	sudo rm -rf /ammos/kmc-crypto-service/etc/crypto-keystore.p12

	sudo cp -p /etc/sysconfig/kmc-crypto-service.bak /etc/sysconfig/kmc-crypto-service
	sudo cp -p /ammos/kmc-crypto-service/etc/kmc-crypto.cfg.bak /ammos/kmc-crypto-service/etc/kmc-crypto.cfg #MOVE ME

	sudo cp -p /usr/lib/systemd/system/kmc-crypto-service.service.bak /usr/lib/systemd/system/kmc-crypto-service.service #MOVE ME


hack-fix-tomcat-cert-pw:
	sudo cp -p /opt/ammos/kmc-crypto-service/cse/3.0.0/tomcat9/conf/server.xml /opt/ammos/kmc-crypto-service/cse/3.0.0/tomcat9/conf/server.xml.bak
	sudo sed -i 's|certificateKeystorePassword="changeit"|certificateKeystorePassword="$(MTLS_PASS)"|g' /opt/ammos/kmc-crypto-service/cse/3.0.0/tomcat9/conf/server.xml

undo-hack-tomcat-cer-pw:
	sudo cp -p /opt/ammos/kmc-crypto-service/cse/3.0.0/tomcat9/conf/server.xml.bak /opt/ammos/kmc-crypto-service/cse/3.0.0/tomcat9/conf/server.xml
