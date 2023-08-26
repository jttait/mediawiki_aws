variable "mariadb_password" {
  description = "Password for the MariaDB user wikiuser."
  type        = string
  sensitive   = true
}

variable "ssh_key_pair_name" {
  description = "Name of an existing SSH key pair for EC2 instance (don't include .pem extension)."
  type        = string
}

variable "backup_s3_bucket_name" {
  description = "Name of S3 bucket for MariaDB backups. If value is provided then hourly backups will be implmented to this bucket. If not provided then no backups will be performed."
  type        = string
  default     = ""
}

variable "ec2_instance_type" {
  description = "EC2 instance type for server."
  type        = string
  default     = "t2.micro"
}

variable "wiki_name" {
  description = "Name of the wiki."
  type        = string
}

variable "admin_password" {
  description = "Password for Admin user."
  type        = string
  sensitive   = true
}

variable "user_rights" {
  description = "User rights for the wiki. Default is 'public', for publicly-editable wiki. Choose 'private' for a private wiki where only logged-in users can edit."
  type        = string
  default     = "public"
  validation {
    condition     = can(regex("public|private", var.user_rights))
    error_message = "The user_rights variable must be either public or private"
  }
}
