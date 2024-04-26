output "ip_publico" {
  value = aws_instance.marcusServer.public_ip
}

output "ip_privado" {
  value = aws_instance.marcusServer.private_ip
}