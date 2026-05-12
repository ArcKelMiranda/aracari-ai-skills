# 🔒 Security Audit v2 — Step 01 OpenClaw

## Issues CRÍTICOS encontrados

### 🔴 1. JSON con key `agents` duplicada (secure-ask-everything.json)

**Problema:** La key `agents` aparece DOS veces en el JSON (líneas 91 y 110). En JSON, claves duplicadas hacen que la **última sobreescriba** la anterior.

```json
{
  "agents": {          // ← PRIMERA VEZ
    "defaults": {
      "sandbox": { ... }
    }
  },
  
  "agents": {          // ← SEGUNDA VEZ (sobrescribe la primera!)
    "defaults": {
      "heartbeat": { ... }  // sandbox se PIERDE!
    }
  }
}
```

**Impacto:** La configuración de `sandbox.mode: "all"` se PIERDE porque la segunda clave `agents` la sobreescribe. El sandbox NO se activaría.

**Solución:** Unir ambas configuraciones en una sola clave `agents`.

---

### 🔴 2. Contradicción en docker-compose.yml

**Problema:** 
```yaml
OPENCLAW_GATEWAY_MODE=lan      # ← Expuesto a LAN
OPENCLAW_GATEWAY_BIND=loopback # ← Solo loopback
```

`mode=lan` y `bind=loopback` son contradictorios. `mode=lan` está pensadow para acceso de red, pero `bind=loopback` lo restringe a localhost.

**Solución:** Cambiar a:
```yaml
OPENCLAW_GATEWAY_MODE=local
OPENCLAW_GATEWAY_BIND=loopback
```

---

### 🔴 3. Contenedor Docker corre como root

**Problema:** La imagen de OpenClaw corre como usuario `node` (uid 1000), pero el contenedor mismo puede estar privilegiado si Docker lo permite.

**Solución:** Ya estamos usando usuario node (no root dentro del contenedor), pero deberíamos asegurar que el Docker host no tenga el socket Docker expuesto innecesariamente.

---

### 🔴 4. No hay `read_only` root filesystem en Docker

**Problema:** El contenedor puede escribir en el filesystem raíz.

**Solución:** Agregar:
```yaml
read_only: true
```

---

### 🔴 5. No hay resource limits en Docker

**Problema:** Sin límites de RAM/CPU, un error puede consumir todos los recursos.

**Solución:** Agregar:
```yaml
deploy:
  resources:
    limits:
      memory: 2G
    reservations:
      memory: 512M
```

---

## Issues ALTOS

### 🟠 6. Script genera token con `openssl` sin verificar que existe

**Archivo:** `setup-vps.sh` línea 64

```bash
RANDOM_TOKEN=$(openssl rand -hex 32)
```

**Problema:** Si `openssl` no está instalado, el script falla silenciosamente o usa valores incorrectos.

**Solución:** Verificar antes o usar alternativa:
```bash
if command -v openssl &> /dev/null; then
    RANDOM_TOKEN=$(openssl rand -hex 32)
else
    RANDOM_TOKEN=$(head -c 32 /dev/urandom | xxd -p)
fi
```

---

### 🟠 7. allowFrom vacío/predeterminado en canales

**Problema:** Aunque dmPolicy es "pairing", no hemos configurado allowFrom explícitamente con los números de los administradores.

**Solución:** Agregar en .env:
```
OPENCLAW_TELEGRAM_ALLOW_FROM='["tu-telegram-id"]'
OPENCLAW_WHATSAPP_ALLOW_FROM='["+1234567890"]'
```

---

### 🟠 8. No hay fail2ban o similar

**Problema:** Si alguien intenta brute-force al gateway token, no hay protección.

**Solución:** Configurar fail2ban o usar autenticación adicional.

---

## Issues MEDIOS

### 🟡 9. Docker network es `bridge` por defecto (sin restricciones)

**Problema:** El contenedor está en una red bridge estándar de Docker.

**Solución:** Para mayor aislamiento:
```yaml
networks:
  openclaw-net:
    driver: bridge
    enable_ipv6: false
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

---

### 🟡 10. No hay HEALTHCHECK robusto para sandbox

**Problema:** El healthcheck solo verifica el gateway, no el sandbox.

---

### 🟡 11. bind mount de `./data` sin restricciones

**Problema:** Los volúmenes montados podrían tener permisos demasiado abiertos en el host.

**Solución:** El script ya hace `chmod 700`, pero verificar que el host también tenga permisos restrictivos.

---

## Issues BAJOS

### 🟢 12. Chinese characters en ask-before-everything.md

**Archivo:** `docs/ask-before-everything.md` línea 158
```
，可能是dmPolicy está muy restrictivo:
```

Error tipográfico con caracteres chinos mezclados.

---

### 🟢 13. Comentarios en JSON5

Los comentarios `//` son válidos en JSON5 pero NO en JSON estándar. Si alguien copia el archivo y lo usa como JSON puro, fallará.

