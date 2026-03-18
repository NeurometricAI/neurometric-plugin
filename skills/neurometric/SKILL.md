---
name: neurometric
description: Neurometric CLI - check status, replay captures, and optimize AI costs
user-invocable: true
---

# neurometric

Unified Neurometric CLI for monitoring, replaying, and optimizing AI API usage.

## Usage

```
/neurometric <command> [options]
```

**Commands:**
- `status` - Check gateway connection status
- `replay [count]` - View recent API captures
- `optimize [options]` - Get cost optimization recommendations

## Commands

---

## status

Check the current Neurometric gateway connection status.

### Usage

```
/neurometric status
```

### Description

Shows the current status of the Neurometric gateway connection, including:
- Whether the environment is configured correctly
- Connection to the Neurometric API
- Current session information
- Recent capture count

### Instructions

When the user invokes `/neurometric status`:

1. Check if environment variables are configured:

```bash
# Check if NEUROMETRIC_API_KEY is set
if [ -z "$NEUROMETRIC_API_KEY" ]; then
  echo "NEUROMETRIC_API_KEY is not set"
  exit 1
fi

# Check gateway connectivity
curl -s -H "Authorization: Bearer $NEUROMETRIC_API_KEY" \
  "https://api.neurometric.ai/v1/status"
```

2. Parse and display the response in a user-friendly format:

**If connected**, show:
```
Neurometric Status: Connected

API Key:    ...${NEUROMETRIC_API_KEY: -8} (last 8 chars)
Gateway:    https://api.neurometric.ai
Captures:   <count> API calls (last 24h)

Environment variables configured for: OpenAI, Anthropic, Cohere, Mistral, Groq, Together
```

**If not configured**, show:
```
Neurometric Status: Not Configured

NEUROMETRIC_API_KEY is not set. To enable capture:
  export NEUROMETRIC_API_KEY="sk_live_..."

Then restart your Claude Code session.
```

**If connection fails**, show:
```
Neurometric Status: Connection Failed

Could not reach https://api.neurometric.ai
Check your network connection and API key.
```

3. If the user wants more details, you can also check:
   - The config at `neurometric.config.json`

---

## replay

Fetch and display recent AI API calls captured by Neurometric.

### Usage

```
/neurometric replay [count]
```

**Arguments:**
- `count` (optional): Number of recent prompts to show. Default: 5, Max: 20

### Description

Fetches and displays recent API calls captured during this session or from Neurometric's history. Useful for:
- Reviewing what prompts were sent
- Re-running a previous prompt with modifications
- Debugging prompt/response pairs

### Instructions

When the user invokes `/neurometric replay`:

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
- NEUROMETRIC_API_KEY is set (/neurometric status)
- You have made AI API calls in this session
- The Neurometric gateway is reachable
```

5. **Offer replay options**:

After showing the captures, ask:
> Would you like to replay any of these prompts? Specify the capture number to re-run it.

If the user selects a capture to replay:
- Extract the original request parameters
- Show the prompt that will be sent
- Confirm before executing
- Make the API call through the proxy (so it gets captured again)

### Notes

- This command requires `NEUROMETRIC_API_KEY` to be set
- Only captures from the current project are shown
- The Neurometric API must support the `/v1/captures` endpoint

---

## optimize

Analyze AI usage and get recommendations for cost optimization, model routing, and latency improvements.

### Usage

```
/neurometric optimize [mode] [options]
```

**Modes:**
- `--captures` (default): Fetch recent API calls from Neurometric and analyze actual usage
- `--scan [path]`: Scan codebase for AI SDK patterns (default path: ./)
- `--describe "..."`: Analyze a natural language workflow description

**Options:**
- `--days N`: Analysis period for captures mode (default: 7)
- `--output json`: Output as JSON instead of formatted text

### Examples

```
/neurometric optimize
/neurometric optimize --captures --days 30
/neurometric optimize --scan ./src
/neurometric optimize --describe "RAG pipeline that extracts JSON from documents and summarizes them"
```

### Instructions

When the user invokes `/neurometric optimize`:

#### 1. Parse Arguments

Determine the mode and options from the arguments:

```javascript
// Default values
let mode = 'captures';
let scanPath = './';
let description = '';
let days = 7;
let outputJson = false;

