# LiteLLM vs API Map - Feature Matrix

Comprehensive feature comparison between LiteLLM and API Map AI gateway solutions.

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

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Total Providers** | 100+ | 12+ | LiteLLM has extensive provider coverage |
| **Recently Added (2024-2025)** | | | |
| DeepSeek | ✅ | ✅ | DeepSeek V3, R1 models |
| Groq | ✅ | ✅ | Ultra-fast inference (LPU) |
| xAI (Grok) | ✅ | ❌ | Elon Musk's xAI models |
| Perplexity | ✅ | ⚠️ | API Map: Via OpenAI-compatible |
| Cerebras | ✅ | ❌ | Cerebras AI inference |
| SambaNova | ✅ | ❌ | SambaNova Systems |
| Azure AI Foundry | ✅ | ❌ | Microsoft's unified AI platform |
| Amazon Nova | ✅ | ⚠️ | Amazon's new model family |
| OpenAI | ✅ | ✅ | Native support |
| Anthropic | ✅ | ✅ | Native support |
| Azure OpenAI | ✅ | ⚠️ | API Map: Via OpenAI-compatible |
| Google Gemini | ✅ | ✅ | Full support |
| AWS Bedrock | ✅ | ⚠️ | API Map: Limited support |
| Cohere | ✅ | ✅ | Full support |
| Groq | ✅ | ✅ | Full support |
| Mistral | ✅ | ✅ | Full support |
| Together AI | ✅ | ✅ | Full support |
| Fireworks AI | ✅ | ✅ | Full support |
| DeepSeek | ✅ | ✅ | Full support |
| OpenRouter | ✅ | ✅ | Full support |
| Ollama (Local) | ✅ | ✅ | Local model support |
| LM Studio | ✅ | ✅ | Local model support |
| llama.cpp | ✅ | ✅ | Local model support |
| vLLM | ✅ | ✅ | Local model support |
| HuggingFace | ✅ | ❌ | LiteLLM only |
| Sagemaker | ✅ | ❌ | LiteLLM only |
| Vertex AI | ✅ | ❌ | LiteLLM only |
| AI21 | ✅ | ❌ | LiteLLM only |
| Baseten | ✅ | ❌ | LiteLLM only |
| Cloudflare AI | ✅ | ❌ | LiteLLM only |
| NLP Cloud | ✅ | ❌ | LiteLLM only |
| Petals | ✅ | ❌ | LiteLLM only |
| Replicate | ✅ | ❌ | LiteLLM only |
| Palm | ✅ | ❌ | LiteLLM only |

## Protocol & Format Support

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **OpenAI Format** | ✅ | ✅ | Native compatibility |
| **Anthropic Format** | ✅ | ✅ | Native compatibility |
| **OpenAI /v1/chat/completions** | ✅ | ✅ | Standard endpoint |
| **OpenAI /v1/completions** | ✅ | ✅ | Legacy endpoint |
| **OpenAI /v1/embeddings** | ✅ | ⚠️ | API Map: Partial support |
| **OpenAI /v1/models** | ✅ | ✅ | Model listing |
| **Anthropic /v1/messages** | ✅ | ✅ | Messages API |
| **Protocol Bridging** | ⚠️ | ✅ | API Map: Format conversion between providers |
| **Function Calling** | ✅ | ⚠️ | LiteLLM: Full tool support |
| **JSON Mode** | ✅ | ⚠️ | LiteLLM: Structured output |
| **Vision/Multimodal** | ✅ | ⚠️ | LiteLLM: Image support |

