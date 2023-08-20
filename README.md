# Installing

1. create ssh key pair called "MediaWikiKeyPair"
1. aws configure
1. terraform plan
1. terraform apply
1. Get IP address from EC2
1. Go to http://{ipAddress}/mediawiki
1. Follow the instructions
1. Database user is wikiuser, password is what you entered as terraform input variable
1. ssh on to instance using MediaWikiKeyPair PEM
1. sudo vim /var/www/html/mediawiki/LocalSettings.php
1. Paste in contents and save (:x)

# Restore Backup

1. ssh on to instance
1. sudo /restore\_mariadb\_from\_latest\_backup.sh
