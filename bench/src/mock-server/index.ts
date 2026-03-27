#!/usr/bin/env bun
/**
 * Mock LLM Server - Bun Implementation
 * 
 * Simulates LLM API responses with configurable latency and behavior.
 * Includes comprehensive error logging for debugging.
 */

import { Elysia, t } from 'elysia';
import { mkdirSync, writeFileSync, existsSync } from 'fs';
import { join } from 'path';

// ============================================================================
// Configuration
// ============================================================================

interface Config {
  port: number;
  host: string;
  latencyMeanMs: number;
  latencyStdMs: number;
  tokensPerSecond: number;
  errorRate: number;
  maxContextLength: number;
  streamingEnabled: boolean;
  logDir: string;
  logRequests: boolean;
  logErrors: boolean;
}

const config: Config = {
  port: parseInt(Bun.env.MOCK_SERVER_PORT || '9999'),
  host: Bun.env.MOCK_SERVER_HOST || '0.0.0.0',
  latencyMeanMs: parseFloat(Bun.env.MOCK_LATENCY_MEAN_MS || '0'),
  latencyStdMs: parseFloat(Bun.env.MOCK_LATENCY_STD_MS || '0'),
  tokensPerSecond: parseFloat(Bun.env.MOCK_TOKENS_PER_SEC || '100'),
  errorRate: parseFloat(Bun.env.MOCK_ERROR_RATE || '0.01'),
  maxContextLength: parseInt(Bun.env.MOCK_MAX_CONTEXT || '8192'),
  streamingEnabled: Bun.env.MOCK_STREAMING_ENABLED !== 'false',
  logDir: Bun.env.MOCK_LOG_DIR || './logs',
  logRequests: Bun.env.MOCK_LOG_REQUESTS !== 'false',
  logErrors: Bun.env.MOCK_LOG_ERRORS !== 'false',
};

// ============================================================================
// Error Logger
// ============================================================================

interface RequestLog {
  timestamp: string;
  method: string;
  path: string;
  requestId: string;
  durationMs: number;
  statusCode: number;
  error?: string;
  inputTokens?: number;
  outputTokens?: number;
  userAgent?: string;
}

interface ErrorLog {
  timestamp: string;
  requestId: string;
  method: string;
  path: string;
  error: string;
  stack?: string;
  context?: Record<string, unknown>;
}

class RequestLogger {
  private requests: RequestLog[] = [];
  private errors: ErrorLog[] = [];
  private readonly logDir: string;
  private readonly enabled: boolean;
  private readonly errorEnabled: boolean;

  constructor(logDir: string, enabled: boolean = true, errorEnabled: boolean = true) {
    this.logDir = logDir;
    this.enabled = enabled;
    this.errorEnabled = errorEnabled;
    
    if ((enabled || errorEnabled) && !existsSync(logDir)) {
      mkdirSync(logDir, { recursive: true });
    }
  }

  logRequest(log: RequestLog): void {
    if (!this.enabled) return;
    this.requests.push(log);
  }

  logError(log: ErrorLog): void {
    if (!this.errorEnabled) return;
    this.errors.push(log);
    
    // Also log to console for immediate visibility
    console.error(`[${log.timestamp}] ERROR ${log.method} ${log.path}: ${log.error}`);
  }

  saveLogs(): void {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
    
    // Save request log
    if (this.enabled && this.requests.length > 0) {
      const requestPath = join(this.logDir, `mock_requests_${timestamp}.json`);
      const requestData = {
        timestamp: new Date().toISOString(),
        totalRequests: this.requests.length,
        errors: this.requests.filter(r => r.statusCode >= 400).length,
        avgDurationMs: this.requests.reduce((a, b) => a + b.durationMs, 0) / this.requests.length,
        requests: this.requests,
      };
      writeFileSync(requestPath, JSON.stringify(requestData, null, 2));
      console.log(`📄 Request log saved to: ${requestPath}`);
    }
    
    // Save error log
    if (this.errorEnabled && this.errors.length > 0) {
      const errorPath = join(this.logDir, `mock_errors_${timestamp}.json`);
      const errorData = {
        timestamp: new Date().toISOString(),
        totalErrors: this.errors.length,
        errors: this.errors,
      };
      writeFileSync(errorPath, JSON.stringify(errorData, null, 2));
      console.log(`📄 Error log saved to: ${errorPath}`);
    }
  }

