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
    inline: "/vagrant/scripts/verifica-usuario.sh sinapse s1n4ps#@2"

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