## Routing & Load Balancing

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Basic Routing** | ✅ | ✅ | Route to providers by model |
| **Pattern-Based Routing** | ⚠️ | ✅ | API Map: Wildcards, capture groups |
| **Priority-Based Routing** | ✅ | ✅ | Route precedence |
| **Load Balancing** | ✅ | ❌ | LiteLLM: Multiple strategies (see below) |
| **Retry Logic** | ✅ | ⚠️ | LiteLLM: Configurable retries with backoff |
| **Fallback/Circuit Breaker** | ✅ | ⚠️ | LiteLLM: Automatic failover |
| **Multi-Region** | ✅ | ❌ | LiteLLM: Geographic routing |
| **Custom Routing Rules** | ✅ | ⚠️ | LiteLLM: Advanced conditions |
| **Router Strategies** | | | |
| Simple Shuffle | ✅ | ❌ | Round-robin across deployments |
| Least Busy | ✅ | ❌ | Route to least loaded instance |
| Latency-Based | ✅ | ❌ | Dynamic based on response times |
| Cost-Based | ✅ | ❌ | Route to cheapest available |
| Rate-Limit Aware | ✅ | ❌ | Respect TPM/RPM limits |
| Content-Based | ✅ | ❌ | Route based on prompt content |

## Management & UI

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Web GUI** | ✅ | ✅ | Both have management interfaces |
| **Configuration UI** | ✅ | ✅ | Visual config editors |
| **YAML Config** | ✅ | ✅ | File-based configuration |
| **Config Validation** | ✅ | ✅ | Syntax checking |
| **Config Backups** | ⚠️ | ✅ | API Map: Auto-backup |
| **Hot Reload** | ✅ | ✅ | Config changes without restart |
| **API Management** | ✅ | ⚠️ | LiteLLM: Virtual keys, budgets |
| **Rate Limiting** | ✅ | ⚠️ | LiteLLM: Per-key limits |
| **Usage Quotas** | ✅ | ❌ | LiteLLM: Token/spend limits |
| **Team Management** | ✅ | ❌ | LiteLLM: Multi-tenancy |
| **SSO/SAML** | ✅ | ❌ | LiteLLM Enterprise: Auth integration |

## Observability

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Request Logging** | ✅ | ✅ | Both log requests/responses |
| **Structured Logging** | ✅ | ✅ | JSON format logs |
| **Log Filtering** | ✅ | ✅ | Exclude sensitive data |
| **Real-time Monitoring** | ✅ | ✅ | WebSocket/dashboard |
| **Request Metrics** | ✅ | ✅ | Latency, tokens, etc. |
| **Cost Tracking** | ✅ | ❌ | LiteLLM: Per-request costs (see below) |
| **Budget Alerts** | ✅ | ❌ | LiteLLM: Spend notifications |
| **Spend Reports** | ✅ | ❌ | LiteLLM: Usage analytics |
| **Team/Key Budgets** | ✅ | ❌ | LiteLLM: Per-key spending limits |
| **Prometheus Metrics** | ✅ | ⚠️ | LiteLLM: Full metrics export |
| **OpenTelemetry** | ✅ | ❌ | LiteLLM: Distributed tracing |
| **Langfuse Integration** | ✅ | ❌ | LiteLLM: LLM observability |
| **Langsmith Integration** | ✅ | ❌ | LiteLLM: LangChain tracing |
| **Weights & Biases** | ✅ | ❌ | LiteLLM: Experiment tracking |
| **Sentry Integration** | ✅ | ❌ | LiteLLM: Error tracking |

## Caching & Performance

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Response Caching** | ✅ | ❌ | LiteLLM: Redis caching |
| **Semantic Caching** | ✅ | ❌ | LiteLLM: Similar query cache |
| **Cache TTL Control** | ✅ | ❌ | LiteLLM: Expiration settings |
| **Cache Invalidation** | ✅ | ❌ | LiteLLM: Manual/API clear |
| **Connection Pooling** | ✅ | ✅ | HTTP keep-alive |
| **Request Batching** | ⚠️ | ❌ | LiteLLM: Limited support |

