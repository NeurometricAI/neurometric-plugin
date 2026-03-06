---
name: neurometric-status
description: Check the current Neurometric proxy session status (captures, tokens, session ID)
user-invocable: true
---

# neurometric-status

Check the current Neurometric capture session status.

## Usage

```
/neurometric-status
```

## Description

Shows the current status of the Neurometric proxy, including:
- Whether the proxy is running
- Current session ID
- Number of API calls captured this session
- Total tokens processed

## Instructions

When the user invokes this skill, execute the following:

1. Check if the proxy is running by reading the PID file and checking the health endpoint:

```bash
PLUGIN_DIR="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
PID_FILE="$PLUGIN_DIR/.neurometric-proxy.pid"
PORT="${PROXY_PORT:-9999}"

if [ -f "$PLUGIN_DIR/neurometric.config.json" ]; then
  PORT=$(node -e "try{console.log(require('$PLUGIN_DIR/neurometric.config.json').proxy?.port||9999)}catch{console.log(9999)}" 2>/dev/null)
fi

curl -s "http://127.0.0.1:$PORT/health"
```

2. Parse and display the response in a user-friendly format:

**If proxy is running**, show:
```
Neurometric Status: Active

Session ID: <session_id>
Captures:   <count> API calls
Tokens:     <total_tokens> total

Proxy running on port <port>
```

**If proxy is not running**, show:
```
Neurometric Status: Inactive

The proxy is not running. Start a new Claude Code session to enable capture.
```

3. If the user wants more details, you can also check:
   - The log file at `.neurometric-proxy.log`
   - The config at `neurometric.config.json`
