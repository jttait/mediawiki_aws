# Installing

1. create ssh key pair called "MediaWikiKeyPair"
1. aws configure
1. terraform plan
1. terraform apply
1. ssh on to instance using MediaWikiKeyPair PEM
1. mariadb
1. CREATE DATABASE my\_wiki;
1. CREATE USER 'wikiuser'@'localhost' IDENTIFIED BY 'database\_password';
1. GRANT ALL PRIVILEGES ON my\_wiki.* TO 'wikiuser'@'localhost' WITH GRANT OPTION;
1. Get IP address from EC2
1. Go to http://{ipAddress}/mediawiki
1. Follow the instructions
1. scp LocalSettings.php {address}:/var/www/mediawiki/
