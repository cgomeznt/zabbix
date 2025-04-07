==================================================
Integración de Zabbix 7.2 con Deepseek para Alertas
==================================================

Objetivo
--------
1. Consultar la API de Deepseek al ocurrir una alarma en Zabbix
2. Enviar solución automatizada por correo electrónico (SMTP local)
3. Gestionar el flujo completo mediante Actions de Zabbix

Prerrequisitos
--------------
- Zabbix 7.2 instalado y funcionando
- SMTP local configurado y operativo
- API Key de Deepseek (obtenida desde https://platform.deepseek.com/)
- Acceso root/administrador al servidor Zabbix

-------------------------
Paso 1: Script de Consulta
-------------------------

Crear script Python para interactuar con Deepseek API:

.. code-block:: python

    #!/usr/bin/env python3
    import requests
    import sys
    import json

    DEEPSEEK_API_KEY = "tu-api-key-deepseek"
    DEEPSEEK_ENDPOINT = "https://api.deepseek.com/v1/chat/completions"

    def get_deepseek_solution(alert_message):
        headers = {
            "Authorization": f"Bearer {DEEPSEEK_API_KEY}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": "deepseek-chat",
            "messages": [
                {
                    "role": "system",
                    "content": "Eres un experto en Zabbix. Proporciona análisis conciso (máx. 150 palabras) de alarmas con: 1) Causa probable 2) Pasos de solución"
                },
                {
                    "role": "user",
                    "content": f"Alarma Zabbix: {alert_message}. Analiza y provee solución técnica:"
                }
            ],
            "temperature": 0.7
        }

        try:
            response = requests.post(DEEPSEEK_ENDPOINT, headers=headers, json=payload)
            response.raise_for_status()
            return response.json()['choices'][0]['message']['content']
        except Exception as e:
            return f"Error consultando Deepseek: {str(e)}"

    if __name__ == "__main__":
        alert_msg = sys.argv[1]
        print(get_deepseek_solution(alert_msg))

Instalación del script:
^^^^^^^^^^^^^^^^^^^^^^^

1. Guardar en ``/usr/lib/zabbix/alertscripts/zabbix_deepseek.py``
2. Asignar permisos:

   .. code-block:: bash

      chmod +x /usr/lib/zabbix/alertscripts/zabbix_deepseek.py
      pip3 install requests

----------------------------
Paso 2: Configurar Media Type
----------------------------

1. Navegar a **Administration → Media Types → Create Media Type**
2. Configurar parámetros:

   +------------------+-------------------------------+
   | Campo            | Valor                         |
   +==================+===============================+
   | Name             | Deepseek Alerts               |
   +------------------+-------------------------------+
   | Type             | Script                        |
   +------------------+-------------------------------+
   | Script name      | zabbix_deepseek.py            |
   +------------------+-------------------------------+
   | Script parameters| {ALERT.MESSAGE}               |
   +------------------+-------------------------------+

------------------------
Paso 3: Configurar Action
------------------------

1. Ir a **Configuration → Actions**
2. Crear nueva Action:

   **General Tab:**
   
   - Name: ``Deepseek Auto-Resolution``
   - Conditions:
     * Trigger severity = Not classified (o las necesarias)
     * Host group = Your_Group (opcional)

   **Operations Tab:**
   
   +---------------------+------------------------------------+
   | Parámetro           | Configuración                      |
   +=====================+====================================+
   | Operation type      | Send message                       |
   +---------------------+------------------------------------+
   | Send to Users       | Seleccionar grupos destino         |
   +---------------------+------------------------------------+
   | Send only to        | Deepseek Alerts (Media Type)       |
   +---------------------+------------------------------------+
   | Message details    | Ver plantilla abajo                |
   +---------------------+------------------------------------+

----------------------------
Paso 4: Plantilla de Mensaje
----------------------------

Configurar en pestaña **Message**:

.. code-block:: text

    Subject: [Zabbix Alert] {TRIGGER.STATUS}: {TRIGGER.NAME}

    Body:
    **Host**: {HOST.NAME}
    **Severity**: {TRIGGER.SEVERITY}
    **Timestamp**: {EVENT.DATE} {EVENT.TIME}
    
    **Trigger Details**:
    {TRIGGER.DESCRIPTION}
    
    **Deepseek Analysis**:
    {ALERT.MESSAGE}

--------------------------------
Configuración Adicional Recomendada
--------------------------------

1. **Control de Frecuencia**:
   - Añadir condición: ``Trigger value = PROBLEM``
   - Setear ``Operation duration`` para evitar spam

2. **Manejo de Errores**:
   - Crear Trigger separado para monitorear fallos en el script

3. **Seguridad**:
   - Restringir permisos del script: ``chmod 750 zabbix_deepseek.py``
   - Usar vault para almacenar API Key

--------------------------------
Solución de Problemas Comunes
--------------------------------

+--------------------------------+-----------------------------------------------+
| Error                          | Solución                                      |
+================================+===============================================+
| 403 Forbidden                  | Verificar API Key y permisos de cuenta       |
+--------------------------------+-----------------------------------------------+
| Timeout en consulta            | Ajustar timeout en script (ej: timeout=10)   |
+--------------------------------+-----------------------------------------------+
| Formato incorrecto en respuesta| Validar JSON response con ``json.loads()``   |
+--------------------------------+-----------------------------------------------+

Notas Finales
------------
- Testear con alarmas no críticas primero
- Monitorear uso de la API para evitar límites
- Considerar caché para respuestas recurrentes
