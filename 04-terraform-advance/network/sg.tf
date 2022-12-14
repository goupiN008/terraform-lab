resource "aws_security_group" "mysql" {
  name        = "mysql-dev"
  description = "Allow traffic of mysql-dev"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Mysql"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [ aws_security_group.keycloak.id ]
  }
  ingress {
    description      = "Mysql ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  
}

resource "aws_security_group" "keycloak" {
  name        = "keycloak-dev"
  description = "Allow traffic of keycloak-dev"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Keycloak web"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "Keycloak ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  
}