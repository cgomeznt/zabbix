Instalar el Zabbix en Debian 8 Jessie
========================================

Elige tu plataforma
++++++++++++++++++++

Nos vamos a la siguiente pagina para realizar la descarga del .deb que se encargara de configurar los repositorios de Debian para Zabbix.
https://www.zabbix.com/download?zabbix=3.0&os_distribution=debian&os_version=8_jessie&db=mysql


a. Instalar Zabbix repository
++++++++++++++++++++++++++++++
::

	# wget https://repo.zabbix.com/zabbix/3.0/debian/pool/main/z/zabbix-release/zabbix-release_3.0-2+jessie_all.deb
	# dpkg -i zabbix-release_3.0-2+jessie_all.deb
	# apt update
	b. Install Zabbix server, frontend, agent
	# apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-agent
	
c. Crear la Base de Datos
+++++++++++++++++++++++++++
::

	# mysql -uroot -p
	password
	mysql> create database zabbix character set utf8 collate utf8_bin;
	mysql> grant all privileges on zabbix.* to zabbix@localhost identified by 'password';
	mysql> quit;
	
Importar esquema inicial y datos. Se le pedirá que ingrese su contraseña recién creada.::

	# zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix
	
d. Configure the database for Zabbix server
++++++++++++++++++++++++++++++++++++++++++++
::

Editar el archivo /etc/zabbix/zabbix_server.conf::

	DBPassword=zabbix
	
e. Configurar PHP para la interfaz de Zabbix
+++++++++++++++++++++++++++++++++++++++++++++

Editar el archivo /etc/zabbix/apache.conf, descomentar la linea::

	# php_value date.timezone Europe/Riga
	
Y cambiarla por nuestra localidad::

	php_value date.timezone America/Caracas

	
f. Inicie el servidor Zabbix y los procesos del agente
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Inicie el servidor Zabbix y los procesos del agente y haga que comience en el sistema boot::

	# systemctl restart zabbix-server zabbix-agent apache2
	# systemctl enable zabbix-server zabbix-agent apache2
	
¡Ahora su servidor Zabbix está en funcionamiento!

Backup and Restore Zabbix 3.0.14 
===============================

Vamos a realizar un Backup de la Base de Datos MySQL y luego vamos a simular un desastre y restaurar.

Realizar un fullBackup de la Base de datos::

	# /bin/nice -n 10 /bin/ionice -c2 -n 7 /bin/mysqldump --user=zabbix --password=zabbix zabbix --lock-tables=false --flush-logs --master-data=2 | gzip > zabbixdb.data-dump.sql.gz

Ingresamos a MySQL y creamos nuevamente la Base de Datos de zabbix::

	# mysql -uroot -p
	Enter password: 
	Welcome to the MySQL monitor.  Commands end with ; or \g.
	Your MySQL connection id is 2053
	Server version: 5.5.60-MySQL MySQL Server

	Copyright (c) 2000, 2018, Oracle, MySQL Corporation Ab and others.

	Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

	MySQL [(none)]> show databases;
	+--------------------+
	| Database           |
	+--------------------+
	| information_schema |
	| faqdb              |
	| mysql              |
	| performance_schema |
	| zabbix             |
	+--------------------+
	5 rows in set (0.00 sec)

	MySQL [(none)]> drop database zabbix;
	Query OK, 140 rows affected (1.24 sec)

	MySQL [(none)]> show databases;
	+--------------------+
	| Database           |
	+--------------------+
	| information_schema |
	| faqdb              |
	| mysql              |
	| performance_schema |
	+--------------------+
	4 rows in set (0.00 sec)

	MySQL [(none)]> 


	MySQL [(none)]> create database zabbix character set utf8 collate utf8_bin;
	Query OK, 1 row affected (0.00 sec)

	MySQL [(none)]> grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
	Query OK, 0 rows affected (0.00 sec)

	MySQL [(none)]> quit;
	Bye

Tal cual como en una instalación por primera ves le pasamos los schemas.::

	# zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix
	Enter password: 

Comenzar la Restauración.
+++++++++++++++++++++++++

Descomprimimos nuestro Respaldo::

	# gunzip zabbixdb.data-dump.sql.gz

Ejecutamos la siguiente instrucción para restaurar la copia en la Base de Datos actual del Zabbix::

	# mysql -uroot -p zabbix < zabbixdb.data-dump.sql 
	Enter password: 

Hasta este punto ya podemos ingresar al Zabbix y vamos observar que tenemos todo hasta la fecha de la cual fue realizado el full Backup


Conéctese a su interfaz de Zabbix recién instalada: http://server_ip_or_name/zabbix 
Siga los pasos descritos en la documentación de Zabbix: Instalación de la interfaz.

