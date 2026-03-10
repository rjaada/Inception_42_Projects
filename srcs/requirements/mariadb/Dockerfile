FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server

COPY tools/init.sh /usr/local/bin/init.sh 
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf


RUN chmod +x /usr/local/bin/init.sh

EXPOSE 3306

CMD ["/usr/local/bin/init.sh"]
