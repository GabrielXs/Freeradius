# # Instalando o docker
 curl -fsSL https://get.docker.com -o get-docker.sh
 sudo sh get-docker.sh

# #Instalando Docker-Compose
 sudo apt-get install -y docker-compose
 sudo usermod -aG docker vagrant

#Iniciando os Containers
docker-compose -f /vagrant/Radius/docker-compose.yml up -d --build



