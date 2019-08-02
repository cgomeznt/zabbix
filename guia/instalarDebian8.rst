Instalar el Zabbix en Debian 8 Jessie
========================================

Elige tu plataforma
++++++++++++++++++++

Nos vamos a la siguiente pagina para realizar la descarga del .deb que se encargara de configurar los repositorios de Debian para Zabbix.
https://www.zabbix.com/download?zabbix=3.0&os_distribution=debian&os_version=8_jessie&db=mysql


Instale y configure el servidor Zabbix para su plataforma
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

a. Instalar Zabbix repository::

	# wget https://repo.zabbix.com/zabbix/3.0/debian/pool/main/z/zabbix-release/zabbix-release_3.0-2+jessie_all.deb
	# dpkg -i zabbix-release_3.0-2+jessie_all.deb
	# apt update
	b. Install Zabbix server, frontend, agent
	# apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-agent
	
c. Crear la Base de Datos::

	# mysql -uroot -p
	password
	mysql> create database zabbix character set utf8 collate utf8_bin;
	mysql> grant all privileges on zabbix.* to zabbix@localhost identified by 'password';
	mysql> quit;
	
Importar esquema inicial y datos. Se le pedirá que ingrese su contraseña recién creada.::

	# zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix
	
d. Configure the database for Zabbix server::

Editar el archivo /etc/zabbix/zabbix_server.conf::

	DBPassword=zabbix
	
e. Configurar PHP para la interfaz de Zabbix::
Editar el archivo /etc/zabbix/apache.conf, descomentar la linea::

	# php_value date.timezone Europe/Riga
	
Y cambiarla por nuestra localidad::

	php_value date.timezone America/Caracas

	
f. Inicie el servidor Zabbix y los procesos del agente
Inicie el servidor Zabbix y los procesos del agente y haga que comience en el sistema boot::

	# systemctl restart zabbix-server zabbix-agent apache2
	# systemctl enable zabbix-server zabbix-agent apache2
	
¡Ahora su servidor Zabbix está en funcionamiento!


Configurar la interfaz de Zabbix
Conéctese a su interfaz de Zabbix recién instalada: http://server_ip_or_name/zabbix 
Siga los pasos descritos en la documentación de Zabbix: Instalación de la interfaz.

