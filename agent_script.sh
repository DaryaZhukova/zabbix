#!/bin/bash

yum -y install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum -y install zabbix-agent
sed -i 's/Server=127.0.0.1/Server=192.168.14.2/' /etc/zabbix/zabbix_agentd.conf
echo "ListenPort=10050" >> /etc/zabbix/zabbix_agentd.conf
echo "ListenIP=0.0.0.0" >> /etc/zabbix/zabbix_agentd.conf
echo "StartAgents=3" >> /etc/zabbix/zabbix_agentd.conf
systemctl start zabbix-agent

yum -y install net-tools
#get IP
IP=$(ifconfig | grep 'inet ' | grep '192*'| awk '{print $2}')

#get API token
token=$(curl -k -s POST -H 'Content-Type:application/json' -d'{"jsonrpc": "2.0","method":"user.login","params":{"user":"Admin","password":"zabbix"},"auth": null,"id":1}' http://192.168.14.2/api_jsonrpc.php | grep -Eo "[[:alnum:]]{32}")

#get group ID
group=$(curl -k -s POST -H 'Content-Type: application/json-rpc' -d "{ \"jsonrpc\": \"2.0\", \"method\": \"hostgroup.get\", \"params\": { \"filter\":{\"name\": \"CloudHosts\"}}, \"auth\": \"$token\", \"id\": 1 }" http://192.168.14.2/api_jsonrpc.php|sed 's/.*\"groupid":"\([[:digit:]]*\).*/\1/g')
#get Custom template ID
template=$(curl -k -s POST -H 'Content-Type: application/json-rpc' -d "{ \"jsonrpc\": \"2.0\", \"method\": \"template.get\", \"params\": { \"filter\":{\"name\": \"Custom\"}}, \"auth\": \"$token\", \"id\": 1 }" http://192.168.14.2/api_jsonrpc.php|sed 's/.*\"templateid":"\([[:digit:]]*\).*/\1/g')

#create  group if not exists
re='[0-9]+$'
if ! [[ $group =~ $re ]] ; then group=$(curl -k -s POST -H 'Content-Type: application/json-rpc' -d "{ \"jsonrpc\": \"2.0\", \"method\": \"hostgroup.create\", \"params\": { \"name\": \"CloudHosts\"}, \"auth\": \"$token\", \"id\": 1 }" http://192.168.14.2/api_jsonrpc.php | sed 's/.*\["\(.*\)\"].*/\1/g') ; fi
#create host
curl -k -s POST -H 'Content-Type: application/json-rpc' -d "{ \"jsonrpc\": \"2.0\", \"method\": \"host.create\", \"params\": { \"host\": \"$HOSTNAME\", \"interfaces\": [ { \"type\": 1, \"main\": 1, \"useip\": 1, \"ip\": \"$IP\", \"dns\": \"\", \"port\": \"10050\" } ], \"groups\": [ { \"groupid\": \"$group\" } ], \"templates\": [ { \"templateid\": \"$template\" } ], \"inventory_mode\": 0 } , \"auth\": \"$token\", \"id\": 1 }" http://192.168.14.2/api_jsonrpc.php


