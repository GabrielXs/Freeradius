FROM mysql:8.0.22 as Base
EXPOSE 3306
ENV MYSQL_DATABASE AnielRadius

ADD ./raddb/mods-config/sql/main/mysql/schema.sql /docker-entrypoint-initdb.d/
ADD ./raddb/mods-config/sql/main/mysql/process-radacct.sql /docker-entrypoint-initdb.d/
ADD ./raddb/mods-config/sql/ippool/mysql/schema-ippool.sql /docker-entrypoint-initdb.d/
# ADD ./raddb/mods-config/sql/ippool/mysql/procedure-ippool.sql /docker-entrypoint-initdb.d/






