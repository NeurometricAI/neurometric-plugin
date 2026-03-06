---
name: neurometric-replay
description: Fetch and display recent AI API calls captured by Neurometric
user-invocable: true
---

# neurometric-replay

Replay recent prompts captured by Neurometric.

## Usage

```
/neurometric-replay [count]
```

**Arguments:**
- `count` (optional): Number of recent prompts to show. Default: 5, Max: 20

## Description

Fetches and displays recent API calls captured during this session or from Neurometric's history. Useful for:
- Reviewing what prompts were sent
- Re-running a previous prompt with modifications
- Debugging prompt/response pairs

## Instructions

When the user invokes this skill:

1. **Parse the argument** to get the count (default 5):

```javascript
const count = Math.min(parseInt(args) || 5, 20);
```

2. **Fetch recent captures from Neurometric API**:

```bash
curl -s -H "Authorization: Bearer $NEUROMETRIC_API_KEY" \
  "https://api.neurometric.ai/v1/captures?session_id=$SESSION_ID&limit=$COUNT"
```

3. **Display each capture** in a readable format:

For each capture, show:
```
─────────────────────────────────────────
Capture #<index> | <timestamp> | <provider>/<model>
─────────────────────────────────────────

PROMPT:
<system prompt if present>
<user message>

RESPONSE:
<assistant response>

Tokens: <prompt_tokens> in / <completion_tokens> out
Latency: <latency_ms>ms
─────────────────────────────────────────
```

4. **If no captures found**, show:
```
No captures found for this session.

Make sure:
- The Neurometric proxy is running (/neurometric-status)
- You have made AI API calls in this session
- NEUROMETRIC_API_KEY is set
```

5. **Offer replay options**:

After showing the captures, ask:
> Would you like to replay any of these prompts? Specify the capture number to re-run it.

If the user selects a capture to replay:
- Extract the original request parameters
- Show the prompt that will be sent
- Confirm before executing
- Make the API call through the proxy (so it gets captured again)

## Notes

- This skill requires `NEUROMETRIC_API_KEY` to be set
- Only captures from the current project are shown
- The Neurometric API must support the `/v1/captures` endpoint
- For local-only replay (without Neurometric backend), a future version could cache captures locally
