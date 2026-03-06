# Neurometric Claude Code Plugin — Project Context

A Claude Code plugin that routes AI API calls through the Neurometric gateway for automatic logging and evaluation.

---

## How It Works

```
┌─────────────────┐                      ┌─────────────────┐
│   Your Code     │─────────────────────▶│   Neurometric   │────▶ OpenAI/etc
│   (AI SDK)      │                      │   Gateway       │
└─────────────────┘                      └─────────────────┘
                                                │
                                                ▼
                                         Automatic logging
```

1. **Session Start**: Hook sets env vars to point AI SDKs at `api.neurometric.ai`
2. **During Session**: All AI API calls go directly to Neurometric gateway
3. **Neurometric**: Logs the request, forwards to upstream, returns response
4. **Session End**: Shows link to Neurometric dashboard

**No local proxy needed** — env vars redirect traffic directly to the hosted gateway.

---

## Directory Structure

```
neurometric-plugin/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── hooks/
│   ├── hooks.json               # Hook definitions
│   ├── session-start.sh         # Sets env vars for Neurometric gateway
│   └── session-end.sh           # Shows dashboard link
├── skills/
│   ├── neurometric-status/
│   │   └── SKILL.md             # /neurometric-status
│   └── neurometric-replay/
│       └── SKILL.md             # /neurometric-replay
├── neurometric.config.json      # User config (optional)
├── settings.json
├── CLAUDE.md
└── README.md
```

---

## Environment Variables

The session-start hook sets these automatically:

| Variable | Value |
|----------|-------|
| `OPENAI_BASE_URL` | `https://api.neurometric.ai` |
| `OPENAI_API_KEY` | `$NEUROMETRIC_API_KEY` |
| `ANTHROPIC_BASE_URL` | `https://api.neurometric.ai` |
| `ANTHROPIC_API_KEY` | `$NEUROMETRIC_API_KEY` |
| ... | (all providers) |

---

## Installation

```bash
export NEUROMETRIC_API_KEY="sk_live_..."
claude --plugin-dir /path/to/neurometric-plugin
```

---

## Limitations

- **No streaming** — Neurometric gateway does not support `stream: true`
- **Model availability** — Only models on your Neurometric account work

---

## Skills

- `/neurometric-status` — Check if routing is active
- `/neurometric-replay` — View recent captures from Neurometric
