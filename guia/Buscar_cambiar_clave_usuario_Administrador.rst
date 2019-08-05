Buscar y cambiar clave de un usuario Administrador.
=====================================================

Si para el momento del full ya tenemos un usuario Administrador omitimos estos pasos.

Ingresamos al servicio de MySQL::

	# mysql -uroot -p
	Enter password:
	Welcome to the MySQL monitor.  Commands end with ; or \g.
	Your MySQL connection id is 923
	Server version: 5.5.60-0+deb8u1 (Debian)

	Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

	Oracle is a registered trademark of Oracle Corporation and/or its
	affiliates. Other names may be trademarks of their respective
	owners.

	Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

	mysql>
	
Consultamos las Base de datos::

	mysql> show databases;
	+--------------------+
	| Database           |
	+--------------------+
	| information_schema |
	| mysql              |
	| performance_schema |
	| zabbix             |
	+--------------------+
	4 rows in set (0.00 sec)
	mysql>
	
Nos pasamos a la base de datos del Zabbix::

	mysql> use zabbix;
	Reading table information for completion of table and column names
	You can turn off this feature to get a quicker startup with -A

	Database changed
	mysql>

Consultamos las tablas existentes::

	mysql> show tables;
	+------------------------------+
	| Tables_in_zabbix             |
	+------------------------------+
	| REPORTE_EDR_REP              |
	| REPORTE_EDR_REP_v2           |
	| acknowledges                 |
	| actions                      |
	| alerts                       |
	| application_discovery        |
	| application_prototype        |
	| application_template         |
	| applications                 |
	| auditlog                     |
	| auditlog_details             |
	| autoreg_host                 |
	| concil_aa_rep                |
	| conditions                   |
	| config                       |
	| dbversion                    |
	| dchecks                      |
	| dhosts                       |
	| drules                       |
	| dservices                    |
	| escalations                  |
	| events                       |
	| expressions                  |
	| functions                    |
	| globalmacro                  |
	| globalvars                   |
	| graph_discovery              |
	| graph_theme                  |
	| graphs                       |
	| graphs_items                 |
	| group_discovery              |
	| group_prototype              |
	| groups                       |
	| history                      |
	| history_log                  |
	| history_str                  |
	| history_text                 |
	| history_uint                 |
	| host_discovery               |
	| host_inventory               |
	| hostmacro                    |
	| hosts                        |
	| hosts_groups                 |
	| hosts_templates              |
	| housekeeper                  |
	| httpstep                     |
	| httpstepitem                 |
	| httptest                     |
	| httptestitem                 |
	| icon_map                     |
	| icon_mapping                 |
	| ids                          |
	| images                       |
	| interface                    |
	| interface_discovery          |
	| item_application_prototype   |
	| item_condition               |
	| item_discovery               |
	| items                        |
	| items_applications           |
	| maintenances                 |
	| maintenances_groups          |
	| maintenances_hosts           |
	| maintenances_windows         |
	| mappings                     |
	| media                        |
	| media_type                   |
	| nodes                        |
	| opcommand                    |
	| opcommand_grp                |
	| opcommand_hst                |
	| opconditions                 |
	| operations                   |
	| opgroup                      |
	| opinventory                  |
	| opmessage                    |
	| opmessage_grp                |
	| opmessage_usr                |
	| optemplate                   |
	| pivot_edr_rep                |
	| pivot_edr_rep_v2             |
	| profiles                     |
	| proxy_autoreg_host           |
	| proxy_dhistory               |
	| proxy_history                |
	| regexps                      |
	| rights                       |
	| screen_user                  |
	| screen_usrgrp                |
	| screens                      |
	| screens_items                |
	| scripts                      |
	| service_alarms               |
	| services                     |
	| services_links               |
	| services_times               |
	| sessions                     |
	| slides                       |
	| slideshow_user               |
	| slideshow_usrgrp             |
	| slideshows                   |
	| slideshows_                  |
	| sysmap_element_url           |
	| sysmap_url                   |
	| sysmap_user                  |
	| sysmap_usrgrp                |
	| sysmaps                      |
	| sysmaps_elements             |
	| sysmaps_link_triggers        |
	| sysmaps_links                |
	| tblsession                   |
	| timeperiods                  |
	| trends                       |
	| trends_bckp_11092018         |
	| trends_reconversion_19082018 |
	| trends_uint                  |
	| trigger_depends              |
	| trigger_discovery            |
	| triggers                     |
	| user_history                 |
	| users                        |
	| users_groups                 |
	| usrgrp                       |
	| valuemaps                    |
	+------------------------------+
	124 rows in set (0.00 sec)

	mysql>

