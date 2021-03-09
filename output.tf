output "public_ip" {
  value = "${aws_instance.webserver.public_dns}"
}
