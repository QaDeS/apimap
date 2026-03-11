# API Map - The LLM BabelFish

> **Complete provider and endpoint coverage for universal LLM API translation**

This document catalogs all major LLM API providers, their endpoints, formats, and transformation requirements. The goal: any client can speak any format to any provider.

---

## Provider Categories

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PROVIDER ECOSYSTEM                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│  ☁️ CLOUD APIs          │  🏠 LOCAL APIs          │  🔌 ENTERPRISE          │
│  - OpenAI               │  - Ollama               │  - Azure OpenAI         │
│  - Anthropic            │  - LM Studio            │  - AWS Bedrock          │
│  - Google Gemini        │  - llama.cpp            │  - GCP Vertex AI        │
│  - Groq                 │  - vLLM                 │  - IBM watsonx          │
│  - Together AI          │  - LocalAI              │  - Oracle Cloud         │
│  - Fireworks            │  - TabbyAPI             │  - Alibaba Cloud        │
│  - DeepSeek             │  - Text Generation WebUI│  - Baidu ERNIE          │
│  - Mistral AI           │  - kobold.cpp           │  - Tencent Hunyuan      │
│  - Cohere               │  - ExLlamaV2            │  - Yandex GPT           │
│  - AI21 Labs            │                         │  - Naver HyperCLOVA     │
│  - OpenRouter           │                         │                         │
│  - Perplexity           │                         │                         │
│  - Anyscale             │                         │                         │
│  - Replicate            │                         │                         │
│  - Hugging Face         │                         │                         │
│  - OctoAI               │                         │                         │
│  - Baseten              │                         │                         │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## ☁️ Cloud Providers

### OpenAI

**Base URL:** `https://api.openai.com/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI Chat | ✅ | Critical |
| `/completions` | POST | OpenAI Legacy | ✅ | High |
| `/responses` | POST | OpenAI Responses | ✅ | Critical |
| `/embeddings` | POST | OpenAI Embeddings | ❌ | High |
| `/images/generations` | POST | DALL-E | ❌ | Medium |
| `/audio/transcriptions` | POST | Whisper | ❌ | Medium |
| `/audio/speech` | POST | TTS | ✅ | Medium |
| `/assistants` | CRUD | Assistants API | ❌ | Low |
| `/threads` | CRUD | Assistants API | ❌ | Low |
| `/batches` | CRUD | Batch API | ❌ | Medium |
| `/fine_tuning/jobs` | CRUD | Fine-tuning | ❌ | Low |
| `/models` | GET | Model list | ❌ | Critical |
| `/moderations` | POST | Moderation | ❌ | Low |

**Unique Features:**
- Function calling with `tools`/`tool_choice`
- JSON mode via `response_format: { type: "json_object" }`
- Structured outputs via `response_format` with schema
- Seed for reproducibility
- Logprobs
- Predicted outputs (new)

---

### Anthropic

**Base URL:** `https://api.anthropic.com`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/v1/messages` | POST | Anthropic Messages | ✅ | Critical |
| `/v1/messages/count_tokens` | POST | Token counting | ❌ | High |
| `/v1/models` | GET | Model list | ❌ | Critical |
| `/v1/completions` | POST | Legacy (deprecated) | ✅ | Low |

**Unique Features:**
- Tool use with `tools` block type
- Computer use beta
- Extended thinking / reasoning
- Citations (beta)
- PDF support
- Maximum output tokens up to 128K

**Format Differences from OpenAI:**
- `max_tokens` → required (not optional)
- `system` → top-level field, not message
- `stop_sequences` → array vs `stop`
- Tools use `input_schema` vs `parameters`
- Content blocks: `text`, `image`, `tool_use`, `tool_result`

---

### Google Gemini / Vertex AI

