output "ec2_instance_public_dns" {
	value = aws_instance.mediawiki.public_dns
}

output "mediawiki_url" {
	value = "http://${aws_instance.mediawiki.public_ip}/mediawiki"
}
