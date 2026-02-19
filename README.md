# Anthropic to OpenAI Router

A fast, lightweight router that translates Anthropic API calls to OpenAI-compatible endpoints. Built with Bun for maximum performance.

## Features

- 🚀 **Fast**: Built with Bun's high-performance HTTP server
- 🔄 **Streaming**: Full support for SSE streaming responses
- 🛠️ **Tool Calls**: Complete tool use/call support in both directions
- 🎯 **Model Mapping**: Map Anthropic models (haiku, sonnet, opus) to any OpenAI-compatible models
- 🔑 **Auth Forwarding**: Forwards API keys transparently
- 🧵 **Multithreaded**: Bun automatically utilizes multiple threads
- 📝 **Request Logging**: Optional conversation logging to files
- 🌐 **CORS Support**: Configurable CORS headers
- ⏱️ **Timeouts**: Configurable request timeouts

## Installation

```bash
bun install
```

## Usage

```bash
bun run index.ts \
  --port 3000 \
  --endpoint https://api.openai.com/v1 \
  --haiku gpt-4o-mini \
  --sonnet gpt-4o \
  --opus gpt-4-turbo
```

### Options

| Option | Description | Default | Required |
|--------|-------------|---------|----------|
| `--port` | Port to listen on | `3000` | No |
| `--endpoint` | OpenAI compatible endpoint URL | - | Yes |
| `--haiku` | Model mapping for `claude-haiku-*` | - | Yes |
| `--sonnet` | Model mapping for `claude-sonnet-*` | - | Yes |
| `--opus` | Model mapping for `claude-opus-*` | - | Yes |
| `--log-dir` | Directory to log conversations | disabled | No |
| `--cors-origin` | CORS origin (`*` for any, `none` to disable) | `*` | No |
| `--timeout` | Request timeout in seconds | `120` | No |
| `--help` | Show help message | - | No |

### Example with Logging

```bash
bun run index.ts \
  --endpoint https://api.openai.com/v1 \
  --haiku gpt-4o-mini \
  --sonnet gpt-4o \
  --opus gpt-4-turbo \
  --log-dir ./logs \
  --timeout 60
```

### Example with OpenRouter

```bash
bun run index.ts \
  --endpoint https://openrouter.ai/api/v1 \
  --haiku openai/gpt-4o-mini \
  --sonnet openai/gpt-4o \
  --opus anthropic/claude-3-opus \
  --cors-origin http://localhost:3000
```

### Example with Local LLM (llama.cpp)

```bash
bun run index.ts \
  --endpoint http://localhost:8080/v1 \
  --haiku local-model \
  --sonnet local-model \
  --opus local-model \
  --timeout 300
```

## API Usage

Once running, the router accepts standard Anthropic API requests:

```bash
curl http://localhost:3000/v1/messages \
  -H "x-api-key: your-openai-api-key" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-haiku-4-5-20251001",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

### Streaming Example

```bash
curl http://localhost:3000/v1/messages \
  -H "x-api-key: your-openai-api-key" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-sonnet-4-5-20251001",
    "max_tokens": 1024,
    "stream": true,
    "messages": [
      {"role": "user", "content": "Tell me a story"}
    ]
  }'
```

### Tool Use Example

```bash
curl http://localhost:3000/v1/messages \
  -H "x-api-key: your-openai-api-key" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-sonnet-4-5-20251001",
    "max_tokens": 1024,
    "tools": [
      {
        "name": "get_weather",
        "description": "Get weather for a location",
        "input_schema": {
          "type": "object",
          "properties": {
            "location": {"type": "string"}
          },
          "required": ["location"]
        }
      }
    ],
    "messages": [
      {"role": "user", "content": "What is the weather in Paris?"}
    ]
  }'
```

## Model Mapping

The router detects model names containing:
- `"haiku"` → maps to your `--haiku` model
- `"sonnet"` → maps to your `--sonnet` model  
- `"opus"` → maps to your `--opus` model

Any model name containing these substrings will be routed accordingly (e.g., `claude-haiku-4-5-20251001` maps to your haiku model).

## Conversation Logging

When `--log-dir` is specified, each request/response pair is logged as a JSON file:

```json
{
  "timestamp": "2026-02-19T01:23:45.123Z",
  "requestId": "lmnop12345_abcdefg",
  "anthropicRequest": { ... },
  "openAIRequest": { ... },
  "response": { ... },
  "durationMs": 1234
}
```

Log files are named: `YYYY-MM-DDTHH-MM-SS-ms_requestId.json`

## Stop Reason Mapping

| OpenAI | Anthropic |
|--------|-----------|
| `stop` | `end_turn` |
| `tool_calls` | `tool_use` |
| `length` | `max_tokens` |
| `content_filter` | `content_filter` |

## Health Check

```bash
curl http://localhost:3000/health
```

Response:
```json
{"status": "ok", "requestId": "..."}
```

## Error Handling

- **400** - Bad request (invalid JSON)
- **401** - Missing API key
- **404** - Not found
- **504** - Upstream timeout
- **500** - Internal server error

All errors include a `requestId` for debugging.

## Notes

- The router strips image content (sends only text to OpenAI endpoints)
- `stop_sequences` are mapped to OpenAI's `stop` parameter
- Authentication header can be `x-api-key` or `authorization`
- Request timeout defaults to 120 seconds
