Integrando Zabbix en JIRA
=============================

Crear un ticket en JIRA con wget en REST
++++++++++++++++++++++++++++++++++++++++

curl -D- -u cgomez:America21 -X POST  --data '{"fields":{"project":{"key": "IT"},"summary": "REST Integration Zabbix to JIRA.","description": "Creating of an issue using project keys and issue type names using the REST API","issuetype": {"name": "Request IT"}}}' -H "Content-Type: application/json" https://consisint.atlassian.net/rest/api/2/issue/

Scripts para crear un ticket desde la línea de comando
+++++++++++++++++++++++++++++++++++++++++++++++++++++++

En particular vamos utilizar bash script y adaptado para Zabbix, porque nos parece mas fácil y universal.

Vamos utilizar este::

	#!/bin/bash
	##################################################################################
	#                                                                                #
	# Example script for creating a UserRequest ticket via the REST/JSON webservices #
	#                                                                                #
	##################################################################################
	 
	# JIRA location and credentials, change them to suit your JIRA installation

	JIRA_USER="cgomez"
	JIRA_PWD="America21"
	JIRA_PROJECT="SCM"
	JIRA_SUMMARY="REST Integration Zabbix to JIRA."
	JIRA_DESCRIPTION="Creating of an issue using project keys and issue type names using the REST API"
	JIRA_ISSUE_TYPE="Request IT"
	JIRA_URL="https://consisint.atlassian.net/rest/api/2/issue/"

 
	MESSAGE=$1

	HOST=$(echo -e "$MESSAGE" | grep Host | awk -F ":" '{print $2}'| tr -d " ")
	HOST=$(echo $HOST | tr -d '\r')
	SERVICE=$(echo -e "$MESSAGE" | grep Problem | awk -F ":" '{print $2}')
	SERVICE=$(echo $SERVICE | tr -d "\(\)\[\]\-\:\"")
	SERVICE_STATUS=$(echo -e "$MESSAGE" | grep Severity | awk -F ":" '{print $2}')
	SERVICE_STATUS_TYPE="HARD"

	echo -e "Inicia ticket" > /tmp/creaticket-JIRA.log
	echo -e "El numero de arg es: $#" >> /tmp/creaticket-JIRA.log
	echo -e "$MESSAGE" >> /tmp/creaticket-JIRA.log
	echo -e "##################################" >> /tmp/creaticket-JIRA.log

	echo -e "El host es:$HOST-este" >> /tmp/creaticket-JIRA.log
	echo -e "El servicio es:$SERVICE" >> /tmp/creaticket-JIRA.log
	echo -e "El severity es:$SERVICE_STATUS" >> /tmp/creaticket-JIRA.log
	echo -e "El Type es:$SERVICE_STATUS_TYPE" >> /tmp/creaticket-JIRA.log


	# Default values, adapt them to your configuration
	TICKET_CLASS="UserRequest"
	ORGANIZATION="SELECT Organization JOIN FunctionalCI AS CI ON CI.org_id=Organization.id WHERE CI.name='"${HOST}"'"
	TITLE="$HOST with SERVICE PROBLEM"
	DESCRIPTION="The service $SERVICE is in state $SERVICE_STATUS on $HOST"
	 
	# Let's create the ticket via the REST/JSON API
	curl -D- -u $JIRA_USER:$JIRA_PWD -X POST  --data '{"fields":{"project":{"key": "$JIRA_PROJECT"},"summary": "$JIRA_SUMMARY","description": "$JIRA_DESCRIPTION","issuetype": {"name": "$JIRA_ISSUE_TYPE"}}}' -H "Content-Type: application/json" $JIRA_URL


		RESULT=`wget -q --post-data='auth_user='"${JIRA_USER}"'&auth_pwd='"${JIRA_PWD}"'&json_data='"${JSON_DATA}" --no-check-certificate -O -  "${JIRA_URL}/webservices/rest.php?version=1.0"`
	 
	echo -e "###########################"

		PATTERN='"key":"([0-9])+"'
		if [[ $RESULT =~ $PATTERN ]]; then
		        echo "Ticket created successfully" >> /tmp/creaticket-JIRA.log
		else
		        echo "ERROR: failed to create ticket" >> /tmp/creaticket-JIRA.log
		        echo $RESULT >> /tmp/creaticket-JIRA.log
		fi
	# else
	#         echo "Service State Type != HARD, doing nothing"
	# fi






Como usarlo
++++++++++++++++