## Security & Guardrails

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **API Key Management** | ✅ | ⚠️ | LiteLLM: Virtual keys |
| **Key Rotation** | ✅ | ❌ | LiteLLM: Automatic rotation |
| **Content Moderation** | ✅ | ❌ | LiteLLM: Guardrails |
| **PII Detection** | ✅ | ❌ | LiteLLM: Data masking |
| **Prompt Injection Detection** | ✅ | ❌ | LiteLLM: Security scanning |
| **Regex Filtering** | ✅ | ❌ | LiteLLM: Pattern blocking |
| **Request Sanitization** | ✅ | ⚠️ | LiteLLM: Input validation |
| **Secret Detection** | ✅ | ❌ | LiteLLM: Leak prevention |
| **IP Whitelist/Blacklist** | ⚠️ | ❌ | Via external proxy |
| **Audit Logging** | ✅ | ⚠️ | LiteLLM: Compliance logs |

## Advanced Features

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **A2A Protocol** | ✅ | ❌ | LiteLLM: Agent-to-Agent |
| **MCP Tools** | ✅ | ❌ | LiteLLM: Model Context Protocol |
| **Custom Callbacks** | ✅ | ❌ | LiteLLM: Event hooks |
| **Pre/Post Processing** | ✅ | ❌ | LiteLLM: Request/response modifiers |
| **Prompt Templates** | ✅ | ❌ | LiteLLM: Templated prompts |
| **Dynamic Prompts** | ✅ | ❌ | LiteLLM: Variable substitution |
| **Batch Processing** | ✅ | ❌ | LiteLLM: /batches endpoint |
| **Fine-tuning API** | ⚠️ | ❌ | LiteLLM: Limited support |
| **Assistant API** | ⚠️ | ❌ | LiteLLM: OpenAI compatible |

## Deployment Options

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Docker Support** | ✅ | ✅ | Container images |
| **Docker Compose** | ✅ | ✅ | Multi-service setup |
| **Kubernetes** | ✅ | ⚠️ | LiteLLM: Helm charts |
| **Helm Charts** | ✅ | ❌ | LiteLLM: K8s deployment |
| **Cloud Run** | ✅ | ✅ | Serverless deployment |
| **AWS ECS/Fargate** | ✅ | ⚠️ | LiteLLM: CloudFormation |
| **AWS Lambda** | ⚠️ | ⚠️ | LiteLLM: Adapter available |
| **Vercel** | ❌ | ⚠️ | API Map: Edge deployment |
| **Systemd Service** | ✅ | ✅ | Linux service files |
| **Binary Distribution** | ❌ | ✅ | API Map: Single binary |
| **PyPI Package** | ✅ | ❌ | LiteLLM: pip install |
| **npm Package** | ❌ | ❌ | Neither on npm |

## Development & Extensibility

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Open Source** | ✅ | ✅ | MIT License |
| **GitHub Stars** | ~10k+ | ~100+ | Community size |
| **Active Development** | ✅ | ✅ | Regular updates |
| **Plugin System** | ⚠️ | ❌ | LiteLLM: Callbacks |
| **Custom Providers** | ✅ | ✅ | Add new backends |
| **Custom Middleware** | ✅ | ⚠️ | LiteLLM: Python hooks |
| **REST API** | ✅ | ✅ | HTTP management API |
| **WebSocket API** | ✅ | ✅ | Real-time updates |
| **gRPC Support** | ❌ | ❌ | Not available |
| **GraphQL Support** | ❌ | ❌ | Not available |

## Documentation & Support

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Documentation** | ✅ | ✅ | Comprehensive docs |
| **API Reference** | ✅ | ✅ | OpenAPI/Swagger |
| **Code Examples** | ✅ | ✅ | Usage samples |
| **Video Tutorials** | ✅ | ❌ | LiteLLM: YouTube content |
| **Community Discord** | ✅ | ❌ | LiteLLM: Active community |
| **GitHub Issues** | ✅ | ✅ | Bug reports |
| **GitHub Discussions** | ✅ | ✅ | Q&A forum |
| **Enterprise Support** | ✅ | ❌ | LiteLLM: Paid plans |
| **SLA Guarantees** | ✅ | ❌ | LiteLLM Enterprise |
| **Custom Development** | ✅ | ❌ | LiteLLM: Consulting |