**Base URL:** `https://generativelanguage.googleapis.com/v1beta` (Gemini)

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/models/{model}:generateContent` | POST | Gemini | ❌ | Critical |
| `/models/{model}:streamGenerateContent` | POST | Gemini | ✅ | Critical |
| `/models/{model}:countTokens` | POST | Token counting | ❌ | High |
| `/models/{model}:embedContent` | POST | Embeddings | ❌ | High |
| `/models` | GET | Model list | ❌ | Critical |
| `/cachedContents` | CRUD | Context caching | ❌ | Medium |
| `/files` | CRUD | File API | ❌ | Medium |

**Unique Features:**
- Native multimodal (text, image, video, audio in one request)
- Context caching for long documents
- Grounding with Google Search
- Code execution
- Function calling (different format)
- System instructions as `systemInstruction` field

**Format Considerations:**
- Parts-based content structure
- Separate `generationConfig` object
- Safety settings as array

---

### Groq

**Base URL:** `https://api.groq.com/openai/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | High |
| `/completions` | POST | OpenAI-compatible | ✅ | Medium |
| `/embeddings` | POST | OpenAI-compatible | ❌ | Medium |
| `/audio/transcriptions` | POST | Whisper-compatible | ❌ | Medium |
| `/models` | GET | OpenAI-compatible | ❌ | High |
| `/batches` | POST | Batch API | ❌ | Low |

**Unique Features:**
- Extremely fast inference
- Native tool use support
- Parallel tool calling
- Speculative decoding

---

### Together AI

**Base URL:** `https://api.together.xyz/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | High |
| `/completions` | POST | OpenAI-compatible | ✅ | Medium |
| `/images/generations` | POST | Image generation | ❌ | Medium |
| `/embeddings` | POST | OpenAI-compatible | ❌ | Medium |
| `/models` | GET | OpenAI-compatible | ❌ | High |

**Unique Features:**
- JSON mode via `response_format`
- Tool calling support
- Image generation (Flux, Stable Diffusion)

---

### Fireworks AI

**Base URL:** `https://api.fireworks.ai/inference/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | High |
| `/completions` | POST | OpenAI-compatible | ✅ | Medium |
| `/embeddings` | POST | OpenAI-compatible | ❌ | Medium |
| `/image_generation` | POST | Image generation | ❌ | Low |
| `/models` | GET | OpenAI-compatible | ❌ | High |

---

### Mistral AI

**Base URL:** `https://api.mistral.ai/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | High |
| `/completions` | POST | OpenAI-compatible | ✅ | Medium |
| `/embeddings` | POST | OpenAI-compatible | ❌ | Medium |
| `/agents/completions` | POST | Agent API | ✅ | Medium |
| `/models` | GET | OpenAI-compatible | ❌ | High |

**Unique Features:**
- Agents API for RAG
- Moderation API
- Fine-tuning API

---

### Cohere

**Base URL:** `https://api.cohere.ai/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat` | POST | Cohere Chat | ✅ | High |
| `/generate` | POST | Cohere Generate | ✅ | Medium |
| `/embed` | POST | Cohere Embeddings | ❌ | Medium |
| `/rerank` | POST | Reranking | ❌ | Medium |
| `/summarize` | POST | Summarization | ❌ | Low |
| `/classify` | POST | Classification | ❌ | Low |
| `/tokenize` | POST | Tokenization | ❌ | Low |
| `/detokenize` | POST | Detokenization | ❌ | Low |
| `/models` | GET | Model list | ❌ | High |

**Unique Features:**
- Chat history in `chat_history` field
- Connectors for RAG
- Documents for grounding
- Search queries for tool use

---

### AI21 Labs

**Base URL:** `https://api.ai21.com/studio/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | Medium |
| `/summarize` | POST | Summarization | ❌ | Low |
| `/gec` | POST | Grammar correction | ❌ | Low |
| `/answer` | POST | QA | ❌ | Low |
| `/embed` | POST | Embeddings | ❌ | Medium |
| `/paraphrase` | POST | Paraphrasing | ❌ | Low |
| `/segmentation` | POST | Text segmentation | ❌ | Low |
| `/library` | CRUD | RAG library | ❌ | Low |

---

### DeepSeek

**Base URL:** `https://api.deepseek.com`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | High |
| `/models` | GET | OpenAI-compatible | ❌ | High |

**Unique Features:**
- Reasoning model with chain-of-thought
- FIM (Fill-in-the-middle) completion

---

### OpenRouter

**Base URL:** `https://openrouter.ai/api/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | High |
| `/completions` | POST | OpenAI-compatible | ✅ | Medium |
| `/models` | GET | OpenAI-compatible | ❌ | High |
| `/generation` | GET | Generation info | ❌ | Low |

**Unique Features:**
- Model routing by OpenRouter
- Provider selection headers
- Fallback models header
- Transformations header

---

### Perplexity

**Base URL:** `https://api.perplexity.ai`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | High |
| `/models` | GET | OpenAI-compatible | ❌ | High |

