output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.minecraft.id
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.minecraft.public_ip
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.minecraft.id
}