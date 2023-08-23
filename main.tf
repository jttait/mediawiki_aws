resource "aws_security_group" "mediawiki" {
  name        = "Inbound HTTP and HTTPS"
  description = "Inbound HTTP and HTTPS"
  vpc_id      = ""
  ingress {
    description = "Allow inbound HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow inbound HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow inbound SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description      = "Allow all outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "mediawiki" {
  ami                         = "ami-0d09654d0a20d3ae2"
  instance_type               = "t2.micro"
  user_data                   = templatefile("${path.module}/start.tftpl", { mariadb_password = var.mariadb_password, backup_s3_bucket_name = var.backup_s3_bucket_name })
  user_data_replace_on_change = true
  key_name                    = var.ssh_key_pair_name
  security_groups             = [aws_security_group.mediawiki.name]
  depends_on                  = [aws_security_group.mediawiki]
  iam_instance_profile        = var.backup_s3_bucket_name == "" ? aws_iam_instance_profile.mediawiki[0].name : null
}

resource "aws_s3_bucket" "mediawiki_backup" {
  count  = var.backup_s3_bucket_name == "" ? 0 : 1
  bucket = var.backup_s3_bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "mediawiki_backup" {
  count  = var.backup_s3_bucket_name == "" ? 0 : 1
  bucket = aws_s3_bucket.mediawiki_backup[0].bucket
  rule {
    id     = "DeleteOlderThan1dayButKeepAtLeast10"
    status = "Enabled"
    noncurrent_version_expiration {
      newer_noncurrent_versions = 10
      noncurrent_days           = 1
    }
  }
}

resource "aws_iam_role" "mediawiki" {
  count              = var.backup_s3_bucket_name == "" ? 0 : 1
  assume_role_policy = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"},\"Sid\":\"\"}],\"Version\":\"2012-10-17\"}"
  name               = "mediawiki_role"
  inline_policy {
    name   = "mediawiki_role"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":[\"s3:*\"],\"Effect\":\"Allow\",\"Resource\":\"${aws_s3_bucket.mediawiki_backup[0].arn}/*\"}]}"
  }
}

resource "aws_iam_instance_profile" "mediawiki" {
  count = var.backup_s3_bucket_name == "" ? 0 : 1
  name  = "mediawiki_profile"
  role  = aws_iam_role.mediawiki[0].name
}
