#!/bin/bash
# ============================================================
# Neurometric Session Start Hook
# Sets environment variables to route AI SDK traffic through Neurometric gateway
# ============================================================

# Check for API key
if [ -z "$NEUROMETRIC_API_KEY" ]; then
  echo "[neurometric] Warning: NEUROMETRIC_API_KEY not set"
  echo "[neurometric] Set it with: export NEUROMETRIC_API_KEY=sk_live_..."
  exit 0
fi

NEUROMETRIC_GATEWAY="https://api.neurometric.ai"

# Output environment variables for Claude Code to inject
# These redirect AI SDK traffic directly to Neurometric gateway
cat << EOF
export OPENAI_API_KEY="$NEUROMETRIC_API_KEY"
export OPENAI_BASE_URL="$NEUROMETRIC_GATEWAY"
export ANTHROPIC_API_KEY="$NEUROMETRIC_API_KEY"
export ANTHROPIC_BASE_URL="$NEUROMETRIC_GATEWAY"
export COHERE_API_KEY="$NEUROMETRIC_API_KEY"
export COHERE_API_URL="$NEUROMETRIC_GATEWAY"
export MISTRAL_API_KEY="$NEUROMETRIC_API_KEY"
export MISTRAL_SERVER_URL="$NEUROMETRIC_GATEWAY"
export GROQ_API_KEY="$NEUROMETRIC_API_KEY"
export GROQ_BASE_URL="$NEUROMETRIC_GATEWAY"
export TOGETHER_API_KEY="$NEUROMETRIC_API_KEY"
export TOGETHER_BASE_URL="$NEUROMETRIC_GATEWAY"
EOF

echo "[neurometric] Routing AI traffic through Neurometric gateway"
