#!/bin/bash

echo "Iniciando a Atualizacao o do Banco "${DATABASE_NAME}
echo "Usuario - "${MYSQL_USER}
echo "Senha - "$MYSQL_ROOT_PASSWORD

cd .atualizacao-banco/

for line in $(ls)
        do
           echo "Pacote atualizando "$line
           cat $line
           exit_code=$?

          if[$exit_code -ne 0]; then
                done;
           fi
done


echo "Finalizado"