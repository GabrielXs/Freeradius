#! /bin/bash

if [ "$1" = "" ] || [ "$2" = "" ]; then
	echo "parametros não informado"
exit 1

else
	if [ "$(cat /etc/passwd| grep -i $1| wc -l)" = "1" ]; then
	    echo "Usuário já cadastrado"
		exit 0
	else
		sudo useradd -m $1
		echo "$1:$2" | sudo chpasswd
		sudo usermod -aG sudo $1
		sudo usermod -aG docker $1
		echo "Usuário $1 - $2 cadastrado"
		exit 0
	fi

fi
