FROM freeradius/freeradius-server:latest
EXPOSE 1812/udp
EXPOSE 1813/udp

COPY raddb/ ./etc/raddb
RUN chmod 755 /etc/raddb/ -R

RUN ln -sf /etc/raddb/mods-available/sql /etc/raddb/mods-enabled/sql
RUN ln -sf /etc/raddb/mods-available/sqlippool /etc/raddb/mods-enabled/sqlippool