**Nota:** OpenClaw soporta JSON5, pero otros parsers no.

---

## Configuración CORREGIDA

### secure-ask-everything.json (FIXED)

```json
{
  "gateway": {
    "mode": "local",
    "bind": "loopback",
    "auth": {
      "mode": "token",
      "token": "${OPENCLAW_GATEWAY_TOKEN}"
    }
  },

  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "pairing",
      "groups": {
        "*": {
          "requireMention": true
        }
      }
    },
    "whatsapp": {
      "enabled": true,
      "dmPolicy": "pairing",
      "groups": {
        "*": {
          "requireMention": true
        }
      }
    }
  },

  "tools": {
    "profile": "messaging",
    "exec": {
      "ask": "always",
      "security": "deny",
      "shell": {
        "ask": "always"
      },
      "fs": {
        "workspaceOnly": true
      }
    },
    "deny": [
      "gateway",
      "cron",
      "sessions_spawn",
      "sessions_send",
      "browser",
      "elevated",
      "group:automation",
      "group:runtime",
      "group:fs"
    ]
  },

  "session": {
    "dmScope": "per-channel-peer"
  },

  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "all",
        "scope": "session",
        "workspaceAccess": "none"
      },
      "heartbeat": {
        "every": "30m",
        "target": "last",
        "directPolicy": "block"
      }
    }
  },

  "messages": {
    "visibleReplies": "automatic",
    "groupChat": {
      "visibleReplies": "message_tool"
    }
  },

  "logging": {
    "redactSensitive": "tools"
  }
}
```

### docker-compose.yml (FIXED)

```yaml
version: '3.8'

services:
  openclaw-gateway:
    image: ghcr.io/openclaw/openclaw:latest
    container_name: openclaw-gateway
    restart: unless-stopped
    read_only: true  # ROOT FS SOLO LECTURA
    ports:
      - "127.0.0.1:18789:18789"
    environment:
      - OPENCLAW_GATEWAY_MODE=local  # CORREGIDO
      - OPENCLAW_GATEWAY_BIND=loopback
      - OPENCLAW_DISABLE_BONJOUR=1
    volumes:
      - ./data/.openclaw:/home/node/.openclaw
      - ./data/workspace:/home/node/.openclaw/workspace
      - tmp_data:/tmp/openclaw  # Para archivos temporales
    env_file:
      - ./config/.env
    networks:
      - openclaw-net
    healthcheck:
      test: ["CMD", "node", "dist/index.js", "health"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 512M

  openclaw-cli:
    image: ghcr.io/openclaw/openclaw:latest
    container_name: openclaw-cli
    depends_on:
      - openclaw-gateway
    environment:
      - OPENCLAW_GATEWAY_URL=http://openclaw-gateway:18789
    env_file:
      - ./config/.env
    volumes:
      - ./data/.openclaw:/home/node/.openclaw
      - ./data/workspace:/home/node/.openclaw/workspace
    networks:
      - openclaw-net
    entrypoint: ["node", "dist/index.js"]
    read_only: true

networks:
  openclaw-net:
    driver: bridge

volumes:
  tmp_data:
```

---

## Checklist de seguridad actualizado

- [x] Puerto 18789 solo localhost (127.0.0.1)
- [x] bind: loopback
- [x] dmPolicy: pairing
- [x] tools.exec.ask: always
- [x] tools.exec.security: deny
- [x] sandbox.mode: all
- [x] Token de gateway obligatorio
- [x] Permisos 600 en .env
- [x] Permisos 700 en directorios de datos
- [x] Docker read_only root fs
- [x] Docker resource limits
- [x] FIXED: agents key no duplicada
- [x] FIXED: gateway mode corregido
- [ ] allowFrom configurado con IDs de admins
- [ ] Firewall UFW configurado
- [ ] fail2ban (opcional pero recomendado)

---

## Referencias

- [Security Docs](https://docs.openclaw.ai/gateway/security)
- [Sandboxing](https://docs.openclaw.ai/gateway/sandboxing)
- [Docker Security](https://docs.openclaw.ai/install/docker)
