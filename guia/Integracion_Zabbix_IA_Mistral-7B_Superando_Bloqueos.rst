=====================================================
Integración Zabbix + Mistral-7B Superando Bloqueos
=====================================================

.. contents:: Tabla de Contenidos
   :depth: 3
   :local:

Integración de Zabbix con IA en Venezuela (Usando LLMs permitidos)
==================================================================

Aquí tienes un paso a paso detallado para integrar Zabbix con modelos de IA accesibles en Venezuela, usando scripts bash para GNU/Linux.

Opciones de IA disponibles en Venezuela
----------------------------------------
OpenRouter.ai (accesible y con modelos gratuitos)

Hugging Face (algunos modelos son accesibles)

LocalAI (si decides instalar modelos locales)

Solución recomendada: Usar OpenRouter.ai

Paso 1: Configurar API Key en OpenRouter
========================================
Regístrate en https://openrouter.ai/

Ve a "API Keys" y crea una nueva clave

Anota tu API Key

Paso 2: Crear script bash para consultar la IA
===============================================
Crea el archivo /usr/lib/zabbix/alertscripts/ai_advisor.sh:

.. code-block:: bash

   #!/bin/bash
   
   # Configuración
   HUGGINGFACE_API_KEY="TU_API_KEY"
   MODEL="mistralai/Mistral-7B-Instruct-v0.2"
   ZABBIX_TRIGGER_NAME="$1"
   ZABBIX_HOSTNAME="$2"
   ZABBIX_SEVERITY="$3"
   ZABBIX_DESCRIPTION="$4"
   
   # Preparar el prompt (formato Mistral-7B compatible con JSON)
   read -r -d '' PROMPT << EOM
   [INST] Eres un experto en sistemas Linux y monitorización con Zabbix. Analiza este problema y provee una solución concisa paso a paso en español:
   
   Trigger: ${ZABBIX_TRIGGER_NAME}
   Host: ${ZABBIX_HOSTNAME}
   Severidad: ${ZABBIX_SEVERITY}
   Descripción: ${ZABBIX_DESCRIPTION}
   
   Proporciona:
   1. Posible causa raíz
   2. Pasos para diagnosticar
   3. Solución recomendada
   4. Comandos Linux específicos [/INST]
   EOM
   
   # Limpiar caracteres especiales y formatear para JSON
   CLEAN_PROMPT=$(echo "$PROMPT" | tr -d '\000-\031' | jq -Rs . | sed 's/\\n/ /g')
   
   # Consultar la API de Hugging Face
   RESPONSE=$(curl -s -X POST \
     "https://api-inference.huggingface.co/models/${MODEL}" \
     -H "Authorization: Bearer ${HUGGINGFACE_API_KEY}" \
     -H "Content-Type: application/json" \
     -d '{"inputs": '"${CLEAN_PROMPT}"'}')
   
   # Extraer y formatear la respuesta
   SOLUTION=$(echo "$RESPONSE" | jq -r '.[0].generated_text' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
   
   # Opcional: Eliminar el prompt duplicado en la respuesta (común en Hugging Face)
   SOLUTION=${SOLUTION#"$PROMPT"}
   
   # Enviar a Zabbix y registrar en log
   echo "$SOLUTION"
   mkdir -p /var/log/zabbix
   echo "$(date) - ${ZABBIX_HOSTNAME} - ${ZABBIX_TRIGGER_NAME}: ${SOLUTION}" >> /var/log/zabbix/ai_advisor.log
   #echo "$SOLUTION" | mailx -s "Solución para ${ZABBIX_TRIGGER_NAME}" cgomeznt@gmail.com
   exit 0


Paso 3: Dar permisos al script
bash
Copy
chmod +x /usr/lib/zabbix/alertscripts/ai_advisor.sh
chown zabbix:zabbix /usr/lib/zabbix/alertscripts/ai_advisor.sh
mkdir -p /var/log/zabbix
touch /var/log/zabbix/ai_advisor.log
chown zabbix:zabbix /var/log/zabbix/ai_advisor.log
Paso 4: Instalar dependencias
bash
Copy
apt-get install jq curl  # Para Debian/Ubuntu
# o
yum install jq curl      # Para RHEL/CentOS
Paso 5: Configurar acción en Zabbix
Ve a "Administration" → "Media Types"

Crea un nuevo tipo de medio:

Name: "AI Advisor"

Type: "Script"

Script name: ai_advisor.sh

Ve a "Configuration" → "Actions"

Crea una nueva acción:

Name: "Consultar IA para solución"

Conditions: Selecciona los triggers relevantes

Operations:

Add: "Send message"

To: "AI Advisor"

Message: Usa estos parámetros:

Copy
{TRIGGER.NAME}
{HOST.NAME}
{TRIGGER.SEVERITY}
{TRIGGER.DESCRIPTION}
Paso 6: Configurar notificaciones (Opcional)
Para recibir las soluciones por email o Telegram:

Crea un nuevo script /usr/lib/zabbix/alertscripts/send_solution.sh:

bash
Copy
#!/bin/bash

EMAIL="$1"
SUBJECT="Solución para problema en Zabbix: $2"
MESSAGE="$3"

# Para email (requiere mailx configurado)
echo "$MESSAGE" | mailx -s "$SUBJECT" "$EMAIL"

# O para Telegram (opcional)
# TELEGRAM_TOKEN="tu_token"
# TELEGRAM_CHAT_ID="tu_chat_id"
# curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
#   -d chat_id="${TELEGRAM_CHAT_ID}" \
#   -d text="${SUBJECT}%0A%0A${MESSAGE}"
Modifica el script ai_advisor.sh para llamar a este script al final:

bash
Copy
# Añade esto al final del script ai_advisor.sh
/usr/lib/zabbix/alertscripts/send_solution.sh "tu_email@dominio.com" "${ZABBIX_TRIGGER_NAME}" "${SOLUTION}"
Alternativa: Usar modelos locales con LocalAI
Si prefieres no depender de APIs externas:

Instala LocalAI en un servidor local:

bash
Copy
git clone https://github.com/go-skynet/LocalAI
cd LocalAI
docker compose up -d
Descarga un modelo compatible (ej. GPT4All):

bash
Copy
wget https://gpt4all.io/models/gguf/gpt4all-falcon-q4_0.gguf -O models/gpt4all-falcon.gguf
Modifica el script ai_advisor.sh para apuntar a tu LocalAI:

bash
Copy
# Cambia la línea de curl por:
RESPONSE=$(curl -s -X POST "http://localhost:8080/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt4all-falcon",
    "messages": [
      {"role": "user", "content": "'"${PROMPT}"'"}
    ]
  }')
Consideraciones importantes
Privacidad: No envíes datos sensibles a APIs externas

Costos: OpenRouter tiene límites gratuitos, monitorea su uso

Validación: Siempre verifica las soluciones sugeridas antes de aplicarlas

Logging: Mantén logs de todas las interacciones para auditoría

Este setup te permitirá recibir soluciones automatizadas para los problemas detectados por Zabbix, usando IA accesible desde Venezuela.

