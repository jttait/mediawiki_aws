#!/bin/bash

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

sudo apt-get update
sudo apt-get install -y php php-apcu php-common php-intl php-json php-mbstring php-mysql php-xml mariadb-server apache2

echo -n "CREATE DATABASE my_wiki" > create_mariadb.sql
echo -n "CREATE USER 'wikiuser'@'localhost' IDENTIFIED BY 'todo'" >> create_mariadb.sql
echo -n "GRANT ALL PRIVILEGES ON my_wiki.* TO 'wikiuser'@'localhost' WITH GRANT OPTION;" >> create_mariadb.sql
mariadb < create_mariadb.sql

wget https://releases.wikimedia.org/mediawiki/1.40/mediawiki-1.40.0.tar.gz
tar -xzvf mediawiki-*.tar.gz --directory /var/www/html/
mv /var/www/html/mediawiki* /var/www/html/mediawiki
rm /mediawiki-*.tar.gz

mkdir /mariadb_backups
echo -n "mariadb-dump --user=wikiuser --password=todo --result-file=/mariadb_backups/backup.sql my_wiki" > /etc/cron.hourly/mariadb_backups.sh
chmod +x /etc/cron.hourly/mariadb_backups.sh
