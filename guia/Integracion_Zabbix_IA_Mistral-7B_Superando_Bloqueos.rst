=====================================================
Integración Zabbix + Mistral-7B Superando Bloqueos
=====================================================

.. contents:: Tabla de Contenidos
   :depth: 3
   :local:

1. Configuración Inicial
=======================

1.1. Requisitos Previos
----------------------

.. code-block:: bash

   # Instalar dependencias básicas
   sudo apt-get update
   sudo apt-get install -y python3-pip curl jq git
   pip3 install transformers torch huggingface-hub requests

1.2. Configuración de Acceso Alternativo
--------------------------------------

.. code-block:: bash

   # Opción 1: Túnel SSH como proxy
   ssh -D 1080 -N -f usuario@servidor-externo.com
   
   # Opción 2: Configurar proxy en entorno
   export ALL_PROXY=socks5h://127.0.0.1:1080
   export HTTPS_PROXY=socks5h://127.0.0.1:1080

2. Implementación del Script
============================

2.1. Guardar el Script de Integración
------------------------------------

Crear ``/usr/lib/zabbix/mistral_zabbix_integration.sh`` con:

.. code-block:: bash
   :linenos:

   #!/bin/bash
   # Configuración
   HUGGINGFACE_API_KEY="TU_API_KEY"
   MODEL="mistralai/Mistral-7B-Instruct-v0.2"
   
   # [Resto de tu script original...]
   
   # Modificación para proxy
   RESPONSE=$(curl -s -x socks5h://127.0.0.1:1080 -X POST \
     "https://api-inference.huggingface.co/models/${MODEL}" \
     -H "Authorization: Bearer ${HUGGINGFACE_API_KEY}" \
     -H "Content-Type: application/json" \
     -d '{"inputs": '"${CLEAN_PROMPT}"'}')

2.2. Permisos y Propiedad
-------------------------

.. code-block:: bash

   chmod +x /usr/lib/zabbix/mistral_zabbix_integration.sh
   chown zabbix:zabbix /usr/lib/zabbix/mistral_zabbix_integration.sh

3. Configuración en Zabbix
=========================

3.1. Script Externo
------------------

+---------------------+---------------------------------------------------+
| Campo               | Valor                                             |
+=====================+===================================================+
| Name                | Mistral-7B Trigger Analysis                      |
+---------------------+---------------------------------------------------+
| Type                | Script                                            |
+---------------------+---------------------------------------------------+
| Execute on          | Zabbix server                                     |
+---------------------+---------------------------------------------------+
| Command            | ``/usr/lib/zabbix/mistral_zabbix_integration.sh`` |
|                     | ``"{TRIGGER.NAME}" "{HOST.NAME}"``                |
|                     | ``"{TRIGGER.SEVERITY}" "{TRIGGER.DESCRIPTION}"``  |
+---------------------+---------------------------------------------------+

3.2. Item para Recepción
-----------------------

+---------------------+------------------------------+
| Parámetro           | Valor                        |
+=====================+==============================+
| Name                | Mistral-7B Analysis Results  |
+---------------------+------------------------------+
| Type                | Zabbix trapper               |
+---------------------+------------------------------+
| Key                 | ``mistral.analysis``         |
+---------------------+------------------------------+
| Type of information | Text                         |
+---------------------+------------------------------+

4. Formateo RST de Respuestas
=============================

4.1. Script de Conversión
------------------------

Crear ``/usr/lib/zabbix/format_rst_response.sh``:

.. code-block:: bash
   :linenos:

   #!/bin/bash
   INPUT="$1"
   HOST="$2"
   
   # Encabezado RST
   echo ".. _mistral_analysis:"
   echo ""
   echo "=============================="
   echo "Análisis de Incidente - Mistral-7B"
   echo "=============================="
   echo ""
   
   # Procesamiento de secciones
   echo "$INPUT" | awk '
   /1\. Posible causa raíz/ {
     print "**Causa Raíz**"
     print "------------"
     print ""
     getline
     while ($0 !~ /2\. Pasos para diagnosticar/) {
       print "- " $0
       getline
     }
     print ""
   }
   # [Resto del formateador...]
   '

