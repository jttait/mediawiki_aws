# Installing

1. Create SSH key pair
1. aws configure
1. terraform plan
1. terraform apply
1. Go to {outputs.mediawiki\_url} in browser
1. Follow the instructions
1. Database username is "wikiuser", password is {var.mariadb\_password}
1. scp -i "{var.ssh\_key\_pair\_name}.pem" LocalSettings.php ubuntu@{ec2\_instance\_public\_dns}:/var/www/html/mediawiki/

# Restore Backup

1. SSH on to instance
1. sudo /restore\_mariadb\_from\_latest\_backup.sh