**Unique Features:**
- Citations in response
- Search mode
- Related questions

---

### Replicate

**Base URL:** `https://api.replicate.com/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/predictions` | POST | Replicate | ✅ | Medium |
| `/models/{owner}/{name}/predictions` | POST | Replicate | ✅ | Medium |
| `/predictions/{id}` | GET | Status | ❌ | Medium |

**Format Considerations:**
- Async by default
- Webhook callbacks
- Different request/response structure

---

### Hugging Face Inference API

**Base URL:** `https://api-inference.huggingface.co`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/models/{model}` | POST | HF Inference | ✅ | Medium |
| `/pipeline/{task}/{model}` | POST | Pipeline | ❌ | Medium |

**Unique Features:**
- Thousands of models
- Text, image, audio, multimodal
- Hosted inference endpoints

---

### OctoAI

**Base URL:** `https://text.octoai.run/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | Medium |
| `/completions` | POST | OpenAI-compatible | ✅ | Low |
| `/health` | GET | Health check | ❌ | Low |

---

### Anyscale

**Base URL:** `https://api.endpoints.anyscale.com/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | Medium |
| `/completions` | POST | OpenAI-compatible | ✅ | Low |
| `/embeddings` | POST | OpenAI-compatible | ❌ | Medium |
| `/fine_tuning` | POST | Fine-tuning | ❌ | Low |

---

### Baseten

**Base URL:** `https://model-{model_id}.api.baseten.co/production`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/predict` | POST | Baseten | ✅ | Low |
| `/status/{request_id}` | GET | Status | ❌ | Low |

---

## 🏠 Local Providers

### Ollama

**Base URL:** `http://localhost:11434`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/api/chat` | POST | Ollama Chat | ✅ | Critical |
| `/api/generate` | POST | Ollama Generate | ✅ | High |
| `/api/embed` | POST | Ollama Embeddings | ❌ | High |
| `/api/tags` | GET | Model list | ❌ | Critical |
| `/api/show` | POST | Model info | ❌ | Medium |
| `/api/create` | POST | Create model | ❌ | Low |
| `/api/copy` | POST | Copy model | ❌ | Low |
| `/api/delete` | DELETE | Delete model | ❌ | Low |
| `/api/pull` | POST | Pull model | ✅ | Low |
| `/api/push` | POST | Push model | ✅ | Low |
| `/api/ps` | GET | Running models | ❌ | Medium |

**Unique Features:**
- Modelfiles for customization
- Pull/push models from registry
- Multi-modal support

---

### LM Studio

**Base URL:** `http://localhost:1234/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | Critical |
| `/completions` | POST | OpenAI-compatible | ✅ | High |
| `/embeddings` | POST | OpenAI-compatible | ❌ | Medium |
| `/models` | GET | OpenAI-compatible | ❌ | Critical |

---

### llama.cpp Server

**Base URL:** `http://localhost:8080`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/completion` | POST | llama.cpp | ✅ | Critical |
| `/v1/chat/completions` | POST | OpenAI-compatible | ✅ | High |
| `/v1/completions` | POST | OpenAI-compatible | ✅ | Medium |
| `/v1/embeddings` | POST | OpenAI-compatible | ❌ | Medium |
| `/v1/models` | GET | OpenAI-compatible | ❌ | High |
| `/tokenize` | POST | Tokenization | ❌ | Low |
| `/detokenize` | POST | Detokenization | ❌ | Low |
| `/props` | GET | Model properties | ❌ | Low |
| `/health` | GET | Health | ❌ | Medium |
| `/slots` | GET | Slot info | ❌ | Low |

**Unique Features:**
- Slot-based continuous batching
- KV cache management
- Grammar/constrained sampling
- System prompt caching

---

### vLLM

**Base URL:** `http://localhost:8000/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | Critical |
| `/completions` | POST | OpenAI-compatible | ✅ | High |
| `/embeddings` | POST | OpenAI-compatible | ❌ | Medium |
| `/models` | GET | OpenAI-compatible | ❌ | Critical |

**Unique Features:**
- PagedAttention for efficient serving
- Tensor parallelism
- Pipeline parallelism
- Speculative decoding
- Prefix caching

---

### LocalAI

