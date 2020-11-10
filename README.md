# Freeradius com docker e vagrant
Remote Authentication Dial In User Service (RADIUS) é um protocolo de rede que fornece gerenciamento centralizado de Autenticação, Autorização e Contabilização (Accounting em inglês) para usuários que conectam-se a e utilizam um serviço de rede. O RADIUS foi desenvolvido pela Livingston Enterprises Ic. em 1991 como um protocolo de autenticação e contabilização de servidor de acesso, sendo mais tarde introduzido como padrão do Internet Engineering Task Force (IETF)

Projeto criado para Gerenciar o Serviço do Radius com Docker. Foi utilizado o Vagrant para gerenciar a maquina virtual onde irá rodar o Docker
 
Dockerfile baseados
    -- freeradius/freeradius-server:latest
    -- mysql:8.0.22
***

### Modulos Ativados Inicialmente!

  - SQL
  - IPPOOL


#### Adicionando novos Modulos do Freeradius:
 Basta ir no Radius.Dockerfile e criar um link de `Radius/Mods-Available` para `/etc/raddb/mods-enabled` 
 
 ```sh
RUN ln -sf /etc/raddb/mods-available/sql /etc/raddb/mods-enabled/sql
RUN ln -sf /etc/raddb/mods-available/sqlippool /etc/raddb/mods-enabled/sqlippool
 ```

### Criação de Usuario para acessar a maquina virutal por SSH
Basta adicionar no provisionamento da Maquina virtual(Vagrantfile) o seguinte Trecho:

 ```rb
    config.vm.provision "shell", 
    inline: "/vagrant/scripts/verifica-usuario.sh [Nome_Usuario] [Senha]"
 ```

### Criação do Banco de Dados
Para nomear o banco de dados basta adicionar o env `MYSQL_DATABASE` em `Mysql.Dockerfile`

```
 ENV MYSQL_DATABASE AnielRadius
```

> por padrão os schemas do Mysql será inserido automaticamente ao subir a maquina > caso queira mexer em alguma configuração ou adicionar algum sql para rodar ao > > levantar a maquina basta adicionar o arquivo a pasta  `/docker.entrypoint-initdb.d` do Mysql.Dockerfile


```sh
 ADD ./raddb/mods-config/sql/ippool/mysql/schema-ippool.sql /docker-entrypoint-initdb.d/
```

### Backup do Banco de Dados
Ao subir a maquina pela primeira vez foi criado um script para iniciar o serviço de backup 'scripts/iniciando-backup-mysql.sh'

para adicionar no Vagrantfile 
 ``` rb
  config.vm.provision "shell", inline: <<-EOC
    echo "Iniciando o Gerenciador de Tarefas"
    echo "* */6 * * * /bin/sh -c 'sh /scripts/iniciando-backup-mysql.sh [NOME_CONTAINER]'" | crontab -
  EOC
 ```

para iniciar manualmente o backup basta rodar o seguinte comando dentro da maquina virtual
 ```sh
  sh /scritps/iniciando-backup-msyql.sh [NOME_CONTAINER]
 ``` 


### Restaurar Backup para o container do Mysql
``` sh
cat backup.sql | docker exec -i [NOME_CONTAINER] /usr/bin/mysql -u [USER_MYSQL] --password=[USER_PASSWORD_MYSQL] [DATABASE]
```

### CONFIGURANDO TIMEZONE VAGRANTFILE
para configurar horario na maquina virtual basta adicionar o time zone no comando abaixo:
``` rb
config.vm.provision :shell, :inline => "sudo rm /etc/localtime && sudo ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime", run: "always"
```

### Vagrantfile
Configuração básica do Vagrantfile

``` rb
Vagrant.configure("2") do |config|
  config.vm.provider "virutalbox" do |v|
    v.name = "Docker Host"
    v.memory = 1024
    v.cpus = 1
  end

  config.vm.box = "ubuntu/bionic64"

  config.vm.network "public_network"

  config.vm.synced_folder "Radius/", "/Radius"
  config.vm.synced_folder "backup/", "/backup-mysql"
  config.vm.synced_folder "scripts/", "/scripts"

  config.vm.provision "shell",
    inline: "chmod +x /vagrant/scripts/*"

  config.vm.provision "shell",
    inline: "/vagrant/scripts/install-docker.sh"

  config.vm.provision "shell", 
    inline: "/vagrant/scripts/verifica-usuario.sh [USUARIO_SSH] [SENHA_SSH]"

  config.vm.provision "shell", inline: <<-EOC
    sudo sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sudo sed -i 's/#*PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    sudo sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
    sudo systemctl restart sshd.service
    echo "SSH configurado"
  EOC

  
  config.vm.provision "shell", inline: <<-EOC
    echo "Iniciando o Gerenciador de Tarefas"
    echo "* */6 * * * /bin/sh -c 'sh /scripts/iniciando-backup-mysql.sh banco'" | crontab -
  EOC
  
  config.vm.provision :shell, :inline => "sudo rm /etc/localtime && sudo ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime", run: "always"  

  
end

```

### DOCKER COMPOSE
Configuração básica do Docker-Compose
``` rb
version: '3.4'
services: 
    radius:
        container_name: radius
        build:
            context: .
            dockerfile: Radius.Dockerfile
        command:  -X
        ports: 
            - 1812:1812/udp
            - 1813:1813/udp
        restart: always
        networks: 
            - network-radius
        depends_on: 
            - db
    
    db:
        container_name: banco
        build:
            context: .
            dockerfile: Mysql.Dockerfile
        command: --default-authentication-plugin=mysql_native_password
        ports: 
            - 3306:3306
        env_file: .env
        restart: always
        volumes: 
            - type: volumes
              source: db-data
              target: /var/lib/mysql
        networks: 
            - network-radius
        
    
    adminer:
        container_name: adminer
        image: adminer
        restart: always
        ports:
            - 8080:8080
        networks: 
            - network-radius
        depends_on: 
            - db
networks: 
    network-radius:
        driver: bridge
volumes: 
    db-data:
```

### Configuração Environment
``` env
MYSQL_ROOT_PASSWORD=[SENHA_ROOT_PASSWORD]
MYSQL_USER=[USUARIO_MYSQL_RADIUS]
MYSQL_PASSWORD=[SENHA_MYSQL_RADIUS]
```

### INICIANDO MAQUINA VIRTUAL
para iniciar a maquina virtual:

``` sh
cd freeradius-with-docker
 vagrant up
```

para iniciar somente o provisionamento da maquina virtual:

``` sh
cd freeradius-with-docker
 vagrant up --provision
```

para desligar a maquina virtual: 
``` sh
cd freeradius-with-docker
 vagrant halt
```

para destruir a maquina virtual: 
``` sh
cd freeradius-with-docker
 vagrant destroy
```
 >> cuidado ao executar esse comando pois irá apagar todos os dados do banco de dados antes faça um backup para não perder os dados
 
License
----

MIT


**Free Software, Hell Yeah!**