// Parse arguments
if (args.includes('--scan')) {
  mode = 'scan';
  const scanMatch = args.match(/--scan\s+([^\s-]+)/);
  if (scanMatch) scanPath = scanMatch[1];
}
if (args.includes('--describe')) {
  mode = 'describe';
  const descMatch = args.match(/--describe\s+"([^"]+)"/);
  if (descMatch) description = descMatch[1];
}
const daysMatch = args.match(/--days\s+(\d+)/);
if (daysMatch) days = parseInt(daysMatch[1]);
if (args.includes('--output json')) outputJson = true;
```

#### 2. Execute Based on Mode

**Mode: captures (default)**

Fetch recent API calls from Neurometric and analyze:

```bash
curl -s -H "Authorization: Bearer $NEUROMETRIC_API_KEY" \
  "https://api.neurometric.ai/v1/captures?days=$DAYS&limit=1000"
```

Parse the response and extract:
- Model used for each call
- Input/output token counts
- Request parameters (response_format, tools, etc.)
- Latency data

**Mode: scan**

Scan the codebase for AI SDK usage patterns:

```bash
# Find OpenAI SDK usage
grep -r "openai\." --include="*.py" --include="*.ts" --include="*.js" $SCAN_PATH

# Find Anthropic SDK usage
grep -r "anthropic\." --include="*.py" --include="*.ts" --include="*.js" $SCAN_PATH

# Find model specifications
grep -rE "(gpt-4|gpt-3|claude|gemini)" --include="*.py" --include="*.ts" --include="*.js" $SCAN_PATH
```

Analyze the patterns to identify:
- Which models are hardcoded
- How requests are structured
- Potential optimization opportunities

**Mode: describe**

Parse the workflow description and classify tasks based on keywords:
- "extract", "parse", "JSON" → extraction tasks
- "summarize", "generate", "write" → generation tasks
- "analyze", "reason", "decide" → reasoning tasks
- "translate", "convert" → transformation tasks

#### 3. Apply Pricing Model

Use this pricing table (March 2026):

| Model | Input ($/1M tokens) | Output ($/1M tokens) | P50 Latency | Best For |
|-------|---------------------|----------------------|-------------|----------|
| gpt-4o | 5.00 | 15.00 | 800ms | Complex reasoning, code generation |
| gpt-4o-mini | 0.15 | 0.60 | 400ms | Simple tasks, extraction, classification |
| gpt-4-turbo | 10.00 | 30.00 | 1000ms | Legacy, complex tasks |
| gpt-3.5-turbo | 0.50 | 1.50 | 300ms | Simple chat, legacy |
| claude-sonnet-4 | 3.00 | 15.00 | 700ms | Balanced performance, coding |
| claude-opus-4 | 15.00 | 75.00 | 1200ms | Most complex reasoning |
| claude-haiku-3.5 | 0.80 | 4.00 | 300ms | Fast, simple tasks |
| gemini-2.0-flash | 0.075 | 0.30 | 200ms | Speed-critical, high volume |
| gemini-2.0-pro | 1.25 | 5.00 | 500ms | Balanced Gemini option |

#### 4. Classify Tasks and Generate Recommendations

**Task Classification Heuristics:**

| Signal | Task Type | Recommended Tier |
|--------|-----------|------------------|
| `response_format: json` or JSON schema | Extraction | Mini/Flash |
| `tools:` or `functions:` present | Function calling | Mini/Medium |
| Short input, short output | Simple Q&A | Mini/Flash |
| Long output (>500 tokens) | Generation | Medium |
| Multi-turn or chain-of-thought | Reasoning | Large |
| Code in prompt or response | Coding | Medium/Large |

**Model Recommendations by Task:**

| Task Type | Budget | Balanced | Premium |
|-----------|--------|----------|---------|
| Extraction | gemini-2.0-flash | gpt-4o-mini | gpt-4o |
| Classification | gemini-2.0-flash | gpt-4o-mini | claude-sonnet-4 |
| Simple chat | gpt-4o-mini | claude-haiku-3.5 | claude-sonnet-4 |
| Generation | gpt-4o-mini | claude-sonnet-4 | gpt-4o |
| Coding | gpt-4o-mini | claude-sonnet-4 | claude-opus-4 |
| Complex reasoning | claude-sonnet-4 | gpt-4o | claude-opus-4 |

#### 5. Calculate Savings

For each task category:
1. Sum current usage (tokens * current model price)
2. Calculate optimized cost (tokens * recommended model price)
3. Compute savings = current - optimized
4. Calculate percentage = (savings / current) * 100

#### 6. Format Output

**Standard Output:**

```
+-------------------------------------------------------------+
|              Neurometric Optimization Report                |
+-------------------------------------------------------------+
|  API Calls Analyzed:   {total_calls}                        |
|  Current Cost:         ${current_cost}/month (projected)    |
|  Optimized Cost:       ${optimized_cost}/month (projected)  |
|  Potential Savings:    ${savings}/month ({percent}%)        |
+-------------------------------------------------------------+

