Vagrant.configure("2") do |config|
  config.vm.provider "virutalbox" do |v|
    v.name = "Docker Host"
    v.memory = 1024
    v.cpus = 1
  end

  config.vm.box = "ubuntu/bionic64"

  config.vm.network "public_network"

  config.vm.provision "shell",
    inline: "chmod +x /vagrant/scripts/*"


  config.vm.provision "shell", inline: <<-EOC
    sudo sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sudo sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
    sudo systemctl restart sshd.service
    echo "finished"
  EOC

  config.vm.provision "shell",
    inline: "/vagrant/scripts/install-docker.sh"
  

  
end
