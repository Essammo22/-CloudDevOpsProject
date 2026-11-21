resource "aws_security_group" "ec2-sg" {
  description = "security-group of ec2 "
  name        = "ec2-sg"
  vpc_id      = var.vpc_id
  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow to traffic from ec2"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "EC2-SG"
  }

}
resource "aws_instance" "ec2-jenkins" {
  subnet_id                   = var.subnet_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ec2-sg.id]
  ami                         = "ami-084df9e6ad4622caf"
  associate_public_ip_address = true
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  tags = {
    Name = "ec2-jenkins"
  }

}
