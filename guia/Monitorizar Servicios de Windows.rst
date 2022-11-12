Como monitorizar servicios en Windows
======================================

Con Get service name y con el key service_state, podemos monitorizar servicios en Windows.


Ejemplo:

Utilizaremos el servidor de Edit Package para este ejemplo.

Ingresamos al servidor y nos vamos a service, buscamos el servicio que se quiera monitorizar y le damos boton derecho propiedades,
ahi buscamos, Service Name, ese es el nombre que debemos utilizar.

Service Name: EditPackage4

En Zabbix en un template creamos un ITEM llamado:

Service Status Edit Package

y el Key debe ser:

service_state["EditPackage4"]

El triger debe ser diferente de 0:

[Sop APP] Servicio de Windows EditPackage is Down	
{srv-veditpack:service_state["EditPackage4"].last()}<>0

Service Status tomcat-LGS

service_state["tomcat-LGS"]

[Sop APP] Servicio de Windows tomcat-LGS is Down	
{srv-veditpack:service_state["tomcat-GUI"].last()}<>0