## Runtime & Performance

| Feature | LiteLLM | API Map | Notes |
|---------|:-------:|:-------:|-------|
| **Runtime** | Python | Bun | Different ecosystems |
| **Cold Start** | ~2-3s | ~1s | Bun faster than Python |
| **Memory Usage** | Higher | Lower | Bun vs Python overhead |
| **Base Latency** | ~10-15ms | ~5-10ms | Routing overhead |
| **Concurrent Requests** | High | High | Both handle 100+ |
| **Max Throughput** | High | High | Provider-limited |
| **Streaming Latency** | Low | Low | Efficient SSE |

## Summary

### LiteLLM Strengths
1. **100+ Provider Support** - Extensive ecosystem coverage
2. **Enterprise Features** - Cost tracking, guardrails, SSO
3. **Python SDK** - Direct library integration
4. **Advanced Routing** - Load balancing, fallbacks, retries
5. **Observability** - Comprehensive logging and metrics
6. **Caching** - Redis-based response caching
7. **A2A/MCP** - Agent and tool protocol support

### API Map Strengths
1. **Pattern Routing** - Wildcard and capture group patterns
2. **Protocol Bridging** - Convert between API formats
3. **Performance** - Bun runtime, lower latency
4. **GUI** - Modern SvelteKit interface
5. **Simplicity** - Easy to configure and deploy
6. **TypeScript** - Type-safe codebase
7. **Real-time** - WebSocket monitoring

### Use Case Recommendations

**Choose LiteLLM if:**
- You need extensive provider support (100+)
- You're building enterprise applications
- Cost tracking and budgeting is critical
- You need advanced routing (load balancing, fallbacks)
- You want a Python SDK for direct integration
- Caching and guardrails are required
- You're building agent workflows (A2A, MCP)

**Choose API Map if:**
- You want simple pattern-based routing
- Protocol bridging is important (OpenAI ↔ Anthropic)
- You prefer TypeScript/Bun performance
- Real-time monitoring is valuable
- You want a modern visual configuration GUI
- Docker-first deployment is preferred
- You need quick local model integration

## Advanced Routing Logic in LiteLLM

LiteLLM's routing system goes far beyond simple model-to-provider mapping. Here's how it works:

### 1. **Router Strategies**

LiteLLM supports multiple routing algorithms selectable via `routing_strategy`:

| Strategy | Description | Use Case |
|----------|-------------|----------|
| `simple-shuffle` | Round-robin across model deployments | Basic load distribution |
| `least-busy` | Routes to deployment with lowest active requests | Avoiding hot spots |
| `latency-based-routing` | Tracks P50 latency per deployment, routes to fastest | Performance optimization |
| `cost-based-routing` | Routes to cheapest available provider | Cost optimization |
| `usage-based-routing` | Considers token usage patterns | Balanced throughput |

### 2. **Fallback Logic**

```yaml
router_settings:
  fallbacks: [
    {"gpt-4": ["gpt-4-turbo", "claude-3-opus", "gpt-3.5-turbo"]}
  ]
  context_window_fallbacks: [
    {"gpt-3.5-turbo": ["gpt-3.5-turbo-16k", "gpt-4"]}
  ]
  content_policy_fallbacks: [
    {"claude-3-opus": ["gpt-4"]}
  ]
```

**Fallback Types:**
- **Model Fallbacks**: If primary model fails, try alternatives in order
- **Context Window Fallbacks**: Auto-upgrade to larger context model if prompt too long
- **Content Policy Fallbacks**: Route to different provider if content blocked

### 3. **Retry Configuration**

```yaml
router_settings:
  num_retries: 3
  timeout: 30
  retry_after: 1  # seconds between retries
  allowed_fails: 3  # Circuit breaker threshold
  cooldown_time: 60  # Seconds before retrying a failed deployment
```

**Retry Behavior:**
- Exponential backoff with jitter
- Circuit breaker pattern (stops sending to failing deployments)
- Automatic cooldown and recovery

