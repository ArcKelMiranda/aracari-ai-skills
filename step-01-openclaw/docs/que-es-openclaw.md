# ¿Qué es OpenClaw?

## Definición

**OpenClaw** es un asistente de IA personal, de código abierto, que corre en tus propios dispositivos o servidores. A diferencia de otros asistentes que viven en la nube, OpenClaw te da control total sobre tu datos y configuración.

## Características principales

### 🤖 Asistente AI Personal
- Funciona 24/7 en tu servidor o máquina
- Conecta con los canales de mensajería que ya usas
- Tiene memoria persistente y contexto continuo
- Puede ejecutar tareas automatizadas

### 📱 Canales soportados
- **Telegram** ✅ (configurado)
- **WhatsApp** ✅ (configurado)
- Discord, Slack, Signal, iMessage
- Microsoft Teams, Matrix, LINE, WeChat, y más

### 🔧 Herramientas y habilidades
- **Skills**: flujos de trabajo reutilizables definidos en archivos `SKILL.md`
- **Tools**: browser, canvas, cron, sessions, y más
- **MCP servers**: puedes conectar Model Context Protocol servers
- **Cron jobs**: tareas programadas automáticas

### 🔒 Seguridad
- Running local-first: tus datos no salen de tu infraestructura
- DM pairing: los mensajes directos requieren aprobación
- Sandbox mode: aisla sesiones no-confiables en contenedores Docker
- Auth con tokens para el gateway

## Modelo de datos y arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                      Gateway (Puerto 18789)              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │
│  │   Channels  │  │   Sessions  │  │   Tools/ Skills │ │
│  │  Telegram   │  │    Main     │  │   Browser       │ │
│  │  WhatsApp   │  │   Agent     │  │   Cron          │ │
│  │  Discord    │  │   ...       │  │   MCP           │ │
│  └─────────────┘  └─────────────┘  └─────────────────┘ │
│                          │                               │
│                    ┌─────┴─────┐                        │
│                    │   Model   │                        │
│                    │  (Claude, │                        │
│                    │  GPT, etc)│                        │
│                    └───────────┘                        │
└─────────────────────────────────────────────────────────┘
```

## Comandos básicos

```bash
# Iniciar el gateway
openclaw gateway --port 18789 --verbose

# Enviar un mensaje
openclaw message send --target +1234567890 --message "Hola"

# Chatear con el asistente
openclaw agent --message "Qué puedes hacer?" --thinking high

# Ver canales conectados
openclaw channels list

# Diagnósticos
openclaw doctor
```

## Workspace y archivos

- **Workspace root**: `~/.openclaw/workspace`
- **Config**: `~/.openclaw/openclaw.json`
- **Skills**: `~/.openclaw/workspace/skills/<skill>/SKILL.md`
- **Prompts especiales**: `AGENTS.md`, `SOUL.md`, `TOOLS.md`

## API vs Plan de suscripción

OpenClaw soporta múltiples proveedores de modelos:
- **OpenAI** (GPT-4, Codex)
- **Anthropic** (Claude)
- **Google** (Gemini)
- **Ollama** (local)
- **LM Studio** (local)
- Y muchos más...

La diferencia clave:
- **API directa**: Pagas por uso vía tu propia API key del proveedor
- **Plan existente**: Si ya tienes Claude Max, ChatGPT Plus, etc, puedes usarlo

## Recursos

- 🌐 [Website](https://openclaw.ai)
- 📚 [Docs](https://docs.openclaw.ai)
- 🐙 [GitHub](https://github.com/openclaw/openclaw)
- 🦞 [ClawHub (skills)](https://clawhub.ai)
- 💬 [Discord](https://discord.gg/clawd)