**Base URL:** `http://localhost:8080/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | High |
| `/completions` | POST | OpenAI-compatible | ✅ | High |
| `/embeddings` | POST | OpenAI-compatible | ❌ | Medium |
| `/models` | GET | OpenAI-compatible | ❌ | High |
| `/images/generations` | POST | Image gen | ❌ | Medium |
| `/audio/transcriptions` | POST | Transcription | ❌ | Medium |
| `/tts` | POST | TTS | ❌ | Medium |

**Unique Features:**
- Drop-in OpenAI replacement
- Multiple backends (llama.cpp, transformers, diffusers)
- Gallery of pre-configured models

---

### TabbyAPI

**Base URL:** `http://localhost:5000/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | Medium |
| `/completions` | POST | OpenAI-compatible | ✅ | Medium |
| `/models` | GET | OpenAI-compatible | ❌ | Medium |

**Unique Features:**
- ExLlamaV2 optimized backend
- CFG (Classifier Free Guidance)
- Draft model support

---

### Text Generation WebUI (oobabooga)

**Base URL:** `http://localhost:5000`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/v1/chat/completions` | POST | OpenAI-compatible | ✅ | Medium |
| `/v1/completions` | POST | OpenAI-compatible | ✅ | Medium |
| `/v1/models` | GET | OpenAI-compatible | ❌ | Medium |

---

### kobold.cpp

**Base URL:** `http://localhost:5001`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/api/v1/generate` | POST | Kobold | ✅ | Low |
| `/api/v1/stream` | POST | Kobold | ✅ | Low |
| `/api/extra/generate/stream` | POST | Kobold SSE | ✅ | Low |
| `/api/v1/model` | GET | Model info | ❌ | Low |

---

## 🔌 Enterprise Providers

### Azure OpenAI

**Base URL:** `https://{resource}.openai.azure.com/openai/deployments/{deployment}`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | OpenAI-compatible | ✅ | Critical |
| `/completions` | POST | OpenAI-compatible | ✅ | High |
| `/embeddings` | POST | OpenAI-compatible | ❌ | High |
| `/images/generations` | POST | DALL-E | ❌ | Medium |
| `/audio/transcriptions` | POST | Whisper | ❌ | Medium |
| `/audio/speech` | POST | TTS | ❌ | Medium |

**Authentication:** API key + Endpoint URL (different from OpenAI)

---

### AWS Bedrock

**Base URL:** `https://bedrock-runtime.{region}.amazonaws.com`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/model/{modelId}/invoke` | POST | Bedrock | ❌ | Critical |
| `/model/{modelId}/invoke-with-response-stream` | POST | Bedrock | ✅ | Critical |
| `/model/{modelId}/converse` | POST | Converse API | ❌ | High |
| `/model/{modelId}/converse-stream` | POST | Converse API | ✅ | High |

**Models Supported:**
- Amazon Titan
- Anthropic Claude
- AI21 Jurassic
- Cohere Command
- Meta Llama
- Mistral
- Stability AI

**Authentication:** AWS Signature V4

---

### Google Vertex AI

**Base URL:** `https://{region}-aiplatform.googleapis.com/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/projects/{project}/locations/{location}/publishers/google/models/{model}:predict` | POST | Vertex | ❌ | Critical |
| `/projects/{project}/locations/{location}/publishers/google/models/{model}:serverStreamingPredict` | POST | Vertex | ✅ | Critical |
| `/projects/{project}/locations/{location}/publishers/google/models/{model}:generateContent` | POST | Gemini | ❌ | Critical |
| `/projects/{project}/locations/{location}/publishers/google/models/{model}:streamGenerateContent` | POST | Gemini | ✅ | Critical |

**Authentication:** GCP Service Account

---

### IBM watsonx.ai

**Base URL:** `https://{region}.ml.cloud.ibm.com`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/ml/v1/text/generation` | POST | watsonx | ❌ | Low |
| `/ml/v1/text/generation_stream` | POST | watsonx | ✅ | Low |
| `/ml/v1/text/chat` | POST | watsonx Chat | ❌ | Low |
| `/ml/v1/text/chat_stream` | POST | watsonx Chat | ✅ | Low |
| `/ml/v1/text/embeddings` | POST | Embeddings | ❌ | Low |

---

### Oracle Cloud Generative AI

**Base URL:** `https://generativeai.{region}.oci.oraclecloud.com`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/20231130/actions/chat` | POST | OCI | ❌ | Low |
| `/20231130/actions/generateText` | POST | OCI | ❌ | Low |
| `/20231130/actions/summarizeText` | POST | OCI | ❌ | Low |

