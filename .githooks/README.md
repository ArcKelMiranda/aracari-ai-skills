# 🔒 Pre-Commit Hook — Seguridad

Este hook valida que **no haya datos sensibles** antes de cada commit.

## ¿Qué verifica?

### 1. Archivos sensibles
- `.env` con valores reales
- `openclaw.json` con tokens
- `secrets.yaml`, `credentials.json`

### 2. Patrones sensibles
Busca en todos los archivos staged:
- API keys (OpenAI, Anthropic, MiniMax, etc.)
- Tokens de Telegram/WhatsApp
- Contraseñas hardcodeadas
- AWS keys
- Tokens JWT
- Private keys (RSA, EC, etc.)
- Tokens de GitHub (`ghp_...`)

### 3. Directorios prohibidos
- `data/` — contiene sesiones y credenciales
- `.openclaw/` con config real

### 4. .gitignore
Verifica que existan las reglas para:
- `.env` / `config/.env`
- `data/`

## Instalación

```bash
# Una sola vez
cd aracari-ai-skills
git init  # si no está inicializado
./.githooks/install-hook.sh

# O manualmente:
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
```

## Verificación manual

```bash
# Probar el hook sin commitear
.githooks/pre-commit
```

## Si el hook falla

1. **Revisa el error** — te dice qué archivo/patrón encontró
2. **Elimina los datos sensibles** del archivo
3. **Usa templates** — `config/.env.example` para configuración
4. **Datos reales** van en `.env.local` (que está en .gitignore)

## Skip en caso de emergencia

```bash
git commit --no-verify -m "fix urgencia"
```

⚠️ **No recomendado** — solo para casos extremos.

## Archivos

```
.githooks/
├── pre-commit        # Hook principal (ejecutable)
├── install-hook.sh   # Script de instalación
└── README.md         # Este archivo
```
