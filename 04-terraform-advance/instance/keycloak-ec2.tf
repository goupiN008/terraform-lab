data "aws_security_group" "keycloak" {
  name = "keycloak-dev"
}

resource "aws_instance" "keycloak" {
  ami           = "ami-0590f3a1742b17914"
  instance_type = "t3.small"
  key_name = aws_key_pair.dev-1.key_name
  vpc_security_group_ids = [data.aws_security_group.keycloak.id]
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
mkdir /home/ubuntu/keycloak
# Install keycloak via docker-compose
echo '''version: "3"
volumes:
  mysql_data:
      driver: local
services:
  keycloak:
      image: quay.io/keycloak/keycloak:legacy
      environment:
        DB_VENDOR: MYSQL
        DB_ADDR: ${aws_instance.mysql.private_ip}
        DB_DATABASE: keycloak
        DB_USER: keycloak
        DB_PASSWORD: password
        KEYCLOAK_USER: admin
        KEYCLOAK_PASSWORD: Pa55w0rd
      ports:
        - 8080:8080''' > /home/ubuntu/keycloak/docker-compose.yaml
docker compose -f /home/ubuntu/keycloak/docker-compose.yaml up -d > /home/ubuntu/keycloak/init-logs.txt
EOF
  subnet_id = var.public_subnet_id
  tags = {
    Name = "keycloak"
  }
}
output "keycloak_url" {
  value       = "http://${aws_instance.keycloak.public_ip}:8080"
  description = "Keycloak url"
}