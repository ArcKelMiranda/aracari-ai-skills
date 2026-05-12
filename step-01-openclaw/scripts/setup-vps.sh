#!/bin/bash
# ===========================================
# Script de instalación de OpenClaw en VPS
# Para: aracari-ai-skills Step 01
# ===========================================

set -e

echo "🦞 Instalando OpenClaw en VPS..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detectar si hay Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado. Abortando.${NC}"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker Compose v2 no encontrado. Intentando con 'docker-compose'...${NC}"
    DOCKER_COMPOSE="docker-compose"
else
    DOCKER_COMPOSE="docker compose"
fi

echo -e "${GREEN}✅ Docker detectado${NC}"

# Verificar Node.js (opcional, para CLI local)
if command -v node &> /dev/null; then
    echo -e "${GREEN}✅ Node.js version: $(node --version)${NC}"
else
    echo -e "${YELLOW}⚠️  Node.js no detectado. Solo usaremos Docker.${NC}"
fi

# Crear directorios de datos con permisos restrictivos
echo "📁 Creando directorios de datos con permisos seguros..."
mkdir -p step-01-openclaw/data/.openclaw
mkdir -p step-01-openclaw/data/workspace
chmod 700 step-01-openclaw/data
chmod 700 step-01-openclaw/data/.openclaw
chmod 700 step-01-openclaw/data/workspace
chmod 700 step-01-openclaw

# Copiar .env.example a .env si no existe
if [ ! -f step-01-openclaw/config/.env ]; then
    echo "📝 Creando archivo .env desde template..."
    cp step-01-openclaw/config/openclaw.env.example step-01-openclaw/config/.env
    chmod 600 step-01-openclaw/config/.env  # Permisos restrictivos para secrets
    echo -e "${YELLOW}⚠️  IMPORTANTE: Edita step-01-openclaw/config/.env y agrega tus tokens!${NC}"
    echo -e "${YELLOW}⚠️  IMPORTANTE: Genera un token seguro para OPENCLAW_GATEWAY_TOKEN${NC}"
else
    echo -e "${GREEN}✅ Archivo .env ya existe${NC}"
    # Asegurar permisos aunque ya exista
    chmod 600 step-01-openclaw/config/.env
fi

# Generar token de gateway si no existe
if grep -q "OPENCLAW_GATEWAY_TOKEN=$" step-01-openclaw/config/.env 2>/dev/null; then
    echo "🔑 Generando token de gateway..."
    # Usar openssl si existe, si no usar /dev/urandom
    if command -v openssl &> /dev/null; then
        RANDOM_TOKEN=$(openssl rand -hex 32)
    else
        RANDOM_TOKEN=$(head -c 32 /dev/urandom | xxd -p -c 64)
    fi
    # Escapar caracteres especiales para sed
    ESCAPED_TOKEN=$(echo "$RANDOM_TOKEN" | sed 's/[/&]/\\&/g')
    sed -i "s/OPENCLAW_GATEWAY_TOKEN=$/OPENCLAW_GATEWAY_TOKEN=${ESCAPED_TOKEN}/" step-01-openclaw/config/.env
    echo -e "${GREEN}✅ Token de gateway generado${NC}"
fi

# Copiar config segura (con MiniMax provider)
echo "📋 Copiando configuración segura con MiniMax..."
if [ -f step-01-openclaw/config/secure-ask-everything.json ]; then
    cp step-01-openclaw/config/secure-ask-everything.json step-01-openclaw/data/.openclaw/openclaw.json
    chmod 600 step-01-openclaw/data/.openclaw/openclaw.json
    echo -e "${GREEN}✅ Config segura copiada${NC}"
else
    echo -e "${YELLOW}⚠️  No se encontró secure-ask-everything.json - usando config por defecto${NC}"
fi

# Pull de la imagen de Docker
echo "📦 Descargando imagen de OpenClaw (puede tardar en la primera vez)..."
docker pull ghcr.io/openclaw/openclaw:latest

# Iniciar el gateway
echo "🚀 Iniciando OpenClaw Gateway..."
cd step-01-openclaw
$DOCKER_COMPOSE -f docker/docker-compose.yml up -d

# Esperar a que el servicio esté listo
echo "⏳ Esperando que el gateway esté listo..."
sleep 5

# Verificar estado
echo "🔍 Verificando estado del gateway..."
curl -fsS http://127.0.0.1:18789/healthz 2>/dev/null && echo -e "${GREEN}✅ Gateway está respondiendo!${NC}" || echo -e "${RED}❌ Gateway no responde. Revisa los logs con: docker compose logs openclaw-gateway${NC}"

# ===== VERIFICACIONES DE SEGURIDAD =====
echo ""
echo "🔒 Ejecutando verificaciones de seguridad..."

# Verificar que el gateway token está configurado
if grep -q "OPENCLAW_GATEWAY_TOKEN=" step-01-openclaw/config/.env; then
    TOKEN_VALUE=$(grep "OPENCLAW_GATEWAY_TOKEN=" step-01-openclaw/config/.env | cut -d'=' -f2)
    if [ -n "$TOKEN_VALUE" ] && [ "$TOKEN_VALUE" != "" ]; then
        echo -e "${GREEN}✅ Token de gateway configurado${NC}"
    else
        echo -e "${RED}❌ Token de gateway está vacío!${NC}"
    fi
fi

# Verificar que dmPolicy está configurado
echo ""
echo "📋 Para máxima seguridad, configura dmPolicy='pairing' en tu .env:"
echo "   OPENCLAW_TELEGRAM_DM_POLICY=pairing"
echo "   OPENCLAW_WHATSAPP_DM_POLICY=pairing"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  🎉 Instalación completada!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "⚠️  IMPORTANTE - Pasos de seguridad:"
echo "1. Edita config/.env y configura dmPolicy='pairing'"
echo "2. Configura tu firewall UFW:"
echo "   ufw allow from TU_IP to any port 18789"
echo "3. Para acceso remoto usa SSH tunnel o reverse proxy con HTTPS"
echo ""
echo "Comandos útiles:"
echo "  Ver logs:        $DOCKER_COMPOSE -f docker/docker-compose.yml logs -f"
echo "  Detener:         $DOCKER_COMPOSE -f docker/docker-compose.yml down"
echo "  Reiniciar:       $DOCKER_COMPOSE -f docker/docker-compose.yml restart"
echo "  Estado:          $DOCKER_COMPOSE -f docker/docker-compose.yml ps"
echo "  Security audit:   $DOCKER_COMPOSE -f docker/docker-compose.yml run --rm openclaw-cli security audit"
echo "  Acceso local UI:  http://127.0.0.1:18789"
