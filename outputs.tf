output "ec2_instance_public_dns" {
  description = "Public DNS of EC2 instance"
  value       = aws_instance.mediawiki.public_dns
}

output "mediawiki_url" {
  description = "URL of wiki"
  value       = "http://${aws_instance.mediawiki.public_ip}/mediawiki"
}
