Terraform module for creating a MediaWiki wiki in AWS.

The wiki server runs on an EC2 instance.

Optional backups of the MariaDB database to S3 bucket. These are done by an hourly cronjob on
the EC2. The required IAM role and profile is also created to allow the EC2 to upload the backup
files to S3.

The MediaWiki setup has a manual setup step using the browser and it doesn't seem possible to
automate this. After setting up in the UI, you then need to upload a settings file to the EC2.

After installation, the wiki is accessible using the Elastic IP. This URL is an output of the
Terraform module.

# Installing

1. `terraform apply`
1. Go to {outputs.mediawiki\_url} in browser
1. Follow the instructions. Database username is "wikiuser", password is {var.mariadb\_password}
1. `scp -i "{var.ssh_key_pair_name}.pem" LocalSettings.php ubuntu@{ec2_instance_public_dns}:/var/www/html/mediawiki/`

# Restore Backup

1. SSH on to instance
1. `sudo /restore_mariadb_from_latest_backup.sh`

# References

MediaWiki installation: https://www.mediawiki.org/wiki/Manual:Installing\_MediaWiki

Terraform: https://www.terraform.io/

AWS Provider for Terraform: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

MariaDB Dump: https://mariadb.com/kb/en/mariadb-dump/
