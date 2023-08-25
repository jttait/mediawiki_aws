variable "mariadb_password" {
  description = "Password for the MariaDB user wikiuser"
  type        = string
  sensitive   = true
}

variable "ssh_key_pair_name" {
  description = "Name of an existing SSH key pair for EC2 instance (don't include .pem extension)"
  type        = string
}

variable "backup_s3_bucket_name" {
  description = "Name of S3 bucket for MariaDB backups"
  type        = string
  default     = ""
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
