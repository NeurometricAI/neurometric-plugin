# Neurometric Claude Code Plugin

Route your AI API calls through Neurometric for automatic logging, evaluation, and analysis.

## How It Works

When you start a Claude Code session with this plugin, it sets environment variables that redirect all AI SDK traffic directly to the Neurometric gateway (`api.neurometric.ai`). Neurometric logs every request and forwards it to the appropriate upstream provider.

```
Your Code  ──▶  Neurometric Gateway  ──▶  OpenAI / Anthropic / etc
                      │
                      ▼
               Automatic logging
```

## Installation

1. Clone the plugin:

```bash
git clone https://github.com/neurometric/claude-code-plugin ~/.claude/plugins/neurometric
```

2. Set your Neurometric API key:

```bash
export NEUROMETRIC_API_KEY="sk_live_your-api-key"
```

3. Start Claude Code with the plugin:

```bash
claude --plugin-dir ~/.claude/plugins/neurometric
```

## What Gets Set

The plugin automatically configures these environment variables:

| SDK | Environment Variables |
|-----|----------------------|
| OpenAI | `OPENAI_BASE_URL`, `OPENAI_API_KEY` |
| Anthropic | `ANTHROPIC_BASE_URL`, `ANTHROPIC_API_KEY` |
| Cohere | `COHERE_API_URL`, `COHERE_API_KEY` |
| Mistral | `MISTRAL_SERVER_URL`, `MISTRAL_API_KEY` |
| Groq | `GROQ_BASE_URL`, `GROQ_API_KEY` |
| Together | `TOGETHER_BASE_URL`, `TOGETHER_API_KEY` |

All point to `https://api.neurometric.ai` with your Neurometric API key.

## Skills

**Check status:**
```
/neurometric-status
```

**View recent captures:**
```
/neurometric-replay [count]
```

## Limitations

- **No streaming** — Neurometric does not support `stream: true` requests
- **Model availability** — Only models configured on your Neurometric account are accessible

## Links

- [Neurometric Dashboard](https://studio.neurometric.ai)
- [Documentation](https://docs.neurometric.ai)
- [Report Issues](https://github.com/neurometric/claude-code-plugin/issues)

## License

MIT
