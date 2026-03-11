# gRPC Endpoints Integration - Analysis & Planning Document

**Status:** Analysis Complete  
**Last Updated:** 2026-03-11  
**Decision:** On Hold (awaiting provider ecosystem maturity)

---

## Executive Summary

This document analyzes the feasibility of adding gRPC endpoints to the API Map universal model router. While technically possible, the limited native gRPC support across AI providers and Bun's immature gRPC ecosystem make this a lower-priority enhancement with limited ROI at this time.

---

## Current Architecture Overview

The API Map router currently uses:
- **Transport Protocol:** HTTP/REST
- **Runtime:** Bun (JavaScript/TypeScript)
- **Provider Pattern:** Extensible base classes that build HTTP requests
- **Data Format:** JSON-based request/response transformation
- **Streaming:** Server-Sent Events (SSE) over HTTP

### Current Provider Implementations
- `BaseProvider` - Abstract base with common functionality
- `OpenAICompatibleProvider` - For OpenAI-compatible REST APIs
- `AnthropicProvider` - Custom headers for Anthropic
- `GoogleProvider` - Query-param based auth
- `OllamaProvider` - Local inference, no auth

---

## Provider gRPC Support Matrix

| Provider | Native gRPC | Notes |
|----------|-------------|-------|
| **Google (Vertex AI/Gemini)** | ✅ Yes | Full protobuf/gRPC API at `aiplatform.googleapis.com` |
| **NVIDIA Triton** | ✅ Yes | Native gRPC for model serving |
| **vLLM** | ⚠️ Indirect | Via Triton wrapper or custom implementation |
| **TensorRT-LLM** | ✅ Via Triton | NVIDIA inference server |
| **OpenAI** | ❌ No | HTTP REST only |
| **Anthropic** | ❌ No | HTTP REST only |
| **Ollama** | ❌ No | HTTP REST only |
| **Groq** | ❌ No | HTTP REST only |
| **Together AI** | ❌ No | HTTP REST only |
| **Fireworks** | ❌ No | HTTP REST only |
| **DeepSeek** | ❌ No | HTTP REST only |
| **Mistral** | ❌ No | HTTP REST only |
| **Cohere** | ❌ No | HTTP REST only |
| **OpenRouter** | ❌ No | HTTP REST only |

### Key Insight
Only **~15% of supported providers** offer native gRPC APIs. The vast majority (including OpenAI and Anthropic) are HTTP-only.

---

## Technical Feasibility Assessment

### ✅ What's Technically Possible

1. **Google Vertex AI gRPC Client**
   - Full protobuf definitions available
   - `GenerateContent` streaming RPC
   - Better performance for high-throughput scenarios

2. **NVIDIA Triton Integration**
   - Standard gRPC interface for model serving
   - Useful for on-premise deployments
   - Supports both HTTP and gRPC endpoints

3. **gRPC-to-HTTP Gateway (Server-Side)**
   - Accept gRPC from clients, convert to HTTP internally
   - Allows gRPC-native clients to use the router
   - Maintains compatibility with existing providers

### ⚠️ Major Challenges

#### 1. Bun Runtime Limitations
```
Issue: Bun's gRPC ecosystem is immature compared to Node.js
- No native @grpc/grpc-js equivalent
- Limited protobuf tooling
- Would require Node.js compatibility mode or native bindings
- Streaming support is less battle-tested
```

#### 2. Protocol Complexity
```
Challenge: Each gRPC provider has unique protobuf definitions
- Google Vertex AI: ~500 message types, complex nested structures
- Triton: Separate protobuf definitions for inference
- Need protobuf compilation pipeline (protoc)
- Version management for .proto files
```

#### 3. Transformation Layer Complexity
```
Current: JSON → Internal Format → Provider JSON
With gRPC: JSON/gRPC → Internal Format → Provider gRPC/JSON

Additional complexity:
- Protobuf binary encoding/decoding
- gRPC metadata vs HTTP headers
- Streaming semantics (client/server/bidirectional)
- Error code mapping (gRPC status codes vs HTTP status)
```

#### 4. Limited Coverage
- gRPC support would be niche (1-2 providers)
- Most users wouldn't benefit
- Maintenance burden for feature used by minority

