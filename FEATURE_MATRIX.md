# LiteLLM vs API Map - Feature Matrix

Comprehensive feature comparison between LiteLLM and API Map AI gateway solutions.

> **Last Updated:** 2025-03-27  
> **API Map Providers:** 75+ built-in (verified from source)

## Legend

- ✅ Full support
- ⚠️ Partial support
- ❌ Not supported
- 🔄 In development

## Core Capabilities

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Unified API** | ✅ | ✅ | Both provide single interface for multiple providers |
| **Python SDK** | ✅ | ❌ | LiteLLM: Direct Python integration; API Map: REST API only |
| **Proxy Server** | ✅ | ✅ | Both offer OpenAI-compatible HTTP endpoints |
| **TypeScript SDK** | ❌ | ❌ | Neither provides native TypeScript SDK |
| **Streaming Support** | ✅ | ✅ | Full SSE streaming across compatible providers |
| **Async Support** | ✅ | ✅ | LiteLLM (Python asyncio); API Map (Bun native) |

## Provider Support

### Cloud Providers

| Provider | LiteLLM | API Map | Category |
|----------|:-------:|:-------:|----------|
| **OpenAI** | ✅ | ✅ | Core |
| **Anthropic** | ✅ | ✅ | Core |
| **Google Gemini** | ✅ | ✅ | Core |
| **Azure OpenAI** | ✅ | ✅ | Enterprise |
| **AWS Bedrock** | ✅ | ✅ | Enterprise |
| **Groq** | ✅ | ✅ | Speed |
| **xAI (Grok)** | ✅ | ✅ | Speed |
| **Together AI** | ✅ | ✅ | Open Source |
| **Fireworks AI** | ✅ | ✅ | Speed |
| **Mistral AI** | ✅ | ✅ | Open Source |
| **Cohere** | ✅ | ✅ | Enterprise |
| **DeepSeek** | ✅ | ✅ | Reasoning |
| **Cerebras** | ✅ | ✅ | Speed |
| **SambaNova** | ✅ | ✅ | Hardware |
| **OpenRouter** | ✅ | ✅ | Aggregator |
| **Perplexity** | ✅ | ✅ | Search |
| **AI21 Labs** | ✅ | ✅ | NLP |
| **Replicate** | ✅ | ✅ | ML Platform |
| **Hugging Face** | ✅ | ✅ | Open Source |
| **OctoAI** | ✅ | ✅ | Inference |
| **Anyscale** | ✅ | ✅ | Scaling |
| **NVIDIA NIM** | ✅ | ✅ | Optimized |
| **Cloudflare AI** | ✅ | ✅ | Edge |
| **GitHub Models** | ✅ | ✅ | Free Tier |
| **Databricks** | ✅ | ✅ | Enterprise |
| **Snowflake Cortex** | ✅ | ✅ | Enterprise |
| **Vertex AI** | ✅ | ✅ | Enterprise |
| **SageMaker** | ✅ | ✅ | Enterprise |
| **watsonx.ai** | ✅ | ✅ | Enterprise |
| **+40 more** | ✅ | ✅ | See `src/providers/builtin.ts` |

### Local Providers

| Provider | LiteLLM | API Map | Notes |
|----------|:-------:|:-------:|-------|
| **Ollama** | ✅ | ✅ | Most popular local LLM |
| **LM Studio** | ✅ | ✅ | GUI-based local |
| **llama.cpp** | ✅ | ✅ | Lightweight |
| **vLLM** | ✅ | ✅ | High-throughput |
| **LocalAI** | ✅ | ✅ | Self-hosted API |
| **TabbyAPI** | ✅ | ✅ | ExLlamaV2 |
| **Text Generation WebUI** | ✅ | ✅ | oobabooga |
| **KoboldCpp** | ✅ | ✅ | Roleplay focus |
| **llamafile** | ✅ | ✅ | Single-file |
| **Triton** | ✅ | ✅ | NVIDIA server |

**Total Provider Count:**
- **LiteLLM:** 100+ providers
- **API Map:** 75+ built-in providers (as of 2025-03-27)

## Protocol & Format Support

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **OpenAI Format** | ✅ | ✅ | Native compatibility |
| **Anthropic Format** | ✅ | ✅ | Native compatibility |
| **OpenAI /v1/chat/completions** | ✅ | ✅ | Standard endpoint |
| **OpenAI /v1/completions** | ✅ | ✅ | Legacy endpoint |
| **OpenAI /v1/responses** | ❌ | ✅ | API Map: Responses API |
| **OpenAI /v1/embeddings** | ✅ | ⚠️ | API Map: Partial support |
| **OpenAI /v1/models** | ✅ | ✅ | Model listing |
| **Anthropic /v1/messages** | ✅ | ✅ | Messages API |
| **Protocol Bridging** | ⚠️ | ✅ | API Map: OpenAI ↔ Anthropic conversion |
| **Function Calling** | ✅ | ⚠️ | LiteLLM: Full tool support |
| **JSON Mode** | ✅ | ⚠️ | LiteLLM: Structured output |
| **Vision/Multimodal** | ✅ | ⚠️ | LiteLLM: Image support |

