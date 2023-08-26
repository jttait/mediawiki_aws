Terraform module for creating a MediaWiki wiki in AWS.

The wiki server runs on an EC2 instance.

Optional backups of the MariaDB database to S3 bucket. These are done by an hourly cronjob on
the EC2. The required IAM role and profile is also created to allow the EC2 to upload the backup
files to S3.

After installation, the wiki is accessible using the Elastic IP. This URL is an output of the
Terraform module.

# Installing

1. `terraform apply`
1. `terraform apply` (There seems to be a bug where EC2 public DNS is not updated and previous value remains in Terraform and is displayed in the outputs. Re-running the apply fixes this issue, the second apply doesn't make any infrastructure changes).
1. Wait until EC2 instance initializes and MediaWiki server starts
1. Go to {outputs.mediawiki\_url} in browser

# Restore Backup

1. SSH on to instance
1. `sudo /restore_mariadb_from_latest_backup.sh`

# References

MediaWiki installation: https://www.mediawiki.org/wiki/Manual:Installing\_MediaWiki

Terraform: https://www.terraform.io/

AWS Provider for Terraform: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

MariaDB Dump: https://mariadb.com/kb/en/mariadb-dump/
