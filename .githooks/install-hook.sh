#!/bin/bash
# ===========================================
# Instala el pre-commit hook en el repo
# ===========================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "🪝 Instalando pre-commit hook..."

# Hacer el script ejecutable
chmod +x .githooks/pre-commit

# Crear symlink al hook
if [ -d ".git" ]; then
    # Configurar git para usar hooks personalizados
    git config core.hooksPath .githooks
    echo -e "${GREEN}✅ Hook instalado correctamente${NC}"
    echo ""
    echo "El hook se ejecutará automáticamente antes de cada commit."
else
    echo -e "${RED}❌ No se encontró .git. Ejecuta primero: git init${NC}"
    exit 1
fi
