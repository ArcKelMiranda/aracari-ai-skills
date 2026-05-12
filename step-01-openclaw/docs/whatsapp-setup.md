# Configuración de WhatsApp

## ⚠️ Importante: Número dedicado

Para WhatsApp necesitas un **número de teléfono dedicado** que noUse para otros fines. Opciones:

1. **SIM secundaria** en tu teléfono
2. **eSIM** dedicada (más fácil)
3. **Número virtual** (servicios como Twilio, voir.com)
4. **WhatsApp Business API** (para uso más avanzado)

## Método: Vinculación por QR (recomendado)

### Paso 1: Asegúrate que Docker esté corriendo

```bash
docker compose -f docker/docker-compose.yml ps
```

### Paso 2: Iniciar login de WhatsApp

```bash
docker compose -f docker/docker-compose.yml run --rm openclaw-cli channels login
```

Verás algo como:

```
📱 OpenClaw Channel Login
Select channel: whatsapp

▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓
▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓
▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓
▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

### Paso 3: Escanear QR con WhatsApp

1. Abre **WhatsApp** en tu teléfono
2. Ve a **Ajustes** → **Dispositivos vinculados** → **Vincular dispositivo**
3. Escanea el código QR que aparece en la terminal

### Paso 4: Verificar conexión

```bash
# Ver estado de canales
docker compose -f docker/docker-compose.yml run --rm openclaw-cli channels list

# Deberías ver whatsapp como "connected"
```

## Método: WhatsApp Business API (avanzado)

Si prefieres usar la API de WhatsApp Business en lugar de vincular un teléfono:

### Prerrequisitos

- Cuenta de WhatsApp Business API (via Meta for Developers)
- Número verificado
- Token de acceso a la API

### Configuración

```bash
# Configurar con WhatsApp Business API
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set channels.whatsapp.business.apiKey "tu-api-key"

docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set channels.whatsapp.business.phoneNumber "1234567890"
```

## Sesiones y persistencia

### Guardar sesión de WhatsApp

Las sesiones de WhatsApp se guardan en:

```
~/.openclaw/workspace/
└── channels/
    └── whatsapp/
        └── sessions/
            └── default/
                └── ... (archivos de sesión)
```

### Backup de sesión

⚠️ **Importante**: Haz backup de estos archivos. Si pierdes la sesión:

1. Borra la sesión antigua:
   ```bash
   rm -rf ~/.openclaw/workspace/channels/whatsapp/sessions/*
   ```
2. Vuelve a vincular:
   ```bash
   docker compose -f docker/docker-compose.yml run --rm openclaw-cli channels login
   ```

## Limitaciones conocidas

| Aspecto | Limitación |
|---------|------------|
| **Grupos** | Puede haber limitaciones |
| **Estados** | No soporta WhatsApp Status |
| **Llamadas** | No soporta llamadas de voz |
| **Múltiples dispositivos** | Solo un dispositivo vinculado a la vez |
| **QR timeout** | El QR expira en ~60 segundos |

## Troubleshooting

### QR no aparece o expira

```bash
# Reiniciar el login
docker compose -f docker/docker-compose.yml run --rm openclaw-cli channels logout --channel whatsapp
docker compose -f docker/docker-compose.yml run --rm openclaw-cli channels login
```

### Sesión inválida o desconectada

```bash
# Ver logs
docker compose -f docker/docker-compose.yml logs openclaw-gateway | grep -i whatsapp

# Resetear sesión
docker compose -f docker/docker-compose.yml run --rm openclaw-cli channels logout --channel whatsapp
docker compose -f docker/docker-compose.yml run --rm openclaw-cli channels login
```

### Error de phone number

```bash
# Verificar sesión
docker compose -f docker/docker-compose.yml run --rm openclaw-cli channels list

# Si dice "disconnected", volver a vincular
docker compose -f docker/docker-compose.yml run --rm openclaw-cli channels login
```

## Seguridad

### Permitir solo ciertos números

```bash
# Configurar allowlist
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set channels.whatsapp.allowFrom '["+1234567890", "+0987654321"]'
```

### Denegar números específicos

```bash
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set channels.whatsapp.denyFrom '["+1111111111"]'
```

## Próximos pasos

Una vez configurado:
1. ✅ Telegram bot
2. ✅ WhatsApp
3. → [Volver al README principal](../README.md)
