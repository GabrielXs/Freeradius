echo "Iniciando a Instalação do Docker..."
echo "Pegando arquivo de Instalação do Docker"
curl -fsSL https://get.docker.com -o get-docker.sh
echo "Iniciando instalação"
sudo sh get-docker.sh
echo "Instalando Python 3.5"
sudo apt-get install python3.5
echo "Instalando Pip 3.0"
sudo apt-get install python3-pip
#Talvez precisa Reiniciar o pc
echo "Instalando Docker Compose"
pip3 install docker-compose

sudo curl -L --fail https://github.com/docker/compose/releases/download/1.27.4/run.sh -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Configurando deamon Docker"
sudo mkdir -p /etc/systemd/system/docker.service.d/
cp ./override.conf /etc/systemd/system/docker.service.d/

sudo systemctl daemon-reload
sudo systemctl restart docker.service

echo "Gerando chaves de Servidor"


# echo "Autorizando Usuários ... "
# sudo usermod -aG docker $USER 
# sudo usermod -aG docker jenkins