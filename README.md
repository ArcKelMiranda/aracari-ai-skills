# aracari-ai-skills

 roadmap de Skills de IA del equipo de Aracari Studios

## 🦞 Step 01: OpenClaw — Personal AI Assistant

[📋 Ir al README de Step 01](./step-01-openclaw/README.md)

Instalación, configuración y entendimiento de OpenClaw como asistente AI personal en VPS Ubuntu con Docker. Conexión de canales Telegram y WhatsApp.

### Temas cubiertos:
- [x] [¿Qué es OpenClaw?](./step-01-openclaw/docs/que-es-openclaw.md)
- [x] [API directa vs Plan existente](./step-01-openclaw/docs/api-vs-suscripcion.md)
- [x] [Setup Telegram](./step-01-openclaw/docs/telegram-setup.md)
- [x] [Setup WhatsApp](./step-01-openclaw/docs/whatsapp-setup.md)

### Archivos clave:
- [docker-compose.yml](./step-01-openclaw/docker/docker-compose.yml) — Configuración Docker
- [openclaw.env.example](./step-01-openclaw/config/openclaw.env.example) — Template de variables
- [setup-vps.sh](./step-01-openclaw/scripts/setup-vps.sh) — Script de instalación

---

## 📚 Roadmap completo

1. ✅ **Fundamentos y herramientas base** — OpenClaw, VPS, Telegram, WhatsApp *(activo)*
2. 🔲 **Bases vectoriales y RAG** — Embeddings, similitud coseno, chunking, indexación, retrieval
3. 🔲 **MCP & Skills** — Crear servidor MCP propio, herramientas, skills
4. 🔲 **OpenAI SDK + Tools + MCP con frontend** — Chat con tools y MCP
5. 🔲 **Seguridad en aplicaciones con IA** — Prompt injection, PII handling, guardrails
6. 🔲 **Selección y comparación de modelos** — Opus vs Sonnet vs Haiku, fine-tuning vs RAG
7. 🔲 **Calculadora de costo de tokens** — Estimar costos de API
8. 🔲 **Asistente de voz** — Botón micrófono, realtime voice

---

## 🔒 Seguridad

### Pre-commit Hook

Tenemos un hook que valida datos sensibles **antes** de cada commit:

```bash
# Instalar (ya hecho)
./.githooks/install-hook.sh

# Verificar manualmente
.githooks/pre-commit
```

El hook busca:
- API keys, tokens, contraseñas hardcodeadas
- Archivos `.env` con valores reales
- Directorio `data/`
- AWS keys, GitHub tokens, JWTs

Ver: [.githooks/README.md](./.githooks/README.md)

---

## Recursos

- 🌐 [OpenClaw Website](https://openclaw.ai)
- 📚 [OpenClaw Docs](https://docs.openclaw.ai)
- 🐙 [GitHub](https://github.com/openclaw/openclaw)
- 🦞 [ClawHub (Skills)](https://clawhub.ai)
- 💬 [Discord](https://discord.gg/clawd)