Consultamos todos los usuarios existentes::


	mysql> select userid, name, alias, passwd from users;
	+--------+---------------------------+-----------+----------------------------------+
	| userid | name                      | alias     | passwd                           |
	+--------+---------------------------+-----------+----------------------------------+
	|      1 | Zabbix                    | Admin     | fda595e193037e9eb45ca6def9e78567 |
	|      2 |                           | guest     | d41d8cd98f00b204e9800998ecf8427e |
	|      8 | zabbix                    | zabbix    | 5fce1b3e34b520afeffb37ce08c7cd66 |
	|      9 | Zabbix                    | root_fv   | 2efb333a64a5b853f834826f213da31e |
	|     10 | MM                        | MMuser    | 93fe39c86ffc11bfe14d7c532e20660a |
	|     11 | MM                        | MMroot    | ff464da8300d383dcacff223033cebba |
	|     14 |                           | as_root   | cc81c9c7bfac1b1133bbdcb0dcb5d889 |
	|     19 | visitante                 | as_user   | face3d7fe9fdcc4ee855b7759be18ea0 |
	|     26 | CCS                       | CCS       | 01c401e3e42a0217b362e491ca1cbae7 |
	|     27 | Maximización de ingresos  | revmax    | b6f99a3786f51a3ee129f883ca27282f |
	|     28 | Infosoft                  | Infosoft  | 11f7523194d24983ab8ee4e703853738 |
	|     29 | DataStage                 | datastage | c8cf8b8c085e04f1652c38bbc84e44e0 |
	|     30 | Plataforma Altamira       | Altamira  | c2cc5bacf7ff7c8692d7f713e344d464 |
	|     31 | Redes                     | redes     | 55bc9b2c9c5e48f174e87bdd42fb3070 |
	|     32 |                           | Canales   | e1ee509e34dd4b45901d774590373b85 |
	|     33 | Michel Vera               | mvera     | 85a152ed56054127d806898d867fc4a1 |
	|     34 | Manuel Tovar              | mtovar    | 36412283e0430233a9bcc705d4703ce5 |
	|     35 | Argenis                   | aramirez  | 8a675a095b45b14dac6c4c3e694e1175 |
	+--------+---------------------------+-----------+----------------------------------+
	18 rows in set (0.00 sec)

	mysql>


Buscamos cuales usuarios son Administradores, (Son los que pertenecen al grupo 7)::


	mysql> select * from users_groups where usrgrpid=7;
	+----+----------+--------+
	| id | usrgrpid | userid |
	+----+----------+--------+
	|  4 |        7 |      1 |
	| 20 |        7 |      9 |
	| 61 |        7 |     33 |
	| 70 |        7 |     34 |
	| 78 |        7 |     35 |
	+----+----------+--------+
	5 rows in set (0.00 sec)

Con esto validamos que los userid, 9, 33, 34, 35 son los Administradores. Para este ejemplo vamos a tomar al usuario root_fv que corresponde con el userid 9, para cambiarle el password y porder utilizarlo.

Vemos el usuario::

	mysql> select name, alias, passwd from users where alias='root_fv';
	+--------+---------+----------------------------------+
	| name   | alias   | passwd                           |
	+--------+---------+----------------------------------+
	| Zabbix | root_fv | 2efb333a64a5b853f834826f213da31e |
	+--------+---------+----------------------------------+
	1 row in set (0.00 sec)

	mysql>

Cambiando el password de un usuario que es administrador::

	mysql> update zabbix.users set passwd=md5('T3l3f0n1c4') where alias='root_fv';
	Query OK, 1 row affected (0.00 sec)
	Rows matched: 1  Changed: 1  Warnings: 0

	mysql>


Conéctese a su interfaz de Zabbix recién instalada: http://server_ip_or_name/zabbix 