Estos serian los argumentos que deben ser cuatro (4)::

	create-ticket.bash <host> <service> <service_status> <service_state_type>


Configuración
++++++++++++++

Cambie las 3 líneas en la parte superior de la secuencia de comandos para ajustarse a su entorno::

	JIRA_USER="cgomez"
	JIRA_PWD="America21"
	JIRA_PROJECT="SCM"
	JIRA_SUMMARY="REST Integration Zabbix to JIRA."
	JIRA_DESCRIPTION="Creating of an issue using project keys and issue type names using the REST API"
	JIRA_ISSUE_TYPE="Request IT"
	JIRA_URL="https://consisint.atlassian.net/rest/api/2/issue/"

Luego cambia los valores por defecto a tu gusto::

	# Default values, adapt them to your configuration
	TICKET_CLASS="UserRequest"
	ORGANIZATION="SELECT Organization JOIN FunctionalCI AS CI ON CI.org_id=Organization.id WHERE CI.name='"${HOST}"'"
	TITLE="Service Down on $1"
	DESCRIPTION="The service $SERVICE is in state $SERVICE_STATUS on $HOST"


Troubleshooting
++++++++++++++++++++++++

Puede probar la creación del ticket ejecutando el script manualmente. Por ejemplo, si existe un servidor llamado Server1 en su JIRA, puede ejecutar el siguiente comando para crear un ticket::

	create-ticket.bash "debian" "Manual Test" "DOWN" "HARD"
	Ticket created successfully

Este otro código lo utilizamos por si falla la creación del ticket igual forma envié la creación de un ticket para verificar este error::

	http://192.168.1.230/JIRA/webservices/rest.php?version=1.1&auth_user=admin&auth_pwd=admin&json_data={"operation":"core/create","class":"UserRequest","output_fields":"id","comment":"ErrtoZabbix","fields":{"org_id":"1","title":"Error create Ticket","description":"Error to create ticket from Zabbix, please contacte the TI Master"}}


Configurando Zabbix
+++++++++++++++++++++++++++++

Ya que tenemos creado el script vamos a copiarlo en el servidor de Zabbix en la siguiente ruta "/usr/lib/zabbix/alertscripts", recordemos que debe tener permisos de ejecución.

En Zabbix debemos crear el "Media Types", nos vamos a "Administration" y le damos "Create Media Type"



.. figure:: ../images/integrations/14.png




Llenamos los campos:
* Name
* Type  - debe ser script
* Script Name - Debe ser tal cual el nombre del script que copiamos en el paso anterior
* Script Parameters - {ALERT.MESSAGE}  - porque en el mensaje le vamos a pasar todos los datos




.. figure:: ../images/integrations/15.png



Ahora el "Media Type" se lo debemos asignar a un usuario en Zabbix con privilegios de Administrador. Nos vamos a "Administration" luego en "Users" y ahí buscamos el usuario indicado



.. figure:: ../images/integrations/16.png



Ahí nos vamos al TAB de Media 



.. figure:: ../images/integrations/17.png



Le damos "add" y buscamos la "Media Type" que creamos agregamos un "Send to" aunque no se utilizara.



.. figure:: ../images/integrations/18.png



Ya lo tenemos asociado al usuario, le damos "Update"



.. figure:: ../images/integrations/19.png



Ahora nos vamos a "Configuration" y en "Action" le damos "Create Action"



.. figure:: ../images/integrations/20.png




En el tab de Action colocamos el, "Name" Cualquiera de nuestro gusto y vamos agregando las condiciones



.. figure:: ../images/integrations/21.png



En "Operations" solo cargamos esto:

* Default subject:

	Default subject


* Default message:

	Host: {HOST.NAME}

	Problem name: {TRIGGER.NAME}

	Severity: {TRIGGER.SEVERITY}


.. figure:: ../images/integrations/22.png



Y la Operacion que vamos agregar es



.. figure:: ../images/integrations/23.png




Lista la configuracón le damos guardar



.. figure:: ../images/integrations/24.png



Nos aseguramos que este habilitado.



.. figure:: ../images/integrations/25.png




Listo, ya con esto cuando en Zabbix se dispare un Trigger esta acción se ejecutara llamando al script y pasándole los datos en el MESSAGE y si todo marcha bien se creara el ticket en JIRA



.. figure:: ../images/integrations/26.png




Ticket creado en JIRA



.. figure:: ../images/integrations/27.png






.. figure:: ../images/integrations/28.png







 