4.2. Integración con Zabbix
--------------------------

Modificar el script original para incluir al final:

.. code-block:: bash

   # Formatear y enviar a Zabbix
   RST_SOLUTION=$(/usr/lib/zabbix/format_rst_response.sh "$SOLUTION" "$ZABBIX_HOSTNAME")
   echo "$RST_SOLUTION" | zabbix_sender -z 127.0.0.1 -s "$ZABBIX_HOSTNAME" -k mistral.analysis -o -

5. Solución Local (Alternativa)
==============================

5.1. Descargar Modelo
---------------------

.. code-block:: bash

   python3 -c "
   from transformers import AutoModelForCausalLM, AutoTokenizer
   tokenizer = AutoTokenizer.from_pretrained('mistralai/Mistral-7B-Instruct-v0.2',
              use_auth_token='$HUGGINGFACE_API_KEY')
   model = AutoModelForCausalLM.from_pretrained('mistralai/Mistral-7B-Instruct-v0.2',
            use_auth_token='$HUGGINGFACE_API_KEY')
   "

5.2. Script de Inferencia Local
------------------------------

Crear ``/usr/lib/zabbix/local_mistral.py``:

.. code-block:: python
   :linenos:

   #!/usr/bin/env python3
   from transformers import AutoModelForCausalLM, AutoTokenizer
   import sys
   import json
   
   model = AutoModelForCausalLM.from_pretrained("/opt/mistral-7b")
   tokenizer = AutoTokenizer.from_pretrained("/opt/mistral-7b")
   
   inputs = tokenizer(sys.argv[1], return_tensors="pt")
   outputs = model.generate(**inputs, max_new_tokens=200)
   print(tokenizer.decode(outputs[0], skip_special_tokens=True))

6. Visualización en Zabbix
=========================

6.1. Configurar Frontend
-----------------------

Editar ``/etc/zabbix/web/zabbix.conf.php``:

.. code-block:: php

   $ZBX_SERVER_NAME = 'Zabbix con IA';
   $IMAGE_FORMAT = IMAGE_FORMAT_RST;

6.2. Widget Personalizado
------------------------

+---------------------+-----------------------------------------+
| Parámetro           | Valor                                   |
+=====================+=========================================+
| Type                | Plain text                              |
+---------------------+-----------------------------------------+
| Items               | mistral.analysis                        |
+---------------------+-----------------------------------------+
| Show text as        | HTML                                    |
+---------------------+-----------------------------------------+
| RST rendering       | Enabled                                 |
+---------------------+-----------------------------------------+

7. Ejemplo de Salida
====================

.. code-block:: rst

   .. _mistral_analysis:

   ==============================
   Análisis de Incidente - Mistral-7B
   ==============================

   **Causa Raíz**
   ------------
   - Alta carga de CPU en servidor DB01
   - Consultas SQL no optimizadas

   **Diagnóstico**
   -------------
   1. Verificar carga con ``top``
   2. Analizar consultas MySQL lentas
   3. Revisar logs de /var/log/mysql

   **Solución**
   ----------
   → Optimizar consultas identificadas
   → Ajustar buffers de MySQL
   → Programar mantenimiento

   **Comandos**
   ----------
   .. code-block:: bash

      mysqldumpslow -s t /var/log/mysql/mysql-slow.log
      SET GLOBAL innodb_buffer_pool_size=2G;
      ANALYZE TABLE problematic_table;

   .. footer:: Generado el 15/11/2023 14:30 (UTC-4)

8. Monitoreo y Mantenimiento
===========================

.. list-table:: Items de Monitoreo Recomendados
   :widths: 30 50 20
   :header-rows: 1

   * - Nombre
     - Descripción
     - Frecuencia
   * - ``mistral.api.status``
     - Estado de conexión a API
     - 5m
   * - ``mistral.response.time``
     - Tiempo de respuesta
     - Trigger
   * - ``mistral.log.size``
     - Tamaño de logs
     - 1h

**Nota**: Para mantener la privacidad, considera:
- Rotar tokens API periódicamente
- Limitar acceso a logs
- Cifrar comunicaciones Zabbix-AI