### 4. **Rate Limit Management**

LiteLLM tracks per-deployment rate limits:
- **TPM** (Tokens Per Minute)
- **RPM** (Requests Per Minute)

```yaml
model_list:
  - model_name: gpt-4
    litellm_params:
      model: openai/gpt-4
      rpm: 200
      tpm: 40000
```

The router automatically queues or redirects when limits are approached.

### 5. **Multi-Region Routing**

```yaml
model_list:
  - model_name: gpt-4-us
    litellm_params:
      model: openai/gpt-4
      api_base: https://us-east-1.api.openai.com
  - model_name: gpt-4-eu
    litellm_params:
      model: openai/gpt-4
      api_base: https://eu-west-1.api.openai.com
```

Route to geographically closest healthy deployment.

---

## Cost Tracking in LiteLLM

LiteLLM provides enterprise-grade cost tracking through its built-in spend monitoring system:

### 1. **How Cost Tracking Works**

```python
# LiteLLM uses provider pricing tables + token counts
import litellm

# Every completion automatically calculates cost
response = litellm.completion(
    model="gpt-4",
    messages=[{"role": "user", "content": "Hello"}]
)

# Access cost from response
print(response._hidden_params["response_cost"])  # e.g., 0.003
```

**Calculation Method:**
- **Input cost**: `prompt_tokens × input_price_per_token`
- **Output cost**: `completion_tokens × output_price_per_token`
- **Total**: Sum of both + any markup

### 2. **Pricing Configuration**

LiteLLM maintains an internal database of model pricing:

| Model | Input (per 1M tokens) | Output (per 1M tokens) |
|-------|----------------------|------------------------|
| GPT-4o | $2.50 | $10.00 |
| GPT-4o-mini | $0.15 | $0.60 |
| Claude 3 Opus | $15.00 | $75.00 |
| Claude 3 Haiku | $0.25 | $1.25 |

**Custom Pricing:**
```yaml
litellm_settings:
  success_callback: ["prometheus"]
  custom_pricing:
    "azure/gpt-4":
      input_cost_per_token: 0.00003
      output_cost_per_token: 0.00006
```

### 3. **Budget Management**

```yaml
general_settings:
  # Global budget
  max_budget: 1000.00  # Stop after $1000
  
# Per-key budgets
model_list:
  - model_name: gpt-4
    litellm_params:
      model: openai/gpt-4
      max_budget: 100  # $100 limit for this key
```

**Budget Features:**
- **Soft limits**: Warnings at thresholds
- **Hard limits**: Request rejection when exceeded
- **Time windows**: Daily/weekly/monthly budgets
- **Team budgets**: Organization-level spend controls

### 4. **Spend Tracking Database**

LiteLLM stores all spend data for analytics:

```sql
-- View spend by model
SELECT 
  model,
  SUM(spend) as total_spend,
  COUNT(*) as request_count
FROM spend_logs
WHERE startTime > NOW() - INTERVAL '7 days'
GROUP BY model;
```

**Tracked Metadata:**
- User ID / API key
- Team/Organization
- Model used
- Token counts
- Timestamp
- Cache hit/miss status

### 5. **Real-Time Alerts**

```yaml
general_settings:
  alert_settings:
    budget_alerts: true
    threshold: 0.8  # Alert at 80% of budget
    webhook_url: "https://hooks.slack.com/..."
```

**Alert Types:**
- Budget threshold reached
- Unusual spend spikes
- Failed request rate increase
- Latency degradation

### 6. **Cost Optimization Features**

| Feature | Description |
|---------|-------------|
| **Caching** | Return cached responses (Redis) - zero cost |
| **Cost-based routing** | Automatically use cheapest capable model |
| **Model downgrade** | Fallback to cheaper models for non-critical requests |
| **Batching** | Group requests for better throughput |
| **Spend reports** | Daily/weekly email summaries |

---

## Last Updated

2024-03-27
