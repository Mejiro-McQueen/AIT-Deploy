create_db:
	mysql -u root < ./create_sadb.sql | true
	mysql -u root < ./create_sadb_ait_test_security_associations.sql | true
	mysql -u root < ./create_user.sql | true


clean:
	mysql -u root < ./sql_scripts/delete_sadb.sql | true
