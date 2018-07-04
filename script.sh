#!/bin/bash

yum -y install mariadb mariadb-server
/usr/bin/mysql_install_db --user=mysql
systemctl start mariadb
mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"

yum -y install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum -y install zabbix-server-mysql zabbix-web-mysql
zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -pzabbix zabbix


echo "DBHost=localhost" >> /etc/zabbix/zabbix_server.conf 
echo "DBName=zabbix" >> /etc/zabbix/zabbix_server.conf 
echo "DBUser=zabbix" >> /etc/zabbix/zabbix_server.conf
echo "DBPassword=zabbix" >> /etc/zabbix/zabbix_server.conf
systemctl start zabbix-server 


sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone Europe\/Minsk/' /etc/httpd/conf.d/zabbix.conf
sed -i 's/DocumentRoot "\/var\/www\/html"/DocumentRoot "\/usr\/share\/zabbix"/' /etc/httpd/conf/httpd.conf
systemctl start httpd

yum -y install zabbix-agent
sed -i 's/Server=127.0.0.1/Server=192.168.14.2/' /etc/zabbix/zabbix_agentd.conf
echo "ListenPort=10050" >> /etc/zabbix/zabbix_agentd.conf
echo "ListenIP=0.0.0.0" >> /etc/zabbix/zabbix_agentd.conf
echo "StartAgents=3" >> /etc/zabbix/zabbix_agentd.conf 

systemctl start zabbix-agent

