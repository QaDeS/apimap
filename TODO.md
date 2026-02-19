# TODO - Future Improvements

## Features
- [ ] **Anthropic API version header** - Handle `anthropic-version` header properly
- [ ] **anthropic-beta headers** - Support for beta features
- [ ] **Thinking/reasoning content** - Support for new Claude thinking blocks (if OpenAI adds equivalent)
- [ ] **Citations** - Document citations support
- [ ] **Rate limiting headers** - Forward rate limit info from OpenAI to client
- [ ] **Response headers** - Better content-type, content-length handling
- [ ] **Retry logic** - Exponential backoff on transient failures
- [ ] **Image content** - Support image content (vision models) - currently stripped
- [ ] **Request validation** - Validate Anthropic request structure before forwarding
- [ ] **Request ID tracking** - Add X-Request-ID for debugging
- [ ] **Metrics endpoint** - /metrics for Prometheus-style monitoring
- [ ] **Health check with upstream check** - Verify OpenAI endpoint is healthy
- [ ] **Graceful degradation** - Fallback models if primary fails
- [ ] **Request/Response size limits** - Prevent abuse
- [ ] **Authentication options** - Support for API key validation at router level
- [ ] **Caching** - Cache identical requests (respecting no-cache headers)
- [ ] **Cost tracking** - Track token usage per request
- [ ] **Structured logging** - JSON logs for production use
- [ ] **Config file support** - YAML/JSON config instead of just CLI args
- [ ] **Environment variable support** - ANTHROPIC_ROUTER_PORT, etc.
- [ ] **WebSocket support** - For real-time streaming
- [ ] **Batch requests** - Support /v1/messages/batch
- [ ] **Prompt caching** - Support for Anthropic's prompt caching feature
- [ ] **Computer use** - Support computer use beta tools

## Code Quality
- [ ] **Unit tests** - Jest/Vitest test suite
- [ ] **Integration tests** - Mock OpenAI server tests
- [ ] **TypeScript strict mode** - Enable strictest type checking
- [ ] **Linting** - ESLint configuration
- [ ] **Formatting** - Prettier configuration
- [ ] **Docker image** - Multi-stage Dockerfile
- [ ] **CI/CD** - GitHub Actions workflow
- [ ] **Benchmarks** - Performance benchmarks vs direct API calls

## Documentation
- [ ] **OpenAPI spec** - Document the API with OpenAPI/Swagger
- [ ] **Architecture diagram** - Visual overview of data flow
- [ ] **Deployment guide** - Kubernetes, Docker Compose examples
- [ ] **Troubleshooting guide** - Common issues and solutions