  getStats(): { total: number; errors: number; avgDuration: number } {
    if (this.requests.length === 0) {
      return { total: 0, errors: 0, avgDuration: 0 };
    }
    return {
      total: this.requests.length,
      errors: this.requests.filter(r => r.statusCode >= 400).length,
      avgDuration: this.requests.reduce((a, b) => a + b.durationMs, 0) / this.requests.length,
    };
  }
}

// Create global logger instance
const requestLogger = new RequestLogger(config.logDir, config.logRequests, config.logErrors);

// Save logs on graceful shutdown
process.on('SIGINT', () => {
  console.log('\n\nShutting down gracefully...');
  requestLogger.saveLogs();
  process.exit(0);
});

process.on('SIGTERM', () => {
  requestLogger.saveLogs();
  process.exit(0);
});

// ============================================================================
// Utils
// ============================================================================

function gaussianRandom(mean: number, std: number): number {
  const u1 = Math.random();
  const u2 = Math.random();
  const z0 = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math.PI * u2);
  return mean + z0 * std;
}

async function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function generateId(): string {
  return `mock-${Math.floor(10000 + Math.random() * 90000)}`;
}

function generateRequestId(): string {
  return `req-${Date.now()}-${Math.floor(Math.random() * 10000)}`;
}

// Sample responses for variety
const sampleResponses = [
  "This is a mock response from the LLM server.",
  "I understand your request and here's my response.",
  "Processing your input with simulated AI capabilities.",
  "Mock LLM output for benchmarking purposes.",
  "Here's a brief response to your query.",
  "Simulated natural language processing complete.",
];

// ============================================================================
// Request Handlers
// ============================================================================

interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

interface ChatCompletionRequest {
  model: string;
  messages: ChatMessage[];
  stream?: boolean;
  max_tokens?: number;
  temperature?: number;
  top_p?: number;
}

function calculateLatency(inputTokens: number, outputTokens: number): number {
  if (Bun.env.MOCK_INSTANT_MODE === 'true') {
    return 0;
  }
  
  const inputLatency = (inputTokens / 1000) * 1000;
  const outputLatency = (outputTokens / config.tokensPerSecond) * 1000;
  
  const baseLatency = config.latencyMeanMs > 0 
    ? Math.max(0, gaussianRandom(config.latencyMeanMs, config.latencyStdMs))
    : 0;
  
  return inputLatency + outputLatency + baseLatency;
}

function shouldError(): boolean {
  return Math.random() < config.errorRate;
}

function countTokens(text: string): number {
  return Math.ceil(text.length / 4);
}

function validateContextLength(messages: ChatMessage[]): { valid: boolean; tokens: number } {
  const totalText = messages.map(m => m.content).join('');
  const tokens = countTokens(totalText);
  return { valid: tokens <= config.maxContextLength, tokens };
}

// ============================================================================
// Elysia App
// ============================================================================

