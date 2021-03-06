#!/bin/bash

# Set the metadata server to the get projct id
PROJECTID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")

echo "Project ID: ${PROJECTID}"

# Install dependencies
apt-get update
apt-get -y install expect jq gnupg gnupg-agent mariadb-backup mariadb-client mariadb-server
MYSQL_ROOT_PASSWORD=$(curl "https://secretmanager.googleapis.com/v1/projects/${PROJECTID}/secrets/mysql_root_password/versions/1:access" \
	--request "GET" \
	--header "authorization: Bearer $(gcloud auth print-access-token)" \
	--header "content-type: application/json" \
	--header "x-goog-user-project: ${PROJECTID}" |
	jq -r ".payload.data" | base64 --decode)
MYSQL_PASSWORD=$(curl "https://secretmanager.googleapis.com/v1/projects/${PROJECTID}/secrets/mysql_password/versions/1:access" \
	--request "GET" \
	--header "authorization: Bearer $(gcloud auth print-access-token)" \
	--header "content-type: application/json" \
	--header "x-goog-user-project: ${PROJECTID}" |
	jq -r ".payload.data" | base64 --decode)

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"${MYSQL_ROOT_PASSWORD}\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

apt -y purge expect

cat <<'EOF' > init_doughnut_db.sql
CREATE DATABASE IF NOT EXISTS doughnut DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
CREATE USER IF NOT EXISTS 'doughnut'@'localhost' IDENTIFIED BY 'doughnut';
SET PASSWORD FOR 'doughnut'@'localhost' = PASSWORD("${MYSQL_PASSWORD}");
GRANT ALL PRIVILEGES ON doughnut.* TO 'doughnut'@'localhost';
FLUSH PRIVILEGES;
EOF

mysql -uroot -p${MYSQL_ROOT_PASSWORD} < init_doughnut_db.sql
