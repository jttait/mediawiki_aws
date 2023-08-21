This is a Terraform module for creating a MediaWiki wiki in AWS.

The wiki server runs on an EC2 instance.

The module includes backups of the MariaDB database to S3. These are done by an hourly cronjob on
the EC2. The required IAM role and profile is also created to allow the EC2 to upload the backup
files to S3.

The two input variables are a password to use for the MariaDB user and the name of an existing SSH
key pair in AWS to be used to SSH or SCP on to the EC2.

The MediaWiki setup has a manual setup step using the browser and it doesn't seem possible to
automate this. After setting up in the UI, you then need to upload a settings file to the EC2.

After installation, the wiki is accessible using the public IP of the EC2 instance. This URL is an
output of the Terraform module.

# Installing

1. Create SSH key pair
1. `aws configure`
1. `terraform plan`
1. `terraform apply`
1. Go to {outputs.mediawiki\_url} in browser
1. Follow the instructions
1. Database username is "wikiuser", password is {var.mariadb\_password}
1. `scp -i "{var.ssh\_key\_pair\_name}.pem" LocalSettings.php ubuntu@{ec2\_instance\_public\_dns}:/var/www/html/mediawiki/`

# Restore Backup

1. SSH on to instance
1. `sudo /restore\_mariadb\_from\_latest\_backup.sh`
