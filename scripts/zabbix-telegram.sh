#!/bin/bash

#########################################################################
# Por: Carlos Gomez Gomez
# https://github.com/cgomeznt/
##########################################################################

MAIN_DIRECTORY="/usr/lib/zabbix/alertscripts/"

USER=$1
SUBJECT=$2
SUBJECT="${SUBJECT//,/ }"
MESSAGE="chat_id=${USER}&text=$3"
GRAPHID=$3
GRAPHID=$(echo $GRAPHID | awk -F"[" '{print $2}' | tr -d "]")
ITEMID=$GRAPHID
ZABBIXMSG="/tmp/zabbix-message-$(date "+%Y.%m.%d-%H.%M.%S").tmp"


#############################################
# URL del Zabbix
#############################################
ZBX_URL="http://172.28.111.36/zabbix"

##############################################
# Cuenta valida en el site de zabbix
##############################################

USERNAME="telegram"
PASSWORD="telegram01"

############################################
# El Bot-Token 
############################################

BOT_TOKEN='684219894:AAFen0V2Qrhy5LlChnpnhEOWMtDY6wiTZqY'

#############################################
# Si no quiere enviar GRAFICO / ENVIA_GRAFICO = 0
# Si no quiere enviar MESSAGE / ENVIA_MESSAGE = 0
#############################################

ENVIA_GRAFICO=1
ENVIA_MESSAGE=1

case $GRAPHID in
        ''|*[!0-9]*) ENVIA_GRAFICO=0 ;;
esac


##############################################
# Graficos
##############################################

WIDTH=800
CURL="/usr/bin/curl"
COOKIE="/tmp/telegram_cookie-$(date "+%Y.%m.%d-%H.%M.%S")"
PNG_PATH="/tmp/telegram_graph-$(date "+%Y.%m.%d-%H.%M.%S").png"

############################################
# Periodo de grafico en minutos Exp: 10800min/3600min=3h
############################################

PERIOD=10800


###########################################
# Verifica si pasaron los 3 parametros
# para el script
###########################################

if [ "$#" -lt 3 ]
then
        exit 1
fi

############################################
# Envio Mensage 
############################################

echo "$MESSAGE" > $ZABBIXMSG
${CURL} -k -s -c ${COOKIE} -b ${COOKIE} -s -X GET "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${USER}&text=\"${SUBJECT}\""  > /dev/null

if [ "$ENVIA_MESSAGE" -eq 1 ]
then
	${CURL} -k -s -c ${COOKIE} -b ${COOKIE} --data-binary @${ZABBIXMSG} -X GET "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"  > /dev/null
fi

############################################
# Envio de graficos
############################################

# Se ENVIA_GRAFICO=1 el envia gráfico.
if [ $(($ENVIA_GRAFICO)) -eq '1' ]; then
        ############################################
        # Zabbix iniciando sesion con el usuario en el site
        ############################################

        # Zabbix - Ingles - Verifique no seu Zabbix se na tela de login se o botao de login é "Sign in".
        # Obs.: Caso queira mudar, abra a configuração do usuário Guest e mude a linguagem para Portugues, se fizer isso comente (#) a linha abaixo e descomente a linha Zabbix-Portugues.

                ${CURL} -k -s -c ${COOKIE} -b ${COOKIE} -d "name=${USERNAME}&password=${PASSWORD}&autologin=1&enter=Sign%20in" ${ZBX_URL}"/index.php" # > /dev/null

        # Download do gráfico e envio
               ${CURL} -k -s -c ${COOKIE}  -b ${COOKIE} -d "itemids=${GRAPHID}&itemid=${ITEMID}&period=${PERIOD}&width=${WIDTH}" ${ZBX_URL}"/chart.php" -o "${PNG_PATH}";

        ${CURL} -k -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto" -F chat_id="${USER}" -F photo="@${PNG_PATH}"  # > /dev/null

fi

############################################
# DEBUG
############################################

# Verificar valores recebidos de Zabbix prompt
# cat /tmp/telegram-debug.txt
# echo "User-Telegram=$USER | Subject=$SUBJECT | Menssage=$MESSAGE | GraphID=${GRAPHID} | Period=${PERIOD} | Width=${WIDTH}" >/tmp/telegram-debug.txt

# Test con curl bajar el  gráfico
# Verifique /tmp/telegram-graph.png 
# ${CURL} -k -c ${COOKIE}  -b ${COOKIE} -d "graphid=1459&itemids=1459&period=10800&width=800" 192.168.10.24/zabbix/chart.php > /tmp/telegram-graph.png

#Verificando envio msg

############################################
# Apagando  archivos utilizados  script
############################################

rm -f ${COOKIE}

rm -f ${PNG_PATH}

rm -f ${ZABBIXMSG}
exit 0
