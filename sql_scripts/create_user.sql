CREATE USER sadb_user IDENTIFIED BY 'sadb_pass';
GRANT ALL PRIVILEGES ON sadb.* TO 'sadb_user'@'%';
