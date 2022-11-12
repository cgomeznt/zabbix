Buenas.

Amigo toda esta información la saque de la pagina oficial de API


Fijate este ejemplo que ponen en este link, https://www.zabbix.com/documentation/current/manual/api/reference/alert/get mira donde dice EXAMPLES

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

Yo primero la comillas dobles les agrego un backslash, eso lo remplazo en un editor de texto de mi gusto y fíjate como queda.

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

Luego le agrego esto en el principio

curl -s -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \


Y esto otro al final 

" $url | \
jq '.' 

Y queda estos asi

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


Guardar la url del zabbix en una variable::

url=https://10.133.0.54/api_jsonrpc.php

Obtener un token

auth=$(curl -s -X POST -H 'Content-Type: application/json-rpc' \
-d '
{"jsonrpc":"2.0","method":"user.login","params":
{"user":"cruz.villarroel","password":"TUPASSWORD"},
"id":1,"auth":null}
' $url | \
jq -r .result
)

Consultar el token

echo $auth

Obtener todos los mapas existentes, cambiar el auth por el del usuario de ese momento, ver Obtener token

curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"map.get","id":1,"auth":"71248da3f8aaf4b1970cd315a9054f","params":{}}' 'https://10.133.0.54/api_jsonrpc.php' | jq '.' | egrep 'sysmapid|name'


Para este ejemplo seleccionamos el sysmapids: 24, que es "name": "Credicard Pagos"
      "sysmapid": "24",
      "name": "Credicard Pagos",

Ejecutamos 

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


Del resultado anterior busquemos estas estas salidas que sabemos estan alarmadas en el MAPA de "Credicard Pagos"

          "label": "API Manager\r\n(Nodo 01)\r\n",
              "hostid": "11713"

          "label": "MQ FTE",
              "hostid": "10467"
                                                 
Ahora armamos el siguiente comando para traer únicamente del hostid 11713 los problemas activos

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

El parámetro severities es el que nos indica si es un 
0 - not classified;
1 - information;
2 - warning;
3 - average;
4 - high;
5 - disaster.

Ver este link y buscar "severity" https://www.zabbix.com/documentation/current/manual/api/reference/event/object#event


Ejecuta este otro para el hostid 10467, es exactamente igual que el anterior solo que es otro hostid

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

Carlos Gómez Gómez
Vicepresidencia de Plataforma y Servicios Tecnológicos.
Gerencia de Soporte Plataforma.
Coordinación Soporte Web.
Telf: 58 (0212)9554207 | 58 0414-5560172
carlos.gomez@credicard.com.ve

 

De: Carlos Gomez 
Enviado el: miércoles, 9 de junio de 2021 2:52 p. m.
Para: Carlos Gomez; cgomeznt
Asunto: Zabbix CURL 

https://blog.zabbix.com/zabbix-api-scripting-via-curl-and-jq/12434/


https://techexpert.tips/es/zabbix-es/zabbix-api-guia-de-inicio-rapido/


curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"apiinfo.version","id":1,"auth":null,"params":{}}' 'https://10.133.0.54/api_jsonrpc.php'

curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{ "params": { "user": "carlos.gomez", "password": "Europa.21" }, "jsonrpc": "2.0", "method": "user.login", "id": 0 }' 'https://10.133.0.54/api_jsonrpc.php'

curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"hostgroup.get","id":1,"auth":"71248da3f8a66af4b1970cd315a9054f","params":{}}' 'https://10.133.0.54/api_jsonrpc.php'


$ curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"apiinfo.version","id":1,"auth":null,"params":{}}' 'https://10.133.0.54/api_jsonrpc.php'

Carlos Gómez Gómez
Vicepresidencia de Plataforma y Servicios Tecnológicos.
Gerencia de Soporte Plataforma.
Coordinación Soporte Web.
Telf: 58 (0212)9554207 | 58 0414-5560172
carlos.gomez@credicard.com.ve

 


________________________________________

“Este correo y cualquier archivo transmitidos con él son confidenciales y previsto solamente para el uso del individuo o de la entidad a quienes se tratan. Si UD. ha recibido este correo por error por favor notificar a abuso@credicard.com.ve. Por favor considere que cualquier opinión presentada en este correo es solamente la del autor y no representa necesariamente la opinión de Consorcio Credicard, C.A. Finalmente, el receptor debe comprobar este correo y cualquier anexo del mismo para identificar la presencia de virus. La compañía no acepta ninguna responsabilidad por ningún daño causado por algún virus transmitido en este correo”.'
