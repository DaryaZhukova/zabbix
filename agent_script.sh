#!/bin/bash
yum -y install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum -y install zabbix-agent
sed -i 's/Server=127.0.0.1/Server=192.168.14.2/' /etc/zabbix/zabbix_agentd.conf
echo "ListenPort=10050" >> /etc/zabbix/zabbix_agentd.conf
echo "ListenIP=0.0.0.0" >> /etc/zabbix/zabbix_agentd.conf
echo "StartAgents=3" >> /etc/zabbix/zabbix_agentd.conf

systemctl start zabbix-agent



