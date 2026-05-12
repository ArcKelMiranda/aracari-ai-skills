# Configuración de Telegram Bot

## Prerrequisitos

- Tener Telegram instalado en tu teléfono o escritorio
- Acceso al bot de [@BotFather](https://t.me/BotFather)

## Paso 1: Crear el bot en Telegram

1. Abre Telegram y busca **@BotFather**
2. Envía el comando: `/newbot`
3. Sigue las instrucciones:
   - **Nombre del bot**: Ej `AracariAI Bot`
   - **Username del bot**: Ej `aracariai_bot` (debe terminar en `bot`)
4. BotFather te dará un **token** como este:
   ```
   1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
   ```
5. **Copia este token** — lo usaremos después

## Paso 2: Configurar el token en OpenClaw

### Opción A: Archivo .env

```bash
# En step-01-openclaw/config/.env
OPENCLAW_TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
```

### Opción B: Docker Compose con variable

```bash
# Ejecutar en la carpeta del proyecto
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  channels add --channel telegram --token "1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"
```

### Opción C: Configuración manual

```bash
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set channels.telegram.botToken "1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"
```

## Paso 3: Agregar el bot a Telegram

1. Abre Telegram y busca tu bot por el username que le diste
2. Envía `/start` al bot
3. Deberías ver un mensaje de bienvenida (si lo configuraste)

## Paso 4: Verificar conexión

```bash
# Ver canales activos
docker compose -f docker/docker-compose.yml run --rm openclaw-cli channels list

# Enviar un mensaje de prueba
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  message send --target @tu_username --message "Hola desde OpenClaw!"
```

## Configuración de seguridad (importante!)

Por defecto, OpenClaw tiene **DM pairing** activado — esto significa que el bot solo responde a usuarios conocidos.

### Modo pairing (recomendado para producción)

1. Un usuario envía un mensaje al bot
2. El bot responde con un **código de pairing**
3. El admin aprueba con:
   ```bash
   openclaw pairing approve telegram <codigo>
   ```

### Modo open (para testing)

⚠️ **No recomendado para producción**

```bash
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set channels.telegram.dmPolicy "open"
```

## Comandos útiles de Telegram

| Comando | Descripción |
|---------|-------------|
| `/start` | Iniciar conversación |
| `/new` | Crear nueva sesión |
| `/reset` | Reiniciar conversación |
| `/status` | Ver estado actual |
| `/help` | Ver ayuda |

## Troubleshooting

### El bot no responde

1. Verifica que el token sea correcto
2. Revisa los logs:
   ```bash
   docker compose logs openclaw-gateway | grep -i telegram
   ```
3. Verifica que el bot esté activo:
   ```bash
   docker compose -f docker/docker-compose.yml run --rm openclaw-cli channels list
   ```

### Error de autenticación

```bash
# Regenerar token desde BotFather
# Luego actualizar en OpenClaw
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  channels update --channel telegram --token "nuevo-token"
```

## Configuraciones avanzadas

### Cambiar política de DMs

```bash
# Solo usuarios en allowlist
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set channels.telegram.dmPolicy "pairing"

# Permitir任何人 (cuidado!)
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set channels.telegram.dmPolicy "open"
```

### Agregar a grupos

1. Habla con @BotFather → `/setjoinrequirements` → disable
2. Agrega el bot al grupo
3. Usa `/start` en el grupo
4. Configura el bot como admin o permite mensajes privado

## Siguiente paso

→ [WhatsApp Setup](./whatsapp-setup.md)
