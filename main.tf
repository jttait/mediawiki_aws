data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

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
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  user_data                   = templatefile("${path.module}/start.tftpl", { mariadb_password = var.mariadb_password, backup_s3_bucket_name = var.backup_s3_bucket_name, mediawiki_url = aws_eip.mediawiki.public_ip, wiki_name = var.wiki_name, admin_password = var.admin_password, user_rights = var.user_rights })
  user_data_replace_on_change = true
  key_name                    = var.ssh_key_pair_name
  security_groups             = [aws_security_group.mediawiki.name]
  depends_on                  = [aws_security_group.mediawiki]
  iam_instance_profile        = var.backup_s3_bucket_name == "" ? null : aws_iam_instance_profile.mediawiki.name
}

resource "aws_eip_association" "mediawiki" {
  instance_id   = aws_instance.mediawiki.id
  allocation_id = aws_eip.mediawiki.id
}

resource "aws_eip" "mediawiki" {
  domain = "vpc"
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
  assume_role_policy = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"},\"Sid\":\"\"}],\"Version\":\"2012-10-17\"}"
  name               = "mediawiki_role"
}

resource "aws_iam_instance_profile" "mediawiki" {
  name = "mediawiki"
  role = aws_iam_role.mediawiki.name
}

resource "aws_iam_role_policy" "mediawiki_s3" {
  count  = var.backup_s3_bucket_name == "" ? 0 : 1
  bucket = aws_s3_bucket.mediawiki_backup[0].bucket
  name   = "mediawiki_s3"
  role   = aws_iam_role.mediawiki.id
  policy = jsonencode("{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":[\"s3:*\"],\"Effect\":\"Allow\",\"Resource\":\"${aws_s3_bucket.mediawiki_backup[0].arn}/*\"}]}")
}

resource "aws_iam_role_policy" "mediawiki_ssm" {
  name   = "mediawiki_ssm"
  role   = aws_iam_role.mediawiki.id
  policy = jsonencode("{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\": \"Allow\",\"Action\":[\"ssm:DescribeAssociation\",\"ssm:GetDeployablePatchSnapshotForInstance\",\"ssm:GetDocument\",\"ssm:DescribeDocument\",\"ssm:GetManifest\",\"ssm:GetParameter\",\"ssm:GetParameters\",\"ssm:ListAssociations\",\"ssm:ListInstanceAssociations\",\"ssm:PutInventory\",\"ssm:PutComplianceItems\",\"ssm:PutConfigurePackageResult\",\"ssm:UpdateAssociationStatus\",\"ssm:UpdateInstanceAssociationStatus\",\"ssm:UpdateInstanceInformation\"],\"Resource\": \"*\"},{\"Effect\": \"Allow\",\"Action\":[\"ssmmessages:CreateControlChannel\",\"ssmmessages:CreateDataChannel\",\"ssmmessages:OpenControlChannel\",\"ssmmessages:OpenDataChannel\"],\"Resource\":\"*\"},{\"Effect\": \"Allow\",\"Action\":[\"ec2messages:AcknowledgeMessage\",\"ec2messages:DeleteMessage\",\"ec2messages:FailMessage\",\"ec2messages:GetEndpoint\",\"ec2messages:GetMessages\",\"ec2messages:SendReply\"],\"Resource\":\"*\"}]}")
}
