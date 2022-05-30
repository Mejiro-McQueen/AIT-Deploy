enc-db: clean
	mysql -u root < ./create_sadb.sql | true
	mysql -u root < ./create_sadb_enc.sql | true
	mysql -u root < ./create_user.sql | true

auth-db: clean
	mysql -u root < ./create_sadb.sql | true
	mysql -u root < ./create_sadb_auth.sql | true
	mysql -u root < ./create_user.sql | true

clean:
	mysql -u root < ./delete_sadb.sql | true