const app = new Elysia()
  .onError(({ code, error, set, request }) => {
    const requestId = generateRequestId();
    const errorMessage = error instanceof Error ? error.message : String(error);
    
    requestLogger.logError({
      timestamp: new Date().toISOString(),
      requestId,
      method: request.method,
      path: new URL(request.url).pathname,
      error: errorMessage,
      stack: error instanceof Error ? error.stack : undefined,
    });
    
    console.error(`[Error ${code}]`, error);
    set.status = 500;
    return { 
      error: 'Internal server error',
      requestId,
    };
  })

  // Request logging middleware
  .onBeforeHandle(({ request }) => {
    (request as Request & { _startTime?: number })._startTime = performance.now();
  })

  // Health check
  .get('/health', () => ({ 
    status: 'healthy',
    timestamp: new Date().toISOString(),
  }), {
    detail: {
      summary: 'Health check endpoint',
      description: 'Returns the health status of the mock server',
    },
  })

  // Server info
  .get('/info', () => ({
    name: 'Mock LLM Server (Bun)',
    version: '1.0.0',
    config: {
      latencyMeanMs: config.latencyMeanMs,
      latencyStdMs: config.latencyStdMs,
      tokensPerSecond: config.tokensPerSecond,
      errorRate: config.errorRate,
      maxContextLength: config.maxContextLength,
      streamingEnabled: config.streamingEnabled,
      logRequests: config.logRequests,
      logErrors: config.logErrors,
    },
    stats: requestLogger.getStats(),
  }))

  // List models
  .get('/v1/models', ({ request }) => {
    const startTime = (request as Request & { _startTime?: number })._startTime || performance.now();
    const duration = performance.now() - startTime;
    const requestId = generateRequestId();
    
    requestLogger.logRequest({
      timestamp: new Date().toISOString(),
      method: 'GET',
      path: '/v1/models',
      requestId,
      durationMs: duration,
      statusCode: 200,
    });
    
    return {
      object: 'list',
      data: [
        { id: 'gpt-4o-mini', object: 'model', created: 1677610602, owned_by: 'openai' },
        { id: 'gpt-4o', object: 'model', created: 1677610602, owned_by: 'openai' },
        { id: 'claude-3-haiku', object: 'model', created: 1677610602, owned_by: 'anthropic' },
        { id: 'claude-3-opus', object: 'model', created: 1677610602, owned_by: 'anthropic' },
      ],
    };
  })

  // Chat completions
  .post('/v1/chat/completions', async ({ body, set, request }) => {
    const startTime = (request as Request & { _startTime?: number })._startTime || performance.now();
    const requestId = generateRequestId();
    const req = body as ChatCompletionRequest;
    
    try {
      // Simulate errors
      if (shouldError()) {
        const error = 'Simulated LLM error';
        requestLogger.logError({
          timestamp: new Date().toISOString(),
          requestId,
          method: 'POST',
          path: '/v1/chat/completions',
          error,
          context: { model: req.model, simulated: true },
        });
        
        set.status = 500;
        requestLogger.logRequest({
          timestamp: new Date().toISOString(),
          method: 'POST',
          path: '/v1/chat/completions',
          requestId,
          durationMs: performance.now() - startTime,
          statusCode: 500,
          error,
        });
        
        return { error, requestId };
      }

      // Validate context length
      const { valid, tokens } = validateContextLength(req.messages);
      if (!valid) {
        const error = 'Context length exceeded';
        requestLogger.logError({
          timestamp: new Date().toISOString(),
          requestId,
          method: 'POST',
          path: '/v1/chat/completions',
          error,
          context: { 
            model: req.model, 
            contextTokens: tokens,
            maxContext: config.maxContextLength,
          },
        });
        
        set.status = 400;
        requestLogger.logRequest({
          timestamp: new Date().toISOString(),
          method: 'POST',
          path: '/v1/chat/completions',
          requestId,
          durationMs: performance.now() - startTime,
          statusCode: 400,
          error,
          inputTokens: tokens,
        });
        
        return { 
          error,
          requestId,
          context_tokens: tokens,
          max_context: config.maxContextLength,
        };
      }

      const responseText = sampleResponses[Math.floor(Math.random() * sampleResponses.length)];
      const maxTokens = req.max_tokens || 50;
      const truncatedResponse = responseText.split(' ').slice(0, maxTokens).join(' ');
      const inputTokens = tokens;
      const outputTokens = countTokens(truncatedResponse);
      const latency = calculateLatency(inputTokens, outputTokens);

      // Simulate processing time
      await sleep(latency);

      const responseId = generateId();
      const timestamp = Math.floor(Date.now() / 1000);

      // Handle streaming
      if (req.stream && config.streamingEnabled) {
        const words = truncatedResponse.split(' ');
        
        requestLogger.logRequest({
          timestamp: new Date().toISOString(),
          method: 'POST',
          path: '/v1/chat/completions',
          requestId,
          durationMs: performance.now() - startTime,
          statusCode: 200,
          inputTokens,
          outputTokens,
        });
        
        const stream = new ReadableStream({
          async start(controller) {
            try {
              // Send role first
              const roleChunk = {
                id: responseId,
                object: 'chat.completion.chunk',
                created: timestamp,
                model: req.model,
                choices: [{ index: 0, delta: { role: 'assistant' }, finish_reason: null }],
              };
              controller.enqueue(`data: ${JSON.stringify(roleChunk)}\n\n`);

              // Stream tokens
              const chunkSize = Math.floor(Math.random() * 3) + 1;
              for (let i = 0; i < words.length; i += chunkSize) {
                const chunkWords = words.slice(i, i + chunkSize);
                const chunkText = (i > 0 ? ' ' : '') + chunkWords.join(' ');
                
                await sleep((chunkWords.length / config.tokensPerSecond) * 1000);

                const contentChunk = {
                  id: generateId(),
                  object: 'chat.completion.chunk',
                  created: Math.floor(Date.now() / 1000),
                  model: req.model,
                  choices: [{ index: 0, delta: { content: chunkText }, finish_reason: null }],
                };
                controller.enqueue(`data: ${JSON.stringify(contentChunk)}\n\n`);
              }

              // Send completion
              const doneChunk = {
                id: generateId(),
                object: 'chat.completion.chunk',
                created: Math.floor(Date.now() / 1000),
                model: req.model,
                choices: [{ index: 0, delta: {}, finish_reason: 'stop' }],
              };
              controller.enqueue(`data: ${JSON.stringify(doneChunk)}\n\n`);
              controller.enqueue('data: [DONE]\n\n');
              controller.close();
            } catch (error) {
              const errorMessage = error instanceof Error ? error.message : String(error);
              requestLogger.logError({
                timestamp: new Date().toISOString(),
                requestId,
                method: 'POST',
                path: '/v1/chat/completions (streaming)',
                error: errorMessage,
                stack: error instanceof Error ? error.stack : undefined,
              });
              controller.error(error);
            }
          },
        });

        return new Response(stream, {
          headers: {
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
            'X-Request-Id': requestId,
          },
        });
      }

      // Non-streaming response
      requestLogger.logRequest({
        timestamp: new Date().toISOString(),
        method: 'POST',
        path: '/v1/chat/completions',
        requestId,
        durationMs: performance.now() - startTime,
        statusCode: 200,
        inputTokens,
        outputTokens,
      });

      return {
        id: responseId,
        object: 'chat.completion',
        created: timestamp,
        model: req.model,
        choices: [{
          index: 0,
          message: {
            role: 'assistant',
            content: truncatedResponse,
          },
          finish_reason: 'stop',
        }],
        usage: {
          prompt_tokens: inputTokens,
          completion_tokens: outputTokens,
          total_tokens: inputTokens + outputTokens,
        },
      };
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      
      requestLogger.logError({
        timestamp: new Date().toISOString(),
        requestId,
        method: 'POST',
        path: '/v1/chat/completions',
        error: errorMessage,
        stack: error instanceof Error ? error.stack : undefined,
        context: { model: req.model },
      });
      
      requestLogger.logRequest({
        timestamp: new Date().toISOString(),
        method: 'POST',
        path: '/v1/chat/completions',
        requestId,
        durationMs: performance.now() - startTime,
        statusCode: 500,
        error: errorMessage,
      });
      
      throw error;
    }
  }, {
    body: t.Object({
      model: t.String(),
      messages: t.Array(t.Object({
        role: t.Union([t.Literal('system'), t.Literal('user'), t.Literal('assistant')]),
        content: t.String(),
      })),
      stream: t.Optional(t.Boolean()),
      max_tokens: t.Optional(t.Number()),
      temperature: t.Optional(t.Number()),
      top_p: t.Optional(t.Number()),
    }),
  })

  // Root
  .get('/', () => ({
    name: 'Mock LLM Server (Bun)',
    version: '1.0.0',
    endpoints: ['/health', '/info', '/v1/models', '/v1/chat/completions'],
    documentation: '/docs',
  }));

