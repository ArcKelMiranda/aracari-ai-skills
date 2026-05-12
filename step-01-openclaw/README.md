# Step 01: OpenClaw — Personal AI Assistant

## Objetivo

Instalar, configurar y entender **OpenClaw** como asistente AI personal en nuestra VPS Ubuntu con Docker. Conectar los canales de **Telegram** y **WhatsApp**.

## Estructura del paso

```
step-01-openclaw/
├── README.md              # Este archivo
├── docs/
│   ├── que-es-openclaw.md
│   ├── api-vs-suscripcion.md
│   ├── telegram-setup.md
│   ├── whatsapp-setup.md
│   ├── security-audit.md          # Auditoría de seguridad
│   └── ask-before-everything.md  # Config "ask before action"
├── config/
│   ├── openclaw.env.example           # Template de variables de entorno
│   └── secure-ask-everything.json    # Configuración ultra-segura
├── docker/
│   └── docker-compose.yml     # Configuración Docker (bind loopback)
└── scripts/
    ├── setup-vps.sh          # Script de instalación en VPS
    └── setup-channels.sh     # Script de configuración de canales
```

## ⚠️ Seguridad — "Ask Before Everything"

Por defecto, OpenClaw puede ejecutar acciones automáticamente. Para máxima seguridad,
queremos que **SIEMPRE pregunte antes de hacer algo**.

### Configuración clave:

```json
{
  tools: {
    exec: {
      ask: "always",      // SIEMPRE pregunta antes de ejecutar
      security: "deny"    // Deniega por defecto
    }
  },
  channels: {
    telegram: { dmPolicy: "pairing" },   // Nadie escribe sin aprobación
    whatsapp: { dmPolicy: "pairing" }
  },
  agents: {
    defaults: {
      sandbox: { mode: "all" }  // Aislamiento total
    }
  }
}
```

### Cómo aplicar:

```bash
# Copiar la config segura
cp config/secure-ask-everything.json ~/.openclaw/openclaw.json

# Reiniciar
docker compose -f docker/docker-compose.yml restart
```

Ver: [docs/ask-before-everything.md](./docs/ask-before-everything.md)

## Prerrequisitos

- [ ] VPS con Ubuntu (Hostinger KM8)
- [ ] Docker + Docker Compose instalados
- [ ] Node 24 (para desarrollo local) — opcional
- [ ] Token de Telegram Bot — obtener via [@BotFather](https://t.me/BotFather)
- [ ] Número de WhatsApp dedicado para el bot

## Roadmap de este paso

- [ ] 1. Instalar OpenClaw en la VPS (via Docker)
- [ ] 2. Configurar variables de entorno y archivo `.env`
- [ ] 3. Configurar canal Telegram
- [ ] 4. Configurar canal WhatsApp
- [ ] 5. Verificar conexión y enviar primer mensaje
- [ ] 6. Entender diferencias: API directa vs plan existente
- [ ] 7. Documentar hallazgos en el repo

## Comandos básicos de OpenClaw

```bash
# Ver estado del gateway
openclaw gateway --port 18789 --verbose

# Enviar mensaje directo
openclaw message send --target +1234567890 --message "Hola desde OpenClaw"

# Hablar con el asistente
openclaw agent --message "Ship checklist" --thinking high

# Agregar canal Telegram
openclaw channels add --channel telegram --token "<token>"

# Login WhatsApp (QR code)
openclaw channels login

# Ver estado de canales
openclaw channels list

# Diagnosticar problemas
openclaw doctor
```

## Recursos

- [Docs oficiales](https://docs.openclaw.ai)
- [GitHub repo](https://github.com/openclaw/openclaw)
- [ClawHub (skills)](https://clawhub.ai)
- [Discord community](https://discord.gg/clawd)

## Siguiente paso

→ [Step 02: Bases vectoriales y RAG](../step-02-rag/README.md)
