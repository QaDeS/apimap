# API Map - Development Roadmap

> **Strategic additions and modifications for the Universal Model Router**

This document organizes potential enhancements by priority and effort level.

---

## 🔴 High Priority (Core Functionality)

### 1. Rate Limiting System
- Per-provider rate limits (requests/minute, tokens/minute)
- Per-key or per-user limits for multi-user scenarios
- Configurable via YAML: `providers.openai.rateLimit: { rpm: 60, tpm: 100000 }`
- Returns proper 429 responses with Retry-After headers

### 2. Request Retry with Fallback Providers
- Auto-retry failed requests with exponential backoff
- Fallback to alternative providers for the same model pattern
- Configurable retry count and timeout per provider

### 3. Provider Health Checks
- Periodic health checks to `/health` or lightweight endpoints
- Mark providers as "unhealthy" after consecutive failures
- Skip unhealthy providers in routing decisions
- Visual indicator in GUI (red/green status)

### 4. Request Replay Functionality
- Replay any logged request from the GUI
- Useful for debugging and testing provider changes

---

## 🟡 Medium Priority (Operational)

### 5. Request Caching Layer
- Cache responses for identical requests (respecting `cache_control` headers)
- Redis or in-memory option
- Configurable TTL per provider/route
- Huge cost savings for repeated queries

### 6. Cost Tracking & Budget Alerts
- Track spend per provider, model, route
- Daily/weekly/monthly usage dashboards
- Budget alerts (notify when approaching limits)
- Export usage reports (CSV/JSON)

### 7. Metrics Endpoint (Prometheus)
- `/metrics` endpoint for Prometheus scraping
- Request counts, latency histograms, error rates
- Provider-specific metrics
- Pre-built Grafana dashboard

### 8. Docker & Docker Compose
```yaml
# docker-compose.yml
services:
  apimap:
    build: .
    ports: ["3000:3000", "3001:3001"]
    volumes: ["./config:/app/config", "./logs:/app/logs"]
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
```

### 9. Request Validation Middleware
- Validate incoming requests against provider schemas before routing
- Early rejection of malformed requests (saves API calls)
- Better error messages for common mistakes

---

## 🟢 Nice to Have (UX & Polish)

### 10. Dark Mode
- System preference detection
- Toggle in GUI
- CSS variables for easy theming

### 11. Log Export & Retention Policies
- Export logs as JSON/CSV
- Configurable retention (keep last N days)
- Auto-archive old logs

### 12. Request Search & Advanced Filtering
- Full-text search across prompts and responses
- Filter by date range, provider, model, status code
- Save common filter combinations

### 13. Keyboard Shortcuts
- Quick navigation between pages
- `Cmd/Ctrl+K` command palette
- `Esc` to close modals

### 14. Auto-Route Suggestions
- ML-based suggestions for unrouted requests
- "Users who routed X also used Y pattern"

### 15. Multi-User/API Key Management
- Named API keys with separate rate limits
- Usage tracking per key
- Key expiration/rotation

---

## 🔧 Technical Improvements

### 16. Complete Test Suite
- Integration tests for all provider transformations
- Load testing scripts
- Streaming response tests

### 17. OpenAPI/Swagger Documentation
- Auto-generated API docs
- Interactive API explorer at `/docs`

### 18. Plugin/Middleware System
- Allow custom request/response transformations
- Webhook support for pre/post-processing
- Community plugins for special formats

### 19. Google Gemini & Azure OpenAI Support
- Native Gemini transformer
- Azure OpenAI auth (API key + endpoint)

### 20. Batch Request Support
- OpenAI's batch API compatibility
- Queue and process large batches efficiently

---

## 📊 Priority Matrix

| Feature | Impact | Effort | Quick Win? |
|---------|--------|--------|------------|
| Rate Limiting | High | Medium | ✅ |
| Health Checks | High | Low | ✅ |
| Docker Support | Medium | Low | ✅ |
| Prometheus Metrics | Medium | Low | ✅ |
| Cost Tracking | High | Medium | |
| Request Caching | High | High | |
| Retry/Fallback | High | Medium | |
| Dark Mode | Low | Low | ✅ |

---

## Recommended Implementation Order

### Phase 1: Foundation (Weeks 1-2)
1. Docker & Docker Compose support
2. Provider health checks
3. Basic rate limiting

### Phase 2: Reliability (Weeks 3-4)
4. Request retry with fallback
5. Request validation middleware
6. Complete test suite

### Phase 3: Observability (Weeks 5-6)
7. Prometheus metrics
8. Cost tracking foundation
9. Request replay

### Phase 4: Scale & Polish (Weeks 7-8)
10. Request caching
11. Dark mode
12. Advanced filtering
