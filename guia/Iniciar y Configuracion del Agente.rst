Como iniciar el agente Zabbix y su archivo de configuración
=============================================================


AIX
++++++

	$ /usr/zabbix/sbin/zabbix_agentd -c /usr/zabbix/conf/zabbix_agentd.conf
	
	kill -9 PID # de agente de Zabbix

Archivo de configuración del AIX
+++++++++++++++++++++++++++++++++++

	$ grep -v \# /usr/zabbix/conf/zabbix_agentd.conf
	LogFile=/tmp/zabbix_agentd.log
	Server=10.133.0.54
	ListenIP=10.124.0.82
	ServerActive=10.133.0.54
	HostMetadataItem=system.uname
	Include=/usr/zabbix/conf/zabbix_agentd/
	
Linux
+++++++++++

	/etc/init.d/zabbix-agent status
	/etc/init.d/zabbix-agent stop
	/etc/init.d/zabbix-agent start

	systemctl status zabbix-agent
	systemctl stop zabbix-agent
	systemctl start zabbix-agent.

Archivo de configuración en LINUX
+++++++++++++++++++++++++++++++++++
	
	grep -v \# /etc/zabbix/zabbix_agentd.conf
	PidFile=/var/run/zabbix/zabbix_agentd.pid
	LogFile=/var/log/zabbix/zabbix_agentd.log
	LogFileSize=0
	Server=10.133.0.54
	ListenIP=10.134.8.15
	ServerActive=10.134.0.54















Include=/etc/zabbix/zabbix_agentd.d/