---

## 🌏 Regional Providers

### Alibaba Cloud (Qwen)

**Base URL:** `https://dashscope.aliyuncs.com/api/v1`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/services/aigc/text-generation/generation` | POST | DashScope | ✅ | Medium |
| `/services/embeddings/text-embedding/text-embedding` | POST | Embeddings | ❌ | Low |

---

### Baidu (ERNIE Bot)

**Base URL:** `https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/chat/completions` | POST | ERNIE | ✅ | Low |
| `/completions` | POST | ERNIE | ✅ | Low |
| `/embeddings` | POST | Embeddings | ❌ | Low |

---

### Tencent (Hunyuan)

**Base URL:** `https://hunyuan.tencentcloudapi.com`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/` | POST | Hunyuan | ✅ | Low |

---

### Yandex GPT

**Base URL:** `https://llm.api.cloud.yandex.net`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/foundationModels/v1/completion` | POST | Yandex | ❌ | Low |
| `/foundationModels/v1/completionAsync` | POST | Yandex | ❌ | Low |
| `/foundationModels/v1/tokenizeCompletion` | POST | Tokenize | ❌ | Low |

---

### Naver HyperCLOVA X

**Base URL:** `https://clovastudio.stream.ntruss.com`

| Endpoint | Method | Format | Streaming | Priority |
|----------|--------|--------|-----------|----------|
| `/testapp/v1/chat-completions/{model}` | POST | HyperCLOVA | ✅ | Low |
| `/testapp/v1/completions/{model}` | POST | HyperCLOVA | ✅ | Low |

---

## 📝 Format Transformation Matrix

### Chat Completions

| From ↓ \ To → | OpenAI | Anthropic | Gemini | Cohere | Bedrock |
|---------------|--------|-----------|--------|--------|---------|
| **OpenAI** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Anthropic** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Gemini** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Cohere** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Bedrock** | ✅ | ✅ | ✅ | ✅ | ✅ |

### Key Transformation Challenges

1. **Message Format**
   - OpenAI: `{role, content}` array
   - Anthropic: `{role, content}` with content blocks
   - Gemini: `parts` array with type discrimination
   - Cohere: `chat_history` + `message` structure

2. **System Messages**
   - OpenAI: First message with `role: "system"`
   - Anthropic: Top-level `system` string
   - Gemini: `systemInstruction` field
   - Cohere: `preamble` field

3. **Tool/Function Calling**
   - OpenAI: `tools` + `tool_calls` in message
   - Anthropic: `tools` + `tool_use` content blocks
   - Gemini: `tools` with `functionDeclarations`
   - Bedrock: Tool config varies by model

4. **Streaming Format**
   - OpenAI: `data: {...}\n\n` SSE
   - Anthropic: SSE with event types
   - Gemini: Server-side events
   - Generic: NDJSON or custom SSE

---

## Implementation Priority by Provider

### Tier 1: Core (Immediate)
- ✅ OpenAI (already implemented)
- ✅ Anthropic (already implemented)
- Google Gemini
- Azure OpenAI
- AWS Bedrock

### Tier 2: Major Players (Short-term)
- Groq
- Together AI
- Fireworks
- Mistral AI
- Cohere
- DeepSeek

### Tier 3: Ecosystem (Medium-term)
- OpenRouter
- Perplexity
- AI21 Labs
- Replicate
- Hugging Face
- OctoAI
- Anyscale

### Tier 4: Local/Enterprise (Long-term)
- Ollama native (non-OpenAI format)
- LocalAI
- TabbyAPI
- kobold.cpp
- IBM watsonx
- GCP Vertex AI

### Tier 5: Regional (As needed)
- Alibaba DashScope
- Baidu ERNIE
- Tencent Hunyuan
- Yandex GPT
- Naver HyperCLOVA

---

## Next Steps

1. **Complete Tier 1**
   - Implement Google Gemini transformer
   - Add Azure OpenAI authentication
   - Add AWS Bedrock support

2. **Standardize Tool Calling**
   - Create unified tool schema
   - Implement bidirectional conversion
   - Test across providers

3. **Embeddings Unification**
   - Support all embedding providers
   - Normalize vector dimensions
   - Batch processing support

4. **Image/Audio APIs**
   - DALL-E, Stable Diffusion, FLUX
   - Whisper-compatible transcription
   - TTS endpoints
