resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins_vm_sg.id]
  associate_public_ip_address = true
  user_data              = templatefile("${path.module}/install.sh", {})

  tags = var.tags

  root_block_device {
    volume_size = 30
  }
}
resource "aws_security_group" "jenkins_vm_sg" {
  name        = "Jenkins-VM-SG"
  description = "Allow access to Jenkins/SonarQube"
  vpc_id      = var.vpc_id

  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000, 8081, 8082] : {
      description      = "Allow port ${port}"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-VM-SG"
  }
}
