# 🔒 Configuración "Ask Before Everything"

## Concepto

Esta configuración hace que **OpenClaw siempre pida confirmación** antes de ejecutar cualquier acción. Es el modo más seguro.

## Configuración clave

### 1. `tools.exec.ask: "always"` — LA MÁS IMPORTANTE

```json
tools: {
  exec: {
    ask: "always"  // SIEMPRE pregunta antes de ejecutar
  }
}
```

Con esto activado, cuando OpenClaw quiera:
- 🔧 Ejecutar un comando en la terminal → **Pregunta**
- 📁 Leer un archivo → **Pregunta**
- 📝 Escribir/modificar un archivo → **Pregunta**
- 🌐 Hacer una búsqueda web → **Pregunta**
- 📧 Enviar un email → **Pregunta**

### 2. `tools.exec.security: "deny"` — Denegar por defecto

```json
tools: {
  exec: {
    security: "deny"  // Deniega ejecución hasta aprobación
  }
}
```

### 3. Sandbox para aislamiento

```json
agents: {
  defaults: {
    sandbox: {
      mode: "all",           // Todo en sandbox
      scope: "session"      // Un sandbox por sesión
    }
  }
}
```

## Cómo aplicar esta configuración

### Opción 1: Copiar el archivo (manual)

```bash
# En la VPS, después de que OpenClaw esté corriendo:
cp step-01-openclaw/config/secure-ask-everything.json ~/.openclaw/openclaw.json

# Reiniciar el gateway
docker compose -f docker/docker-compose.yml restart
```

### Opción 2: Usar el CLI

```bash
# Aplicar cada setting individualmente
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set tools.exec.ask "always"

docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set tools.exec.security "deny"

docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set agents.defaults.sandbox.mode "all"
```

## Qué hace cada setting

| Setting | Valor | Qué hace |
|---------|-------|----------|
| `tools.exec.ask` | `"always"` | Pregunta ANTES de cada ejecución |
| `tools.exec.security` | `"deny"` | Deniega exec por defecto |
| `tools.profile` | `"messaging"` | Perfil restrictivo de herramientas |
| `tools.deny` | `["gateway", "cron", ...]` | Lista de herramientas bloqueadas |
| `tools.exec.fs.workspaceOnly` | `true` | Solo puede tocar workspace |
| `channels.*.dmPolicy` | `"pairing"` | Nadie escribe sin aprobación |
| `session.dmScope` | `"per-channel-peer"` | Sesiones aisladas por persona |
| `sandbox.mode` | `"all"` | Todo corre en sandbox |

## Cómo funciona en la práctica

### Ejemplo 1: Usuario pide "busca en Google"

```
👤 Usuario: "Busca las noticias de hoy"
🤖 OpenClaw: "¿Puedo usar la herramienta de búsqueda web?"
   [✅ Aprobar] [❌ Denegar]
```

### Ejemplo 2: Usuario pide "escribe un archivo"

```
👤 Usuario: "Crea un archivo notes.txt con lo que hablamos"
🤖 OpenClaw: "¿Puedo escribir en ~/.openclaw/workspace/notes.txt?"
   [✅ Aprobar] [❌ Denegar]
```

### Ejemplo 3: Usuario pide "ejecuta un comando"

```
👤 Usuario: "Instala npm"
🤖 OpenClaw: "¿Puedo ejecutar 'npm install' en la terminal?"
   [✅ Aprobar] [❌ Denegar]
```

## Settings menos restrictivos (si "always" es muy lento)

### Opción: "first" (pregunta solo la primera vez)

```json
tools: {
  exec: {
    ask: "first"  // Solo pregunta la primera vez por tipo de comando
  }
}
```

### Opción: "tool" (pregunta solo para herramientas peligrosas)

```json
tools: {
  exec: {
    ask: "tool"  // Solo pregunta para exec/browser/files
  }
}
```

## Aprobaciones guardadas

Si aprobas algo, puedes elegir:
- **Solo esta vez** → La próxima vez pregunta de nuevo
- **Guardar para siempre** → No pregunta para ese comando específico

Para limpiar aprobaciones guardadas:

```bash
# Ver aprobaciones
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config get tools.exec.approvals

# Limpiar todas las aprobaciones
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set tools.exec.approvals "[]"
```

## Troubleshooting

### El bot no responde nada

Puede ser que dmPolicy esté muy restrictivo:

```bash
# Ver estado de pairing
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  pairing list telegram

# Aprobar un usuario
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  pairing approve telegram CODIGO
```

### "Herramienta no permitida"

Es porque la herramienta está en `deny`. Para permitirla temporalmente:

```bash
# Quitar de deny (¡precaución!)
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set tools.deny '["gateway", "cron"]'
```

## Checklist de seguridad

- [x] `tools.exec.ask: "always"` — Pregunta siempre
- [x] `tools.exec.security: "deny"` — Deniega por defecto
- [x] `channels.*.dmPolicy: "pairing"` — Solo usuarios aprobados
- [x] `sandbox.mode: "all"` — Aislamiento activo
- [ ] Token de gateway configurado
- [ ] Firewall restrictivo
- [ ] Aprobar usuarios de confianza

## Referencias

- [Exec Tool Config](https://docs.openclaw.ai/gateway/config-tools#exec)
- [Sandboxing](https://docs.openclaw.ai/gateway/sandboxing)
- [Security Model](https://docs.openclaw.ai/gateway/security)
