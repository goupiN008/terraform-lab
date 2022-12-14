data "aws_security_group" "mysql" {
  name = "mysql-dev"
}

resource "aws_instance" "mysql" {
  ami           = "ami-0590f3a1742b17914"
  instance_type = "t3.small"
  key_name = aws_key_pair.dev-1.key_name
  vpc_security_group_ids = [data.aws_security_group.mysql.id]
  
  user_data = <<EOF
#!/bin/bash
# Install docker
apt-get update
apt-get install  \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
usermod -aG docker ubuntu
mkdir /home/ubuntu/mysql
# Install mysql via docker-compose
echo '''version: "3"
volumes:
  mysql_data:
      driver: local
services:
  mysql:
      image: mysql:5.7
      volumes:
        - mysql_data:/var/lib/mysql
      ports:
        - 3306:3306
      environment:
        MYSQL_ROOT_PASSWORD: root
        MYSQL_DATABASE: keycloak
        MYSQL_USER: keycloak
        MYSQL_PASSWORD: password''' > /home/ubuntu/mysql/docker-compose.yaml
docker compose -f /home/ubuntu/mysql/docker-compose.yaml up -d > /home/ubuntu/mysql/init-logs.txt
EOF
  subnet_id = var.private_subnet_id
  tags = {
    Name = "mysql"
  }
}
output "mysql_private_ip" {
  value       = "${aws_instance.mysql.private_ip}"
  description = "PrivateIP address details"
  sensitive   = true
}