# 🔒 Security Audit — Step 01 OpenClaw

## Issues encontrados

### 🔴 CRÍTICO

#### 1. Puerto 18789 expuesto públicamente sin autenticación
**Archivo:** `docker/docker-compose.yml`
```yaml
ports:
  - "18789:18789"  # Gateway UI
```
**Problema:** Si el firewall de la VPS permite acceso entrante, cualquiera puede acceder al Gateway UI.

**Solución:** 
- Usar `bind: "loopback"` y un reverse proxy con HTTPS
- O configurar `gateway.auth.token` fuerte
- O cerrar el puerto con firewall (solo permitir desde tu IP)

#### 2. dmPolicy no configurado explícitamente
**Archivo:** `docker/docker-compose.yml`
**Problema:** Por defecto, puede que acepte mensajes de cualquiera sin pairing.

**Solución:** Agregar en la configuración:
```yaml
environment:
  - OPENCLAW_TELEGRAM_DM_POLICY=pairing
  - OPENCLAW_WHATSAPP_DM_POLICY=pairing
```

### 🟠 ALTO

#### 3. .env con permisosIncorrectos después de copiar
**Archivo:** `scripts/setup-vps.sh`
**Problema:** El script copia `.env` pero no cambia permisos a 600.

**Solución:**
```bash
chmod 600 step-01-openclaw/config/.env
```

#### 4. No hay allowlist de IPs en el firewall
**Archivo:** `scripts/setup-vps.sh`
**Problema:** El script no configura qué IPs pueden acceder a la VPS.

**Solución:** Agregar reglas UFW:
```bash
ufw allow from TU_IP to any port 18789
```

#### 5. No se ejecuta `openclaw security audit`
**Archivo:** `scripts/setup-vps.sh`
**Problema:** No hay verificación de seguridad post-instalación.

**Solución:** Agregar al final del script:
```bash
docker compose -f docker/docker-compose.yml run --rm openclaw-cli security audit --fix
```

### 🟡 MEDIO

#### 6. WhatsApp sin allowFrom
**Archivo:** `docs/whatsapp-setup.md`
**Problema:** No hay configuración de números permitidos.

**Solución:** Agregar en la config:
```bash
docker compose -f docker/docker-compose.yml run --rm openclaw-cli \
  config set channels.whatsapp.allowFrom '["+1234567890"]'
```

#### 7. Telegram sin allowFrom
**Archivo:** `docs/telegram-setup.md`
**Problema:** Mismoissue que WhatsApp.

**Solución:** Mismo fix.

### 🟢 BAJO

#### 8. Directorios de datos sin permisos restrictivos
**Archivo:** `scripts/setup-vps.sh`
**Problema:** Los directorios se crean con `mkdir -p` sin permisos.

**Solución:**
```bash
chmod 700 step-01-openclaw/data
chmod 700 step-01-openclaw/data/.openclaw
chmod 700 step-01-openclaw/data/workspace
```

---

## Configuración de seguridad recomendada

### docker-compose.yml hardening

```yaml
version: '3.8'

services:
  openclaw-gateway:
    image: ghcr.io/openclaw/openclaw:latest
    container_name: openclaw-gateway
    restart: unless-stopped
    ports:
      - "127.0.0.1:18789:18789"  # SOLO localhost!
    environment:
      - OPENCLAW_GATEWAY_BIND=loopback  # CAMBIADO: solo loopback
      - OPENCLAW_DISABLE_BONJOUR=1
      - OPENCLAW_GATEWAY_TOKEN=${OPENCLAW_GATEWAY_TOKEN}  # Token requerido!
    volumes:
      - ./data/.openclaw:/home/node/.openclaw
      - ./data/workspace:/home/node/.openclaw/workspace
    env_file:
      - ./config/.env
    networks:
      - openclaw-net
    healthcheck:
      test: ["CMD", "node", "dist/index.js", "health"]
      interval: 30s
      timeout: 10s
      retries: 3

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

networks:
  openclaw-net:
    driver: bridge
```

### .env hardening

```bash
# === SEGURIDAD ===
OPENCLAW_GATEWAY_TOKEN=genera-un-token-muy-largo-y-aleatorio-aqui

# Telegram - DM pairing (recomendado)
OPENCLAW_TELEGRAM_DM_POLICY=pairing

# WhatsApp - DM pairing (recomendado)
OPENCLAW_WHATSAPP_DM_POLICY=pairing

# Solo IPs de confianza (opcional)
OPENCLAW_ALLOW_FROM=tu-ip-publica-aqui
```

---

## Reglas de firewall UFW (importante!)

```bash
# En la VPS, ejecutar:

# 1. Asegurar SSH (¡primero!)
ufw allow 22/tcp comment 'SSH'

# 2. Solo permitir acceso al gateway desde TU IP
ufw allow from TU_IP to any port 18789 comment 'OpenClaw Gateway'

# 3. Si usas Telegram Webhook, también abre ese puerto
# ufw allow 443/tcp comment 'HTTPS'

# 4. Activar firewall
ufw enable

# 5. Verificar reglas
ufw status numbered
```

---

## Verificación post-instalación

```bash
# 1. Verificar que el gateway responde localmente
curl -s http://127.0.0.1:18789/healthz

# 2. Ejecutar audit de seguridad
docker compose -f docker/docker-compose.yml run --rm openclaw-cli security audit

# 3. Ver logs por actividad sospechosa
docker compose -f docker/docker-compose.yml logs --tail=100 | grep -i "unauthorized\|failed\|error"

# 4. Verificar que el token está configurado
docker compose -f docker/docker-compose.yml run --rm openclaw-cli config get gateway.auth.mode
```

---

## Checklist de seguridad

- [ ] Token de gateway generado y configurado en .env
- [ ] Puerto 18789 solo accesible desde localhost o IP confiable
- [ ] dmPolicy configurado como "pairing"
- [ ] allowFrom configurado con números/IDs autorizados
- [ ] Permisos de archivos correctos (600 para .env, 700 para directorios)
- [ ] openclaw security audit passes
- [ ] Firewall configurado (UFW)
- [ ] No exponer puertos innecesarios
- [ ] Usar HTTPS si se accede remotamente (reverse proxy)

---

## Referencias

- [OpenClaw Security Docs](https://docs.openclaw.ai/gateway/security)
- [Security Audit Checks](https://docs.openclaw.ai/gateway/security/audit-checks)
- [Docker Firewall UFW](https://docs.openclaw.ai/install/docker#docker-port-publishing-with-ufw)
