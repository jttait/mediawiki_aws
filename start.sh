#!/bin/bash

sudo apt-get update
sudo apt-get install -y php php-apcu php-common php-intl php-json php-mbstring php-mysql php-xml mariadb-server apache2

wget https://releases.wikimedia.org/mediawiki/1.40/mediawiki-1.40.0.tar.gz
tar -xzvf mediawiki-*.tar.gz --directory /var/www/html/
mv /var/www/html/mediawiki* /var/www/html/mediawiki
