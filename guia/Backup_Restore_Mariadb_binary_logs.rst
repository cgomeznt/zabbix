Backup and Restore Zabbix 3.x 
===============================

Vamos a realizar un Backup de la Base de Datos Mariadb y luego vamos a simular un desastre y restaurar.

Consultamos antes de realizara el backup::

	# ls -ltrh /var/log/mariadb/
	total 148Kb
	-rw-r----- 1 mysql mysql 368K oct 27 21:28 mariadb.log
	-rw-rw---- 1 mysql mysql 5,8M oct 27 22:19 mariadb-bin.000018
	-rw-rw---- 1 mysql mysql   72 oct 27 22:20 mariadb-bin.index
	-rw-rw---- 1 mysql mysql  43K oct 27 22:21 mariadb-bin.000019

Lo primero que vamos hacer es realizar un fullBackup de la Base de datos::

	# /bin/nice -n 10 /bin/ionice -c2 -n 7 /bin/mysqldump --user=root --password=r00tme zabbix --lock-tables=false --flush-logs --master-data=2 | gzip > zabbixdb.data-dump.sql.gz

Como tenemos configurado en el "my.cf" en el tab "mysqld" los binary logs por eso tenemos las opciones "--flush-logs --master-data=2"::

	log_bin=/var/log/mariadb/mariadb-bin.log
	expire_logs_days=10
	max-binlog-size=1000M

Ingresamos a Mariadb y vamos a eliminar la base de datos de zabbix::

	# mysql -uroot -p
	Enter password: 
	Welcome to the MariaDB monitor.  Commands end with ; or \g.
	Your MariaDB connection id is 528
	Server version: 5.5.60-MariaDB MariaDB Server

	Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

	Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

	MariaDB [(none)]> show databases;
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

	MariaDB [(none)]> drop database zabbix;
	Query OK, 140 rows affected (1.28 sec)

	MariaDB [(none)]> show databases;
	+--------------------+
	| Database           |
	+--------------------+
	| information_schema |
	| faqdb              |
	| mysql              |
	| performance_schema |
	+--------------------+
	4 rows in set (0.00 sec)

	MariaDB [(none)]> quit;
	Bye

Consultamos que se realizara el backup y vemos como se incremento el binay logs::

	# ls -ltrh /var/log/mariadb/
	total 66M
	-rw-r--r-- 1 root  root   60M oct 27 21:05 full_backup.sql
	-rw-r----- 1 mysql mysql 368K oct 27 21:28 mariadb.log
	-rw-rw---- 1 mysql mysql 5,8M oct 27 22:19 mariadb-bin.000018
	-rw-rw---- 1 mysql mysql  108 oct 27 22:21 mariadb-bin.index
	-rw-rw---- 1 mysql mysql  57K oct 27 22:21 mariadb-bin.000019
	-rw-rw---- 1 mysql mysql 2,2K oct 27 22:21 mariadb-bin.000020
	[root@srvscmutils ~]# 

Podemos realizar un respaldo::

	# cp -dpRv /var/log/mariadb/ .
	«/var/log/mariadb/» -> «./mariadb»
	«/var/log/mariadb/mariadb-bin.index» -> «./mariadb/mariadb-bin.index»
	«/var/log/mariadb/mariadb-bin.000019» -> «./mariadb/mariadb-bin.000019»
	«/var/log/mariadb/mariadb-bin.000020» -> «./mariadb/mariadb-bin.000020»
	«/var/log/mariadb/mariadb-bin.000018» -> «./mariadb/mariadb-bin.000018»
	«/var/log/mariadb/full_backup.sql» -> «./mariadb/full_backup.sql»
	«/var/log/mariadb/mariadb.log» -> «./mariadb/mariadb.log»

Ingresamos a Mariadb y creamos nuevamente la Base de Datos de zabbix::

	# mysql -uroot -p
	Enter password: 
	Welcome to the MariaDB monitor.  Commands end with ; or \g.
	Your MariaDB connection id is 2053
	Server version: 5.5.60-MariaDB MariaDB Server

	Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

	Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

	MariaDB [(none)]> show databases;
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

	MariaDB [(none)]> drop database zabbix;
	Query OK, 140 rows affected (1.24 sec)

	MariaDB [(none)]> show databases;
	+--------------------+
	| Database           |
	+--------------------+
	| information_schema |
	| faqdb              |
	| mysql              |
	| performance_schema |
	+--------------------+
	4 rows in set (0.00 sec)

	MariaDB [(none)]> 


	MariaDB [(none)]> create database zabbix character set utf8 collate utf8_bin;
	Query OK, 1 row affected (0.00 sec)

	MariaDB [(none)]> grant all privileges on zabbix.* to zabbix@localhost identified by 'America21';
	Query OK, 0 rows affected (0.00 sec)

	MariaDB [(none)]> quit;
	Bye

Tal cual como en una instalación por primera ves le pasamos los schemas.::

	# zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix
	Enter password: 

Ahora que ya esta nuevamente configurado el zabbix, podemos observar que podemos ingresar con el usuario "Admin" y la clave "zabbix" si hasta este punto estamos bien, vamos a comenzar la Restauración.

Descomprimimos nuestro Respaldo::

	# gunzip zabbixdb.data-dump.sql.gz

Ejecutamos la siguiente instrucción para restaurar la copia en la Base de Datos actual del Zabbix::

	# mysql -uroot -p zabbix < zabbixdb.data-dump.sql 
	Enter password: 

Hasta este punto ya podemos ingresar al Zabbix y vamos observar que tenemos todo hasta la fecha de la cual fue realizado el full Backup

Muestro aquí como vaciar los Binary Logs, pero siempre tendremos errores de Primary Key, por lo cual confió únicamente en el Full Backup.::

	[root@srvscmutils ~]# mysqlbinlog mariadb/mariadb-bin.000019 | mysql -uroot -p
	Enter password: 
	ERROR 1062 (23000) at line 72: Duplicate entry '107' for key 'PRIMARY'

	[root@srvscmutils ~]# mysqlbinlog mariadb/mariadb-bin.000020 | mysql -uroot -p
	Enter password: 
	ERROR 1062 (23000) at line 12: Duplicate entry '107' for key 'PRIMARY'

	[root@srvscmutils ~]# mysqlbinlog mariadb/mariadb-bin.000022 | mysql -uroot -p
	Enter password: 
	ERROR 1062 (23000) at line 132: Duplicate entry '107' for key 'PRIMARY'






