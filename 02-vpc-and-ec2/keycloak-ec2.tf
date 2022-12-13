resource "aws_instance" "mysql" {
  ami           = "ami-007a18d38016a0f4e"
  instance_type = "t3.small"
  vpc_security_group_ids = [
    "sg-0d8bdc71aee9f"
  ]
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
mkdir keycloak
# Install keycloak via docker-compose
echo '''version: '3'
volumes:
  mysql_data:
      driver: local
services:
  keycloak:
      image: quay.io/keycloak/keycloak:legacy
      environment:
        DB_VENDOR: MYSQL
        DB_ADDR: mysql
        DB_DATABASE: keycloak
        DB_USER: keycloak
        DB_PASSWORD: password
        KEYCLOAK_USER: admin
        KEYCLOAK_PASSWORD: Pa55w0rd
      ports:
        - 8080:8080
docker-compose -f keycloak/docker-compose.yaml up -d
EOF
  subnet_id = "subnet-00514b9f4cd6d4"
  tags = {
    Name = "${var.prefix}${count.index}"
  }
}
output "keycloak_url" {
  value       = "https://${aws_instance.keycloak.public_ip}:8080"
  description = "Keycloak url"
}