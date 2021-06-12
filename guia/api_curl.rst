Como trabajar con la API de Zabbix
=================================

Todo esta en la pagina oficial de API


Este ejemplo que esta en el link, https://www.zabbix.com/documentation/current/manual/api/reference/alert/get veamos el apartado de EXAMPLES::

	{
	    "jsonrpc": "2.0",
	    "method": "alert.get",
	    "params": {
		"output": "extend",
		"actionids": "3"
	    },
	    "auth": "038e1d7b1735c6a5436ee9eae095879e",
	    "id": 1
	}

Lo primero que debemos hacer para poder utilizar esta API con la ayuda del comando **curl**, es colocar en donde están las comillas dobles, les agregamos un backslash, eso lo podemos reemplazar con la ayuda de nuestro editor preferido y así queda.::

	{
	    \"jsonrpc\": \"2.0\",
	    \"method\": \"alert.get\",
	    \"params\": {
		\"output\": \"extend\",
		\"actionids\": \"3\"
	    },
	    \"auth\": \"038e1d7b1735c6a5436ee9eae095879e\",
	    \"id\": 1
	}

Luego le agregamos esto en el principio::

	curl -s -X POST \
	-H 'Content-Type: application/json-rpc' \
	-d " \


Y esto otro al final ::

	" $url | \
	jq '.' 

Y queda de esta forma::

	curl -s -X POST \
	-H 'Content-Type: application/json-rpc' \
	-d " \
	{
	    \"jsonrpc\": \"2.0\",
	    \"method\": \"alert.get\",
	    \"params\": {
		\"output\": \"extend\",
		\"actionids\": \"3\"
	    },
	    \"auth\": \"038e1d7b1735c6a5436ee9eae095879e\",
	    \"id\": 1
	}
	" $url | \
	jq '.' 


Ahora si vamos con la acción
++++++++++++++++++++++++++++


Guardar la url del zabbix en una variable::

	url=https://10.133.0.54/api_jsonrpc.php

Obtener un token y guardarlo en la variable::

	auth=$(curl -s -X POST -H 'Content-Type: application/json-rpc' \
	-d '
	{"jsonrpc":"2.0","method":"user.login","params":
	{"user":"cruz.villarroel","password":"TUPASSWORD"},
	"id":1,"auth":null}
	' $url | \
	jq -r .result
	)

Consultar el token::

	echo $auth

Obtener todos los mapas existentes, cambiar el auth por el del usuario de ese momento, ver Obtener token::

	curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"map.get","id":1,"auth":"71248da3f8aaf4b1970cd315a9054f","params":{}}' 'https://10.133.0.54/api_jsonrpc.php' | jq '.' | egrep 'sysmapid|name'


Para este ejemplo seleccionamos el sysmapids: 24, que es "name": "MyMaps"::

      "sysmapid": "24",
      "name": "MyMaps",

Ejecutamos::

	curl -s -X POST \
	-H 'Content-Type: application/json-rpc' \
	-d " \
	{
	    \"jsonrpc\": \"2.0\",
	    \"method\": \"map.get\",
	    \"params\": {
		\"output\": \"extend\",
		\"selectSelements\": \"extend\",
		\"selectLinks\": \"extend\",
		\"selectUsers\": \"extend\",
		\"selectUserGroups\": \"extend\",
		\"selectShapes\": \"extend\",
		\"selectLines\": \"extend\",
		\"sysmapids\": \"24\"
	    },
	    \"auth\": \"$auth\",
	    \"id\": 1
	}
	" $url | \
	jq '.' | egrep 'label|hostid'


Del resultado anterior busquemos estas salidas que sabemos están alarmadas en el MAPA de "MyMaps"

          "label": "API Manager\r\n(Nodo 01)\r\n",
              "hostid": "11713"

          "label": "MQ FTE",
              "hostid": "10467"
                                                 
Ahora armamos el siguiente comando para traer únicamente del hostid 11713 los problemas activos::

	curl -s -X POST \
	-H 'Content-Type: application/json-rpc' \
	-d " \
	{
	    \"jsonrpc\": \"2.0\",
	    \"method\": \"problem.get\",
	    \"params\": {
		\"output\": \"extend\",
		\"hostids\": \"11713\",
		\"severities\": \"2\",
		\"selectAcknowledges\": \"extend\",
		\"selectTags\": \"extend\",
		\"selectSuppressionData\": \"extend\",
		\"recent\": \"true\",
		\"sortfield\": [\"eventid\"],
		\"sortorder\": \"DESC\"
	    },
	    \"auth\": \"$auth\",
	    \"id\": 1
	}
	" $url | \
	jq '.'

El parámetro severities es el que nos indica si es un:

0 - not classified;

1 - information;

2 - warning;

3 - average;

4 - high;

5 - disaster.

Ver este link y buscar "severity" https://www.zabbix.com/documentation/current/manual/api/reference/event/object#event


Ejecuta este otro para el hostid 10467, es exactamente igual que el anterior solo que es otro hostid::

	curl -s -X POST \
	-H 'Content-Type: application/json-rpc' \
	-d " \
	{
	    \"jsonrpc\": \"2.0\",
	    \"method\": \"problem.get\",
	    \"params\": {
		\"output\": \"extend\",
		\"hostids\": \"10467\",
		\"severities\": \"2\",
		\"selectAcknowledges\": \"extend\",
		\"selectTags\": \"extend\",
		\"selectSuppressionData\": \"extend\",
		\"recent\": \"true\",
		\"sortfield\": [\"eventid\"],
		\"sortorder\": \"DESC\"
	    },
	    \"auth\": \"$auth\",
	    \"id\": 1
	}
	" $url | \
	jq '.'


Todo lo anterior estamos utilizando la API problem.get, hay muchas más API ver la pagina oficial

