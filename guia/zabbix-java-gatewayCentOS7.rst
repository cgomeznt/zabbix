Instalar Zabbix-java-gateway en CentOS 7
========================================


Descripción general
++++++++++++++++++++++++

El soporte nativo para monitorear aplicaciones JMX existe en forma de un demonio Zabbix llamado "Zabbix Java gateway", disponible desde Zabbix 2.0. La puerta de enlace Zabbix Java es un demonio escrito en Java. Para averiguar el valor de un contador JMX particular en un host, el servidor Zabbix consulta la puerta de enlace Java Zabbix, que utiliza la API de administración JMX para consultar la aplicación de interés de forma remota. La aplicación no necesita ningún software adicional instalado, solo tiene que iniciarse con la -Dcom.sun.management.jmxremoteopción en la línea de comando.

La puerta de enlace Java acepta la conexión entrante del servidor o proxy Zabbix y solo se puede utilizar como un "proxy pasivo". A diferencia del proxy Zabbix, también se puede usar desde el proxy Zabbix (los proxies Zabbix no se pueden encadenar). El acceso a cada puerta de enlace Java se configura directamente en el servidor Zabbix o en el archivo de configuración del proxy, por lo que solo se puede configurar una puerta de enlace Java por servidor Zabbix o proxy Zabbix. Si un host tendrá elementos de tipo agente JMX y elementos de otro tipo, solo los elementos del agente JMX se pasarán a la puerta de enlace Java para su recuperación.

Cuando un elemento debe actualizarse a través de la puerta de enlace Java, el servidor o proxy Zabbix se conectará a la puerta de enlace Java y solicitará el valor, que la puerta de enlace Java a su vez recupera y devuelve al servidor o proxy. Como tal, la puerta de enlace de Java no almacena en caché ningún valor.

El servidor o proxy Zabbix tiene un tipo específico de procesos que se conectan a la puerta de enlace de Java, controlado por la opción StartJavaPollers . Internamente, la puerta de enlace Java inicia varios subprocesos, controlados por la opción START_POLLERS . En el lado del servidor, si una conexión tarda más de segundos de tiempo de espera , se terminará, pero la puerta de enlace de Java aún puede estar ocupada recuperando el valor del contador JMX. Para solucionar esto, existe la opción TIMEOUT en la puerta de enlace Java que permite establecer el tiempo de espera para las operaciones de la red JMX.

El servidor o proxy Zabbix intentará agrupar las solicitudes a un solo destino JMX tanto como sea posible (afectado por los intervalos de elementos) y enviarlas a la puerta de enlace de Java en una sola conexión para un mejor rendimiento.

Se sugiere tener StartJavaPollers menor o igual que START_POLLERS ; de lo contrario, puede haber situaciones en las que no haya subprocesos disponibles en la puerta de enlace de Java para atender las solicitudes entrantes; en tal caso, la puerta de enlace Java usa ThreadPoolExecutor.CallerRunsPolicy, lo que significa que el hilo principal atenderá la solicitud entrante y temporalmente no aceptará ninguna solicitud nueva.

ver link oficial: https://www.zabbix.com/documentation/current/en/manual/concepts/java/from_rhel_centos


Instalar Zabbix Java Gateway
++++++++++++++++++++++++++++

Una vez que ya tengamos los repositorios de Zabbix, procedemos con la instalación::

	# yum install zabbix-java-gateway


Configurar y ejecutar Java gateway
+++++++++++++++++++++++++++++++++++++

Configuración de los parametros para Zabbix Java gateway pueden ser tuneados en este archivo::

	/etc/zabbix/zabbix_java_gateway.conf

Estos son los parametros más comunes para iniciar esta configuración::

	LISTEN_IP="192.168.1.20"
	LISTEN_PORT=10052
	PID_FILE="/var/run/zabbix/zabbix_java.pid"
	START_POLLERS=5
	TIMEOUT=30

Para mayor detalle ver este link: https://www.zabbix.com/documentation/current/en/manual/appendix/config/zabbix_java


Iniciar Zabbix Java gateway::

	# systemctl enable zabbix-java-gateway

	# systemctl start zabbix-java-gateway

	# systemctl status zabbix-java-gateway

Verificamos que levante el puerto::

	# netstat -natp | grep 10052
	tcp6       0      0 192.168.1.20:10052      :::*                    LISTEN      57075/java


Configuración del servidor para su uso con la puerta de enlace de Java
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Con la Zabbix java Gateway en funcionamiento, debe decirle al servidor Zabbix dónde encontrar al Zabbix java Gateway. Esto se hace especificando los parámetros JavaGateway y JavaGatewayPort en el archivo de configuración del servidor. Si el servidor en el que se está ejecutando la aplicación JMX es monitoreado por el proxy Zabbix, entonces usted especifica los parámetros de conexión en el archivo de configuración del proxy.
vi /etc/zabbix/zabbix_server.conf::


	JavaGateway=192.168.3.20
	JavaGatewayPort=10052

De forma predeterminada, el servidor no inicia ningún proceso relacionado con la supervisión de JMX. Sin embargo, si desea utilizarlo, debe especificar el número de instancias pre-forked de los pollers Java. Lo hace de la misma manera que especifica los poller y trappers habituales.

	StartJavaPollers = 5

No olvide reiniciar el servidor o el proxy, una vez que haya terminado de configurarlos::

	systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm


Debugging Java gateway
++++++++++++++++++++++++

Zabbix Java gateway el archvio de Log es::

	/var/log/zabbix/zabbix_java_gateway.log

Si queremos incrementar el nivel del Log. Editamos el archivo::

	/etc/zabbix/zabbix_java_gateway_logback.xml

Y cambiamos el level="info" a "debug" o puede ser "trace" (para un profundo troubleshooting)::

	<configuration scan="true" scanPeriod="15 seconds">
	[...]
	      <root level="info">
		      <appender-ref ref="FILE" />
	      </root>
	</configuration>


