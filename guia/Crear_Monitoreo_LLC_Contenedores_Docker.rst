Crear Monitoreo LLC para contenedores Docker
================================================

Vamos a crear un Template en Zabbix, crear los tres (3) script en los servidores y crear el .conf de Zabbix.

Comandos 
--------------
docker ps --format '{{.Names}}' 
echo '{"data":[';for i in $(docker ps --format '{{.Names}}' ) ;do echo "{\"{#ITEM}\": \"$i\"},";done | sed  '$ s/.$//' ; echo ']}'


Agregar el grupo zabbix dentro del grupo docker
-----------------------------------------------
zabbix dentro del grupo de docker::

        usermod -a -G docker gitlab-runner

Creamos los scripts
--------------------
::

        cat > /usr/local/bin/docker_discovery.sh << 'EOF'
        #!/bin/bash
        echo '{"data":[';for i in $(docker ps --format '{{.Names}}' ) ;do echo "{\"{#ITEM}\": \"$i\"},";done | sed  '$ s/.$//' ; echo ']}'
        EOF 

::

        cat > /usr/local/bin/status_contenedor.sh << 'EOF'
        #!/bin/bash
        
        NAME_CONTENEDOR=$1
        #echo $NAME_CONTENEDOR
        if docker ps --format "table {{.Names}}:{{.Status}}" | tr ' ' ':' | grep $NAME_CONTENEDOR | grep unhealthy > /dev/null ; then
                echo "1"
                #echo "$NAME_CONTENEDOR unhealthy"
                #zabbix_sender  -z 10.133.0.54 -s $NAME_SERVER  -k $NAME_CONTENEDOR -o 1
        else
                echo "0"
                #echo "$NAME_CONTENEDOR healthy"
                #zabbix_sender  -z 10.133.0.54 -s $NAME_SERVER  -k $NAME_CONTENEDOR -o 0
        fi
        EOF

::

        cat > /usr/local/bin/activo_contenedor.sh << 'EOF'
        #!/bin/bash
        
        NAME_CONTENEDOR=$1
        #echo $NAME_CONTENEDOR
        if docker ps --format "table {{.Names}}:{{.Status}}" | grep $1 > /dev/null ; then
                echo "0"
                #echo "$NAME_CONTENEDOR esta vivo"
        else
                echo "1"
                #echo "$NAME_CONTENEDOR NO esta vivo"
        fi
        EOF



Consultamos las configuraciones de zabbix
---------------------------------------------

::

        cat /etc/zabbix_agentd.conf
        PidFile=/run/zabbix/zabbix_agentd.pid
        LogFile=/var/log/zabbix/zabbix_agentd.log
        LogFileSize=0
        Server=10.133.0.54
        ListenIP=10.124.3.161
        ServerActive=10.133.0.54
        Hostname=lrkprdappcashub01
        Include=/etc/zabbix/zabbix_agentd.d/*.conf


Creamos la configuración de LLC para zabbix
-------------------------------------------
::

        cat > /etc/zabbix/zabbix_agentd.d/docker_custom.conf << 'EOF'
        UserParameter=docker.discovery,/usr/local/bin/discover_contenedores.sh;
        UserParameter=docker.status.[*],/usr/local/bin/status_contenedor.sh $1;
        UserParameter=docker.activo.[*],/usr/local/bin/activo_contenedor.sh $1;
        EOF


Otorgamos permisos de execute a los script y reiniciamos zabbix
-------------------------------------------------------------------
::

        chmod +x /usr/local/bin/*.sh && systemctl restart zabbix-agent



Desde el servidor de Zabbix probamos que todo funcione
--------------------------------------------------------
::

        zabbix_get -s 10.124.3.161 -k 'docker.discovery'
        zabbix_get -s 10.124.3.161 -k 'docker.status.[cashub01-ckit-service-1]'
        zabbix_get -s 10.124.3.161 -k 'docker.activo.[cashub01-ckit-service-1]'
        



Se crea un template Docker_Custom
-----------------------------------
::

        Create Discovery rule
        Name: Discovery_Contenedores
        Type: Zabbix Agent
        Key: docker.discovery
        
        Create Item Prototype
        Name: contenedor status of {#ITEM}
        Type: Zabbix Agent
        Key: docker.status.[{#ITEM}]
        Type of information: numeric (unsigned)
        
        Create Item Prototype
        Name: contenedor active of {#ITEM}
        Type: Zabbix Agent
        Key: docker.activo.[{#ITEM}]
        Type of information: numeric (unsigned)

Create Trigger prototype
Name: [Sop App]: El Contenedor{#ITEM} no está ejecutandose
Expression: last(/Docker_Custom/docker.status.[{#ITEM}])=1

