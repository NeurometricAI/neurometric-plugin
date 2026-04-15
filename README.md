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

Install via the Claude Code plugin manager. Inside a Claude Code session, run:

```
/plugin marketplace add NeurometricAI/neurometric-plugin
/plugin install neurometric@neurometric
```

Set your Neurometric API key in your shell:

```bash
export NEUROMETRIC_API_KEY="sk_live_your-api-key"
```

Restart Claude Code. The plugin's `SessionStart` hook configures the gateway
environment variables automatically on each session.

### Updating

```
/plugin marketplace update neurometric
```

### Development / local testing

To run from a local checkout (useful for contributors or while iterating on
the plugin):

```bash
git clone https://github.com/NeurometricAI/neurometric-plugin
claude --plugin-dir ./neurometric-plugin
```

`--plugin-dir` can be passed multiple times to load several local plugins
side by side:

```bash
claude --plugin-dir ./neurometric-plugin --plugin-dir /path/to/other-plugin
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
/neurometric status
```

**View recent captures:**
```
/neurometric replay [count]
```

**Get cost optimization recommendations:**
```
/neurometric optimize [--captures | --scan ./path | --describe "..."]
```

## Limitations
- **Model availability** — Only models configured on your Neurometric account are accessible

## Links

- [Neurometric Dashboard](https://studio.neurometric.ai)
- [Documentation](https://docs.neurometric.ai)
- [Report Issues](https://github.com/NeurometricAI/neurometric-plugin/issues)

## License

MIT