## Recommendations

### High Impact: {task_description} -> {recommended_model}
- Current: {current_model} (${current_monthly})
- Recommended: {recommended_model} (${recommended_monthly})
- Savings: ${savings}/mo ({percent}%)
- Latency: {latency_change}
- Confidence: {High|Medium|Low}
- Rationale: {why_this_recommendation}

### Medium Impact: ...

## Summary by Task Type

| Task Type | Calls | Current Model | Recommended | Monthly Savings |
|-----------|-------|---------------|-------------|-----------------|
| Extraction | 450 | gpt-4o | gpt-4o-mini | $66.45 |
| Generation | 200 | gpt-4o | claude-sonnet-4 | $12.00 |
| ...

## Next Steps

1. Update model selection for extraction tasks (highest impact)
2. Consider implementing model routing based on task complexity
3. Review the {N} calls using premium models for simple tasks

---
View full analysis at: https://studio.neurometric.ai/optimize
```

**JSON Output (when --output json):**

```json
{
  "summary": {
    "calls_analyzed": 1247,
    "current_cost_monthly": 127.45,
    "optimized_cost_monthly": 48.20,
    "savings_monthly": 79.25,
    "savings_percent": 62
  },
  "recommendations": [
    {
      "impact": "high",
      "task_type": "extraction",
      "current_model": "gpt-4o",
      "recommended_model": "gpt-4o-mini",
      "current_cost": 68.50,
      "optimized_cost": 2.05,
      "savings": 66.45,
      "savings_percent": 97,
      "latency_change_ms": -200,
      "confidence": "high",
      "rationale": "JSON extraction tasks don't require advanced reasoning"
    }
  ],
  "by_task_type": {
    "extraction": { "calls": 450, "current": "gpt-4o", "recommended": "gpt-4o-mini" },
    "generation": { "calls": 200, "current": "gpt-4o", "recommended": "claude-sonnet-4" }
  }
}
```

#### 7. Handle Edge Cases

**No NEUROMETRIC_API_KEY (captures mode):**
```
Error: NEUROMETRIC_API_KEY not set

To use captures mode, set your API key:
  export NEUROMETRIC_API_KEY="sk_live_..."

Alternatively, try:
  /neurometric optimize --scan ./
  /neurometric optimize --describe "your workflow"
```

**No captures found:**
```
No API calls found in the last {days} days.

Make sure:
- NEUROMETRIC_API_KEY is set (/neurometric status)
- You have made AI API calls through the gateway
- Try increasing the time range: --days 30
```

**No AI SDK patterns found (scan mode):**
```
No AI SDK usage patterns found in {path}

Searched for:
- OpenAI SDK (openai.*)
- Anthropic SDK (anthropic.*)
- Model references (gpt-*, claude-*, gemini-*)

Try:
- Specifying a different path: --scan ./src
- Using describe mode: --describe "your workflow"
```

### Notes

- Pricing data is approximate and may vary by account/tier
- Recommendations are heuristics-based; always validate for your use case
- For real-time pricing, check provider documentation
- Latency estimates are P50 under typical load

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `/neurometric status` | Check gateway connection |
| `/neurometric replay` | Show last 5 captures |
| `/neurometric replay 10` | Show last 10 captures |
| `/neurometric optimize` | Analyze captures for savings |
| `/neurometric optimize --scan ./` | Scan codebase for AI patterns |
| `/neurometric optimize --describe "..."` | Analyze workflow description |