## Routing & Load Balancing

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Basic Routing** | ✅ | ✅ | Route to providers by model |
| **Pattern-Based Routing** | ⚠️ | ✅ | API Map: Wildcards, capture groups |
| **Priority-Based Routing** | ✅ | ✅ | Route precedence |
| **Load Balancing** | ✅ | ❌ | LiteLLM: Multiple strategies |
| **Retry Logic** | ✅ | ⚠️ | LiteLLM: Configurable retries |
| **Fallback/Circuit Breaker** | ✅ | ⚠️ | LiteLLM: Automatic failover |
| **Multi-Region** | ✅ | ❌ | LiteLLM: Geographic routing |

## Management & UI

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Web GUI** | ✅ | ✅ | Both have management interfaces |
| **Configuration UI** | ✅ | ✅ | Visual config editors |
| **YAML Config** | ✅ | ✅ | File-based configuration |
| **Config Validation** | ✅ | ✅ | Syntax checking |
| **Config Backups** | ⚠️ | ✅ | API Map: Auto-backup |
| **Hot Reload** | ✅ | ✅ | Config changes without restart |
| **Request Monitoring** | ✅ | ✅ | Real-time request log |

## Observability

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Request Logging** | ✅ | ✅ | Both log requests/responses |
| **Structured Logging** | ✅ | ✅ | JSON format logs |
| **Real-time Monitoring** | ✅ | ✅ | WebSocket/dashboard |
| **Request Metrics** | ✅ | ✅ | Latency, tokens, etc. |
| **Cost Tracking** | ✅ | ❌ | LiteLLM: Per-request costs |
| **Prometheus Metrics** | ✅ | ⚠️ | LiteLLM: Full metrics export |
| **OpenTelemetry** | ✅ | ❌ | LiteLLM: Distributed tracing |

## Caching & Performance

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Response Caching** | ✅ | ❌ | LiteLLM: Redis caching |
| **Semantic Caching** | ✅ | ❌ | LiteLLM: Similar query cache |
| **Connection Pooling** | ✅ | ✅ | HTTP keep-alive |
| **Request Batching** | ⚠️ | ❌ | LiteLLM: Limited support |

## Security & Guardrails

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **API Key Management** | ✅ | ⚠️ | LiteLLM: Virtual keys |
| **Content Moderation** | ✅ | ❌ | LiteLLM: Guardrails |
| **PII Detection** | ✅ | ❌ | LiteLLM: Data masking |
| **Prompt Injection Detection** | ✅ | ❌ | LiteLLM: Security scanning |

## Advanced Features

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **A2A Protocol** | ✅ | ❌ | LiteLLM: Agent-to-Agent |
| **MCP Tools** | ✅ | ❌ | LiteLLM: Model Context Protocol |
| **Custom Callbacks** | ✅ | ❌ | LiteLLM: Event hooks |
| **Batch Processing** | ✅ | ❌ | LiteLLM: /batches endpoint |

## Deployment Options

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Docker Support** | ✅ | ✅ | Container images |
| **Docker Compose** | ✅ | ✅ | Multi-service setup |
| **Kubernetes** | ✅ | ⚠️ | LiteLLM: Helm charts |
| **Helm Charts** | ✅ | ❌ | LiteLLM: K8s deployment |
| **Cloud Run** | ✅ | ✅ | Serverless deployment |
| **Binary Distribution** | ❌ | ✅ | API Map: Single binary |
| **PyPI Package** | ✅ | ❌ | LiteLLM: pip install |

## Runtime & Performance

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Runtime** | Python | Bun | Different ecosystems |
| **Cold Start** | ~2-3s | ~1s | Bun faster than Python |
| **Memory Usage** | Higher | Lower | Bun vs Python overhead |
| **Base Latency** | ~10-15ms | ~5-10ms | Routing overhead |
| **Max Throughput** | High | High | Provider-limited |

## Summary

### Choose LiteLLM if:
- You need 100+ provider coverage
- Cost tracking and budgeting is critical
- You need advanced routing (load balancing, fallbacks)
- You want a Python SDK
- Caching and guardrails are required
- You're building agent workflows (A2A, MCP)

### Choose API Map if:
- You want pattern-based routing (wildcards)
- Protocol bridging is important (OpenAI ↔ Anthropic)
- You prefer TypeScript/Bun performance
- Real-time WebSocket monitoring is valuable
- You want a modern visual configuration GUI
- 75+ providers cover your needs

## Provider Count by Category

| Category | API Map | LiteLLM |
|----------|:-------:|:-------:|
| Core (OpenAI, Anthropic, Google) | 5 | 5 |
| Major Players (Groq, Together, etc.) | 9 | 10+ |
| Ecosystem/Open Source | 50+ | 50+ |
| Local/On-Premise | 10 | 10 |
| Enterprise (Azure, AWS, GCP) | 9 | 10+ |
| Regional (China, Korea, etc.) | 8 | 8+ |
| **Total** | **75+** | **100+** |

---

*This matrix is auto-generated from source code. For the complete provider list, see `src/providers/builtin.ts`.*
