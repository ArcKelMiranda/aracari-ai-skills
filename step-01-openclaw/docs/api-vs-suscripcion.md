# API directa vs Plan existente

## Entendiendo las opciones

OpenClaw puede conectarse a modelos de IA de dos maneras principales:

### 1. API directa (Pay-as-you-go)

```json
{
  "agent": {
    "model": "anthropic/claude-sonnet-4-20250514"
  }
}
```

**Cómo funciona:**
- Creas una cuenta en el proveedor (Anthropic, OpenAI, etc.)
- Generas una API key desde su dashboard
- Pagas por tokens consumidos en tiempo real
- La API key se guarda en `~/.openclaw/openclaw.json` o variable de entorno

**Proveedores y costos aproximados:**

| Proveedor | Modelo | Costo input | Costo output |
|-----------|--------|-------------|--------------|
| Anthropic | Claude Sonnet 4 | $3/1M tokens | $15/1M tokens |
| Anthropic | Claude Opus 4 | $15/1M tokens | $75/1M tokens |
| OpenAI | GPT-4o | $5/1M tokens | $15/1M tokens |
| Google | Gemini 1.5 Pro | $1.25/1M tokens | $5/1M tokens |

### 2. Plan existente (OAuth/Suscripción)

Si ya tienes una suscripción activa:

**Ejemplo: Claude Max ($100/mes)**
- Viene con límites más altos de uso
- Se vincula vía OAuth flow
- OpenClaw puede usar tu suscripción existente

**Ejemplo: ChatGPT Plus ($20/mes)**
- Solo para modelos ChatGPT (no Codex)
- Se configura en el onboarding

## Comparación directa

| Aspecto | API directa | Plan existente |
|---------|------------|---------------|
| **Costo** | Pay-per-use | Suscripción fija |
| **Límites** | Depends on plan | Límites altos (Max) |
| **Control** | Total | Limitado al plan |
| **Flexibilidad** | Cualquier modelo | Solo del proveedor |
| **Ideal para** | Uso moderado/alto | Uso intensivo constante |

## Recomendación del roadmap

Para el equipo Aracari:

1. **Empezar con API directa**: 
   - Más control y flexibilidad
   - Podemos empezar con Sonnet (~$3/1M input)
   - Monitorizar consumo fácilmente

2. **Considerar plan existente** si:
   - Ya tenemos Claude Max
   - El uso justifica la suscripción fija
   - Necesitamos límites altos frecuentes

## Cómo configurar cada uno

### API directa (recomendado para empezar)

```bash
# Configurar modelo y API key
export ANTHROPIC_API_KEY="sk-ant-xxxxx"

# O en el archivo ~/.openclaw/openclaw.json
{
  "agent": {
    "model": "anthropic/claude-sonnet-4-20250514"
  }
}
```

### Plan existente (OAuth)

```bash
# En el onboarding
openclaw onboard

# Seleccionar el proveedor y "Login with [Provider]"
# Se abrirá un navegador para autenticarte
```

## Recomendación

Para el paso 1 del roadmap:
1. **Empezar con API directa** usando Claude Sonnet
2. Configurar un budget/alert para controlar gastos
3. Una vez entendamos el uso, evaluar si conviene un plan más caro

## Verificación de costos

```bash
# Ver uso de tokens en una sesión
openclaw usage

# Configurar alertas en el provider
# Anthropic: https://console.anthropic.com/settings/billing
# OpenAI: https://platform.openai.com/settings/billing
```
