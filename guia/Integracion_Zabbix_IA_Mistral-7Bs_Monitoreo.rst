Monitoreo del Uso de Hugging Face en la Integración con Zabbix
=============================================================

Hugging Face ofrece acceso gratuito a sus modelos de IA, pero con ciertas limitaciones que es importante monitorear.

Límites de la API de Hugging Face
---------------------------------

1. **Límites por token**:
   - Free tier: ~10,000-30,000 tokens/hora (varía por modelo)
   - Límites diarios/mensuales adicionales

2. **Restricciones por modelo**:
   - Modelos pequeños: mayores límites
   - Modelos grandes: límites más estrictos

3. **Tipos de límite**:
   - Límites de solicitudes (requests)
   - Límites de cómputo (compute)
   - Límites de tiempo (temporal)

Configuración del Monitoreo
---------------------------

### Método 1: Usar los headers de respuesta HTTP

Cree un script ``/usr/lib/zabbix/alertscripts/huggingface_monitor.sh``:

.. code-block:: bash

   #!/bin/bash
   API_KEY="tu_api_key_de_huggingface"
   RESPONSE=$(curl -s -I -X GET "https://api-inference.huggingface.co/models" \
     -H "Authorization: Bearer ${API_KEY}")

   # Extraer límites de los headers
   RATELIMIT_LIMIT=$(echo "$RESPONSE" | grep -i "x-ratelimit-limit" | awk '{print $2}' | tr -d '\r')
   RATELIMIT_REMAINING=$(echo "$RESPONSE" | grep -i "x-ratelimit-remaining" | awk '{print $2}' | tr -d '\r')
   RATELIMIT_RESET=$(echo "$RESPONSE" | grep -i "x-ratelimit-reset" | awk '{print $2}' | tr -d '\r')

   echo "Límite: ${RATELIMIT_LIMIT}"
   echo "Restantes: ${RATELIMIT_REMAINING}"
   echo "Reset en: ${RATELIMIT_RESET} segundos"

### Método 2: Monitoreo mediante la API de uso

.. code-block:: bash

   #!/bin/bash
   API_KEY="tu_api_key_de_huggingface"
   USAGE_DATA=$(curl -s -X GET "https://api-inference.huggingface.co/dashboard/usage" \
     -H "Authorization: Bearer ${API_KEY}")

   echo "$USAGE_DATA" | jq .

Configuración en Zabbix
-----------------------

1. **Crear items** para monitoreo:

   +-------------------+----------------------------------------+----------------+
   | Nombre            | Key                                   | Tipo de dato   |
   +===================+========================================+================+
   | HF Rate Limit     | huggingface_monitor.sh[limit]         | Numeric (float)|
   +-------------------+----------------------------------------+----------------+
   | HF Remaining      | huggingface_monitor.sh[remaining]     | Numeric (float)|
   +-------------------+----------------------------------------+----------------+
   | HF Reset Time     | huggingface_monitor.sh[reset]         | Numeric (uint) |
   +-------------------+----------------------------------------+----------------+

2. **Configurar triggers**:

   .. code-block:: none

      {huggingface_monitor.sh:remaining.last()} < 100
      {huggingface_monitor.sh:remaining.last()} < 10

3. **Dashboard** recomendado:

   - Gráfico de límite vs. uso
   - Indicador de solicitudes restantes
   - Tiempo hasta el próximo reset

Estrategias para Gestionar Límites
----------------------------------

1. **Cache de respuestas**:

   .. code-block:: bash

      CACHE_DIR="/var/cache/zabbix/hf_responses"
      mkdir -p "$CACHE_DIR"
      CACHE_KEY=$(echo "${ZABBIX_DESCRIPTION}" | md5sum | cut -d' ' -f1)

      if [ -f "${CACHE_DIR}/${CACHE_KEY}" ]; then
          cat "${CACHE_DIR}/${CACHE_KEY}"
          exit 0
      fi

2. **Modelos alternativos**:

   .. code-block:: bash

      # Lista de modelos alternativos
      MODELS=("distilbert-base-uncased" "bert-base-uncased" "roberta-base")

3. **Plan de contingencia**:

   - Cambiar a modelo local si se excede el límite
   - Enviar alerta al equipo de soporte
   - Reducir frecuencia de consultas

Señales de Alerta
-----------------

1. **Headers importantes**:
   - ``x-ratelimit-remaining``: Solicitudes restantes
   - ``x-ratelimit-reset``: Tiempo hasta el reset (segundos)
   - ``x-ratelimit-limit``: Límite total

2. **Códigos de error**:
   - 429: Too Many Requests
   - 503: Service Unavailable (overloaded)

Ejemplo de Respuesta con Límite Alcanzado
----------------------------------------

.. code-block:: json

   {
     "error": "Model is currently loading",
     "estimated_time": 30
   }

Recomendaciones Finales
-----------------------

1. Implemente monitoreo continuo del uso
2. Configure alertas tempranas (80% de uso)
3. Mantenga alternativas locales disponibles
4. Revise regularmente los límites en la documentación oficial