---

## Recommended Implementation Approaches

### Option 1: Hybrid gRPC Server Gateway (Recommended if proceeding)

**Concept:** Add gRPC server frontend that converts to internal HTTP

```
Client (gRPC) → API Map gRPC Server → Internal Router → Provider (HTTP)
```

**Pros:**
- gRPC clients can use the router
- No changes needed to providers
- Single implementation covers all providers

**Cons:**
- Added latency (gRPC→HTTP conversion)
- Doesn't leverage native gRPC where available
- Complex streaming transformation

**Estimated Effort:** 2-3 weeks

---

### Option 2: Provider-Native gRPC (Selective)

**Concept:** Add gRPC as optional transport for supported providers only

```yaml
providers:
  google:
    apiKeyEnv: "GOOGLE_API_KEY"
    transport: "grpc"  # Optional: grpc | http (default)
  
  triton:
    baseUrl: "localhost:8001"
    transport: "grpc"
```

**Implementation:**
- New `GoogleGrpcProvider` class
- New `TritonGrpcProvider` class
- Protobuf definitions in `proto/` directory
- Conditional compilation for gRPC features

**Pros:**
- Native performance where supported
- Clean abstraction
- Opt-in feature

**Cons:**
- Complex codebase (two transport layers)
- protobuf maintenance
- Testing matrix doubles

**Estimated Effort:** 3-4 weeks

---

### Option 3: Wait for Ecosystem Maturity (Recommended Current Path)

**Concept:** Monitor provider landscape, defer implementation

**Triggers for Re-evaluation:**
- [ ] OpenAI or Anthropic adds gRPC support
- [ ] Bun releases native gRPC support
- [ ] Customer demand for gRPC reaches threshold
- [ ] Performance requirements justify the investment

---

## Implementation Details (If Proceeding)

### Required Dependencies

```json
// package.json additions
{
  "dependencies": {
    "@grpc/grpc-js": "^1.12.0",
    "@grpc/proto-loader": "^0.7.0",
    "google-protobuf": "^3.21.0"
  },
  "devDependencies": {
    "grpc-tools": "^1.12.0"
  }
}
```

### Protobuf Definitions Needed

```protobuf
// proto/google/aiplatform/v1/prediction_service.proto
// (from googleapis repository)
service PredictionService {
  rpc Predict(PredictRequest) returns (PredictResponse);
  rpc StreamingPredict(stream StreamingPredictRequest) 
      returns (stream StreamingPredictResponse);
}

// proto/triton/inference.proto
// (from Triton inference server)
service GRPCInferenceService {
  rpc ModelInfer(ModelInferRequest) returns (ModelInferResponse);
  rpc ModelStreamInfer(stream ModelInferRequest) 
      returns (stream ModelStreamInferResponse);
}
```

### Proposed Directory Structure

```
src/
├── providers/
│   ├── base.ts
│   ├── grpc/              # NEW
│   │   ├── base.ts        # BaseGrpcProvider
│   │   ├── google.ts      # GoogleVertexGrpcProvider
│   │   └── triton.ts      # TritonGrpcProvider
│   └── ...
├── grpc-server/           # NEW (if Option 1)
│   ├── server.ts
│   ├── converter.ts
│   └── streaming.ts
├── proto/                 # NEW
│   ├── google/
│   └── triton/
└── ...
```

---

## Performance Considerations

| Metric | HTTP/JSON | gRPC/Protobuf | Notes |
|--------|-----------|---------------|-------|
| Payload Size | ~2-5x larger | Compact binary | Protobuf more efficient |
| Serialization | ~1-2ms | ~0.1-0.5ms | Negligible for LLM calls |
| Connection | Per-request | Persistent HTTP/2 | gRPC better for high QPS |
| Streaming Latency | ~50-100ms first token | ~40-80ms first token | Similar for LLMs |
| Throughput | Good | Better | gRPC ~10-20% better |

**Key Insight:** For LLM inference, the network overhead is negligible compared to model inference time. gRPC benefits are most visible in:
- High-throughput embedding batching
- Multi-modal requests with large payloads
- Persistent connection scenarios

---

## Decision Matrix