// ============================================================================
// Start Server
// ============================================================================

console.log(`
╔══════════════════════════════════════════════════════════════╗
║           Mock LLM Server (Bun + Elysia)                    ║
╚══════════════════════════════════════════════════════════════╝
`);

console.log('Configuration:');
console.log(`  Port: ${config.port}`);
console.log(`  Host: ${config.host}`);
console.log(`  Latency: ${config.latencyMeanMs}ms ± ${config.latencyStdMs}ms`);
console.log(`  Tokens/sec: ${config.tokensPerSecond}`);
console.log(`  Error rate: ${(config.errorRate * 100).toFixed(1)}%`);
console.log(`  Max context: ${config.maxContextLength} tokens`);
console.log(`  Streaming: ${config.streamingEnabled ? 'enabled' : 'disabled'}`);
console.log(`  Request logging: ${config.logRequests ? 'enabled' : 'disabled'}`);
console.log(`  Error logging: ${config.logErrors ? 'enabled' : 'disabled'}`);
console.log(`  Log directory: ${config.logDir}`);
console.log('');

app.listen({
  port: config.port,
  hostname: config.host,
});

console.log(`🚀 Server running at http://${config.host}:${config.port}`);
console.log(`   Health: http://${config.host}:${config.port}/health`);
console.log(`   Info: http://${config.host}:${config.port}/info`);
console.log(`   Models: http://${config.host}:${config.port}/v1/models`);
console.log('');
console.log('Press Ctrl+C to stop and save logs');
