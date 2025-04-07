==================================================
Integración de Zabbix 7.2 con OpenAI para Alarmas
==================================================

El prompt de la IA
-------------------
hola deepseek, por favor ayudame, trabajo en tecnologia y tengo la administración de la herramienta de monitoreo Zabbix.
necesito tu ayuda para tener un paso a paso detallado que explique como integrar zabbix 7.2 con OpenAI, que me indique las posibles soluciones cuando aparezca una alarma en Zabbix y me explique como con un "action de Zabbix" puedo enviarlo por correo a los buzones que ya estan asociado a los usuarios, el SMTP es local y ya esta configurado y funcionando.
Por favor enviar en formato "rst"


Objetivo
--------
1. Consultar a OpenAI cuando ocurra una alarma en Zabbix para obtener soluciones automatizadas.
2. Enviar un correo electrónico (vía SMTP local ya configurado) con la alarma y la respuesta generada por OpenAI.
3. Utilizar "Actions" de Zabbix para gestionar el flujo completo.

Prerrequisitos
--------------
- **Zabbix 7.2** instalado y funcionando.
- **SMTP local** configurado y operativo en Zabbix.
- **API Key de OpenAI** (obtenida desde https://platform.openai.com/).
- Acceso de administrador en el servidor Zabbix.

------------------------
Paso 1: Script de OpenAI
------------------------

Crear un script en Python para consultar la API de OpenAI:

.. code-block:: python

    #!/usr/bin/env python3
    import requests
    import sys

    OPENAI_API_KEY = "tu-api-key-aqui"
    OPENAI_MODEL = "gpt-3.5-turbo"  # o "gpt-4"

    def get_openai_solution(problem):
        headers = {
            "Authorization": f"Bearer {OPENAI_API_KEY}",
            "Content-Type": "application/json"
        }
        data = {
            "model": OPENAI_MODEL,
            "messages": [
                {"role": "system", "content": "Eres un experto en Zabbix. Proporciona soluciones concisas (máx. 100 palabras)."},
                {"role": "user", "content": f"Alarma en Zabbix: {problem}. Causas y soluciones:"}
            ]
        }
        response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=data)
        return response.json()["choices"][0]["message"]["content"]

    if __name__ == "__main__":
        print(get_openai_solution(sys.argv[1]))

Instalación del script:
^^^^^^^^^^^^^^^^^^^^^^^

1. Guardar en ``/usr/lib/zabbix/alertscripts/zabbix_openai.py``.
2. Dar permisos de ejecución:

   .. code-block:: bash

      chmod +x /usr/lib/zabbix/alertscripts/zabbix_openai.py
      pip3 install requests

----------------------------
Paso 2: Configurar Media Type
----------------------------

1. Ir a **Administration → Media Types → Create Media Type**.
2. Configurar:

   - *Name*: ``OpenAI Integration``
   - *Type*: ``Script``
   - *Script name*: ``zabbix_openai.py``
   - *Script parameters*: ``{ALERT.MESSAGE}``

------------------------
Paso 3: Crear la Action
------------------------

1. Ir a **Configuration → Actions → Create Action**.
2. Configurar:

   - *Name*: ``OpenAI Auto-Resolution``
   - *Conditions*: 
     - ``Trigger severity = High`` (o las deseadas)

3. **Operations**:

   +---------------------+-----------------------------------------+
   | Campo               | Valor                                   |
   +=====================+=========================================+
   | Operation type      | Send message                            |
   +---------------------+-----------------------------------------+
   | Send to Users       | Seleccionar grupos relevantes           |
   +---------------------+-----------------------------------------+
   | Send only to        | ``OpenAI Integration`` (Media Type)     |
   +---------------------+-----------------------------------------+

4. **Añadir segunda operación**:

   +---------------------+-----------------------------------------+
   | Operation type      | Send message                            |
   +---------------------+-----------------------------------------+
   | Send only to        | ``Email`` (para SMTP local)             |
   +---------------------+-----------------------------------------+

----------------------------
Paso 4: Plantilla del Mensaje
----------------------------

En la pestaña **Message** de la Action:

.. code-block:: text

    Subject: Alarma: {TRIGGER.NAME}

    Mensaje:
    **Host**: {HOST.NAME}
    **Severidad**: {TRIGGER.SEVERITY}
    **Descripción**: {TRIGGER.DESCRIPTION}

    **Solución OpenAI**:
    {ALERT.MESSAGE}

--------------------------------
Solución de Problemas Comunes
--------------------------------

+--------------------------------+-----------------------------------------------+
| Error                          | Solución                                      |
+================================+===============================================+
| Script no ejecutable           | Verificar permisos (``chmod +x``)            |
+--------------------------------+-----------------------------------------------+
| API Key inválida               | Revisar clave en OpenAI y en el script       |
+--------------------------------+-----------------------------------------------+
| SMTP no envía correos          | Probar configuración SMTP en Zabbix          |
+--------------------------------+-----------------------------------------------+

Notas Adicionales
----------------
- **Costos**: Monitorear el uso de la API de OpenAI para evitar gastos inesperados.
- **Seguridad**: Almacenar la API Key en un archivo con permisos restringidos.
- **Testing**: Simular alarmas para verificar el flujo completo.
Cómo usar este documento:

Copia el contenido en un archivo con extensión .rst (ej: zabbix_openai.rst).

Puedes convertirlo a PDF/HTML usando herramientas como Sphinx o Pandoc.

¡Personaliza los valores marcados entre llaves (ej: {ALERT.MESSAGE}) según tu entorno!
