output "public_ip" {
  value = "${aws_instance.webserver.public_dns}"
}

output "vpc_id" {
  value = aws_vpc.app-vpc.id
}