| Factor | Weight | Score (1-5) | Weighted |
|--------|--------|-------------|----------|
| Provider Coverage | 25% | 2 | 0.5 |
| Performance Gain | 20% | 3 | 0.6 |
| Implementation Complexity | 20% | 2 | 0.4 |
| Maintenance Burden | 15% | 2 | 0.3 |
| Customer Demand | 15% | 1 | 0.15 |
| Bun Ecosystem Maturity | 5% | 2 | 0.1 |
| **Total** | 100% | | **2.05/5** |

**Interpretation:** Below threshold (3.0) for immediate implementation.

---

## Next Steps & Action Items

### Immediate (Next 3 months)
- [ ] Monitor Bun's gRPC roadmap
- [ ] Track OpenAI/Anthropic API announcements
- [ ] Document this decision in ADR (Architecture Decision Record)

### Short-term (3-6 months)
- [ ] Gather customer feedback on gRPC interest
- [ ] Benchmark HTTP/2 vs gRPC for high-throughput scenarios
- [ ] Evaluate if Triton integration is needed for enterprise users

### Long-term (6+ months)
- [ ] Re-evaluate if provider landscape changes
- [ ] Consider gRPC if Bun adds native support
- [ ] Implement if concrete use case emerges

---

## Alternatives to Consider

### 1. HTTP/2 Optimization (Immediate Win)
Bun already supports HTTP/2. Ensure we're leveraging:
- Connection pooling
- Header compression (HPACK)
- Server push (if applicable)

### 2. WebSocket Streaming (Bidirectional)
For real-time bidirectional use cases:
- Lower overhead than polling
- Native browser support
- Simpler than gRPC-Web

### 3. Connect-RPC (Modern Alternative)
- gRPC-compatible but works over HTTP/1.1
- Smaller payload than REST
- Better browser support than native gRPC
- Consider if gRPC semantics needed without complexity

---

## References

- [Google Vertex AI gRPC API](https://cloud.google.com/vertex-ai/docs/reference/rpc/google.cloud.aiplatform.v1)
- [NVIDIA Triton gRPC Protocol](https://github.com/triton-inference-server/common/blob/main/protobuf/grpc_service.proto)
- [Bun GitHub Issues - gRPC Support](https://github.com/oven-sh/bun/issues)
- [gRPC vs REST Performance](https://grpc.io/docs/guides/performance/)
- [Connect-RPC](https://connectrpc.com/)

---

## Appendix: Sample Implementation Sketch

### Google gRPC Provider (Conceptual)

```typescript
// src/providers/grpc/google.ts
import { credentials, loadPackageDefinition } from '@grpc/grpc-js';
import { loadSync } from '@grpc/proto-loader';
import { BaseProvider, ProviderRequest } from '../base.ts';

const PROTO_PATH = './proto/google/aiplatform/v1/prediction_service.proto';

export class GoogleGrpcProvider extends BaseProvider {
  private client: any;
  
  constructor(id: string, config: ProviderConfig) {
    super(id, config);
    
    const packageDefinition = loadSync(PROTO_PATH, {
      keepCase: true,
      longs: String,
      enums: String,
      defaults: true,
      oneofs: true,
    });
    
    const proto = loadPackageDefinition(packageDefinition);
    const PredictionService = proto.google.cloud.aiplatform.v1.PredictionService;
    
    this.client = new PredictionService(
      'aiplatform.googleapis.com:443',
      credentials.createSsl()
    );
  }
  
  async buildRequest(body: unknown): Promise<ProviderRequest> {
    // Convert OpenAI format to Vertex AI protobuf
    const request = this.convertToVertexFormat(body);
    
    return {
      url: 'grpc://aiplatform.googleapis.com',
      headers: { 'x-goog-api-key': this.getApiKey()! },
      body: request,
    };
  }
  
  async *streamGenerateContent(request: any): AsyncGenerator<any> {
    const call = this.client.streamingPredict(request);
    
    for await (const response of call) {
      yield this.convertToOpenAIFormat(response);
    }
  }
}
```

---

*Document Version: 1.0*  
*Author: AI Assistant*  
*Review Cycle: Quarterly or on significant provider changes*
