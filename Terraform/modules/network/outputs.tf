output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
output "public_subnet_id" {
  value = [
    aws_subnet.public_subnet1.id,
    aws_subnet.public_subnet2.id
  ]
}
output "private_subnet_id" {
  value = [
    aws_subnet.private_subnet1.id,
    aws_subnet.private_subnet2.id
  ]

}