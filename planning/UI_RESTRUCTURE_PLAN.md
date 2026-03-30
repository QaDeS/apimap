# UI Restructure Plan: Merge Dashboard, Monitor, and Logs

## Overview

This plan describes the restructuring of the admin UI to merge the Dashboard, Monitor, and Logs pages into a single unified "Dashboard" view with real-time stats, comprehensive filters, and expandable message tiles.

## Current State

### Existing Pages
1. **Dashboard** (`gui/src/routes/+page.svelte`)
   - Static stats cards (Total, Routed, Unrouted, Avg Latency)
   - Unrouted requests list
   - Auto-refreshes every 5 seconds

2. **Monitor** (`gui/src/routes/monitor/+page.svelte`)
   - Live WebSocket connection for real-time updates
   - Shows active requests with status (pending/streaming/completed/error)
   - Stats bar (Total, Running, Completed, Errors)
   - Expandable request items showing prompt and response content
   - MessageDisplay component for streaming content

3. **Logs** (`gui/src/routes/logs/+page.svelte`)
   - Historical request logs with filtering
   - Tabs in expanded view: Request, Transformed Request, Upstream Response, Response, Error, Metadata
   - Shows schema conversion information
   - Tool call detection

### Backend APIs
- `/admin/status` - System stats
- `/admin/unrouted` - Unrouted requests
- `/admin/logs` - Historical logs
- `/admin/active-requests` - Active requests (HTTP fallback)
- WebSocket `/ws` - Real-time updates

## Proposed New Structure

### Dashboard Page Layout

```
┌────────────────────────────────────────────────────────────────────────┐
│  Dashboard (Live)                                            [Status]  │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  ┌────────────┐ ┌──────────┐ ┌──────────┐ ┌───────────┐ ┌──────────┐   │
│  │ Total      │ │ Routed   │ │ Running  │ │ Completed │ │ Avg      │   │
│  │ 1,523      │ │ 1,500 ✓  │ │ 2  Total │ │ 1420    ✓ │ │ 450   ms │   │
│  │ 34 ●stream │ │ 23   ⚠️  │ │ 1 ◐stream│ │ 80      ✗ │ │ 43.3  t/s│   │
│  └────────────┘ └──────────┘ └──────────┘ └───────────┘ └──────────┘   │
│                                                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ Filter: [Search...] [Status ▼] [Provider ▼] [Time ▼]  322/1,523 │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                        │
│                        < 1 2 3 4 ... 33 >                     [10 ▼]   │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ ▶ ✓ gpt4o -> my/gpt4o  ● stream                     ⏰ 10:30:15 │   │
│  │   E openai      Let's test if you are opiniona…     13.6 s (200)│   │
│  ├─────────────────────────────────────────────────────────────────┤   │
│  │ ▼ ✓ sonnet -> gptOSS ● stream                       ⏰ 10:30:12 │   │
│  │   E llamacpp                                        23.4 s (200)│   │
│  │   ┌─────────┬─────────┬───────┬──────────┬───────┬──────────┐   │   │
│  │   │ Message │ Request │ T Req │ Response │ T Res │ Metadata │   │   │
│  │   │         └─────────┴───────┴──────────┴───────┴──────────┘   │   │
│  │   │ Hello, how are you? And what is your Opinion on the best│   │   │
│  │   │ food in asia?                                           │   │   │
│  │   ├─────────────────────────────────────────────────────────┤   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### Stats Cards (5 cards)

| Card | Primary Value | Secondary Line |
|------|---------------|----------------|
| **Total** | Total request count | Streaming count (● stream) |
| **Routed** | Routed count | Unrouted count (⚠️) |
| **Running** | Running total | Streaming count (◐ stream for pending, ● stream for streaming) |
| **Completed** | Completed count | Error count (✗) |
| **Avg** | Avg latency (ms) | Tokens per second (t/s) |

### Collapsed Item Format

**Line 1:** Status icon + source model + arrow + target model + streaming indicator + time
```
✓ gpt4o -> my/gpt4o  ● stream                     ⏰ 10:30:15
```

**Line 2:** Provider icon (E = external/provider initials) + shortened prompt + duration + HTTP status in parentheses
```
E openai    Let's test if you are opiniona…       13.6 s (200)
```

**Status indicators:**
- `✓` Green = completed/routed
- `✗` Red = error
- `◐` Yellow = pending
- `⚠️` Orange = unrouted

**Streaming indicators:**
- `●` Blue pulsing dot = actively streaming
- `○` Gray dot = was streaming (completed stream)

### Expanded Item Tabs (6 tabs)

1. **Message** - Shows prompt and response content (from Monitor)
   - Full prompt display
   - Response content with MessageDisplay component
   - Reasoning content if available
   - Real-time streaming updates

2. **Request** - Original client request
   - Source format/scheme
   - Original request body (JSON viewer)
   - Tool definitions if present

3. **T Req** (Transformed Request) - Request as sent to provider
   - Target format
   - Transformed request body (JSON viewer)
   - Tool definitions in provider format

4. **Response** - Provider-returned response BEFORE transformation
   - Original format (target scheme)
   - Raw upstream response body (JSON viewer)
   - Tool calls in provider format
   - Response headers from provider

5. **T Res** (Transformed Response) - Response as sent to client
   - Transformed format (source scheme)
   - Transformed response body (JSON viewer)
   - Tool calls in client format

6. **Metadata** - Request routing and timing details
   - Request ID, timestamp, duration
   - Provider URL (NEW)
   - Authentication scheme used (header, prefix, masked key) (NEW)
   - Routing pattern matched
   - Source/target schemes

### List Features

- **Pagination**: Page numbers with prev/next, items-per-page selector (10/25/50/100)
- **Filter bar**: Search text, status dropdown, provider dropdown, time range
- **Counter**: Shows "filtered/total" count (e.g., "322/1,523")

## Implementation Plan

### Phase 1: Backend API Enhancements

#### 1.1 Extend LogEntry with Additional Fields
**File:** `src/types/index.ts`

Add to `LogEntry` interface:
```typescript
export interface LogEntry {
  // ... existing fields ...
  
  /** Provider base URL used for the request */
  providerUrl?: string;
  
  /** Authentication scheme details */
  authScheme?: {
    header: string;
    prefix: string;
    maskedKey: string;
  };
  
  /** Stream flag from request */
  stream?: boolean;
}
```

#### 1.2 Capture Provider Info in Request Handling
**File:** `src/server.ts`

Modify `handleRequest` to capture:
- Provider base URL
- Auth header/prefix used
- Stream flag from request body
- Store in logEntry

```typescript
// In handleRequest, before making the provider request:
const providerReq = provider.buildRequest(transformedReq, req.headers);
const providerInfo = provider.getInfo();
const providerConfig = config.providers[route.provider];
const streamMode = body.stream === true;

// Add to logEntry
logEntry.providerUrl = providerReq.url;
logEntry.authScheme = {
  header: providerConfig?.authHeader || providerInfo.authHeader,
  prefix: providerConfig?.authPrefix || providerInfo.authPrefix,
  maskedKey: maskApiKey(provider.getApiKey() || ''),
};
logEntry.stream = streamMode;
```

#### 1.3 Add WebSocket Log History Endpoint
**File:** `src/server.ts`

Send recent logs on WebSocket connect:
```typescript
// In WebSocket handler, on connection:
const recentLogs = await state.logging.getRecentLogs(50);
ws.send(JSON.stringify({ type: 'initial_logs', logs: recentLogs }));
```

#### 1.4 Add Tokens-Per-Second Calculation
**File:** `src/logging/index.ts` or `src/server.ts`

Calculate and store tokens-per-second for completed requests:
```typescript
// When logging completes:
if (entry.responseBody && typeof entry.responseBody === 'object') {
  const usage = entry.responseBody.usage;
  if (usage?.completion_tokens && entry.durationMs > 0) {
    entry.tokensPerSecond = Math.round(
      (usage.completion_tokens / entry.durationMs) * 1000
    );
  }
}
```

### Phase 2: Frontend Type Updates

#### 2.1 Update API Types
**File:** `gui/src/lib/utils/api.ts`

Update `LogEntry` interface:
```typescript
export interface LogEntry {
  // ... existing fields ...
  providerUrl?: string;
  authScheme?: {
    header: string;
    prefix: string;
    maskedKey: string;
  };
  stream?: boolean;
  tokensPerSecond?: number;
}
```

#### 2.2 Update Stats Type
**File:** `gui/src/lib/utils/api.ts`

```typescript
export interface DashboardStats {
  total: number;
  streaming: number;
  routed: number;
  unrouted: number;
  running: number;
  runningStreaming: number;
  completed: number;
  errors: number;
  avgLatency: number;
  avgTokensPerSecond: number;
}
```

### Phase 3: Create Unified Dashboard Page

#### 3.1 New Dashboard Implementation
**File:** `gui/src/routes/+page.svelte` (rewrite)

Key state:
```svelte
<script>
  // State
  let logs = $state<LogEntry[]>([]);
  let expandedLogId = $state<string | null>(null);
  let activeTabs = $state<Record<string, string>>({}); // per-request tab state
  
  // Filters
  let searchFilter = $state('');
  let statusFilter = $state<'all' | 'streaming' | 'pending' | 'completed' | 'error' | 'unrouted'>('all');
  let providerFilter = $state<string>('all');
  let timeRangeFilter = $state<'1h' | '24h' | '7d' | 'all'>('all');
  
  // Pagination
  let currentPage = $state(1);
  let itemsPerPage = $state(10);
  
  // Derived stats
  let stats = $derived(calculateStats(logs));
  
  // Filtered and paginated logs
  let filteredLogs = $derived(filterLogs(logs, searchFilter, statusFilter, providerFilter));
  let paginatedLogs = $derived(paginate(filteredLogs, currentPage, itemsPerPage));
  
  // WebSocket connection
  // ...
</script>
```

#### 3.2 Create StatsBar Component
**File:** `gui/src/lib/components/StatsBar.svelte`

Five stat cards with primary and secondary values:
```svelte
<div class="grid grid-cols-5 gap-4">
  <StatCard 
    label="Total"
    value={stats.total}
    secondary={`${stats.streaming} ● stream`}
    icon={Activity}
    color="blue"
  />
  <StatCard 
    label="Routed"
    value={stats.routed}
    secondary={`${stats.unrouted} ⚠️`}
    icon={CheckCircle}
    color="green"
  />
  <StatCard 
    label="Running"
    value={stats.running}
    secondary={`${stats.runningStreaming} streaming`}
    icon={Loader2}
    color="amber"
  />
  <StatCard 
    label="Completed"
    value={stats.completed}
    secondary={`${stats.errors} ✗`}
    icon={CheckCircle}
    color="purple"
  />
  <StatCard 
    label="Avg"
    value={`${stats.avgLatency}ms`}
    secondary={`${stats.avgTokensPerSecond} t/s`}
    icon={Clock}
    color="gray"
  />
</div>
```

#### 3.3 Create MessageFilters Component
**File:** `gui/src/lib/components/MessageFilters.svelte`

```svelte
<div class="flex items-center gap-4 p-4 bg-white rounded-lg border">
  <input 
    type="text" 
    placeholder="Search model, provider, request ID..."
    bind:value={search}
    class="flex-1"
  />
  <select bind:value={status}>
    <option value="all">All Status</option>
    <option value="streaming">Streaming</option>
    <option value="pending">Pending</option>
    <option value="completed">Completed</option>
    <option value="error">Error</option>
    <option value="unrouted">Unrouted</option>
  </select>
  <select bind:value={provider}>
    <option value="all">All Providers</option>
    {#each providers as p}
      <option value={p.id}>{p.name}</option>
    {/each}
  </select>
  <select bind:value={timeRange}>
    <option value="1h">Last Hour</option>
    <option value="24h">Last 24h</option>
    <option value="7d">Last 7 Days</option>
    <option value="all">All Time</option>
  </select>
  <span class="text-sm text-gray-500">{filteredCount}/{totalCount}</span>
</div>
```

#### 3.4 Create Pagination Component
**File:** `gui/src/lib/components/Pagination.svelte`

```svelte
<div class="flex items-center justify-between">
  <div class="flex items-center gap-2">
    {#each pageNumbers as page}
      <button 
        class:active={page === currentPage}
        onclick={() => goToPage(page)}
      >
        {page}
      </button>
    {/each}
  </div>
  <select bind:value={itemsPerPage}>
    <option value={10}>10 per page</option>
    <option value={25}>25 per page</option>
    <option value={50}>50 per page</option>
    <option value={100}>100 per page</option>
  </select>
</div>
```

#### 3.5 Create MessageTile Component
**File:** `gui/src/lib/components/MessageTile.svelte`

Props:
```typescript
interface Props {
  log: LogEntry;
  isExpanded: boolean;
  activeTab: string; // 'message' | 'request' | 'transformedRequest' | 'response' | 'transformedResponse' | 'metadata'
  onToggle: () => void;
  onTabChange: (tab: string) => void;
}
```

**Collapsed view layout:**
```
[▶/▼] [✓] {sourceModel} -> {targetModel}  [● stream]        ⏰ {time}
      E {provider}   {truncatedPrompt}...   {duration}s ({statusCode})
```

**Expanded view layout:**
```
┌─────────────────────────────────────────────────────────┐
│ Message │ Request │ T Req │ Response │ T Res │ Metadata │
├─────────────────────────────────────────────────────────┤
│ [Tab content based on activeTab]                       │
│                                                        │
│ For Message tab:                                       │
│ - Prompt section (full text, collapsible)              │
│ - Response section (MessageDisplay component)          │
│                                                        │
└─────────────────────────────────────────────────────────┘
```

#### 3.6 Create Tab Content Components

**MessageTab.svelte:**
```svelte
<div class="p-4 space-y-4">
  <!-- Prompt -->
  <div class="bg-blue-50 rounded-lg p-4">
    <div class="flex justify-between mb-2">
      <span class="text-sm font-medium text-blue-700">Prompt</span>
      <button onclick={togglePrompt}>Collapse/Expand</button>
    </div>
    <pre class="text-sm text-blue-900 whitespace-pre-wrap">{prompt}</pre>
  </div>
  
  <!-- Response -->
  <div>
    <span class="text-sm font-medium text-gray-700 mb-2">Response</span>
    <MessageDisplay 
      content={responseContent}
      reasoningContent={reasoningContent}
      isStreaming={log.status === 'streaming'}
    />
  </div>
</div>
```

**RequestTab.svelte:**
```svelte
<div class="p-4 space-y-3">
  <div class="flex gap-4 text-sm text-gray-500">
    <span>Format: <code>{log.sourceScheme}</code></span>
    <span>Endpoint: <code>{log.method} {log.path}</code></span>
  </div>
  <JsonViewer data={log.requestBody} />
</div>
```

**TransformedRequestTab.svelte:**
```svelte
<div class="p-4 space-y-3">
  <div class="flex gap-4 text-sm text-gray-500">
    <span>Target Format: <code>{log.targetScheme}</code></span>
    <span>Provider: <code>{log.provider}</code></span>
  </div>
  <JsonViewer data={log.transformedBody} />
</div>
```

**ResponseTab.svelte** (raw upstream response):
```svelte
<div class="p-4 space-y-3">
  <div class="flex gap-4 text-sm text-gray-500">
    <span>Original Format: <code>{log.targetScheme}</code></span>
    <span>From: <code>{log.provider}</code></span>
  </div>
  <JsonViewer data={log.rawUpstreamResponse} />
</div>
```

**TransformedResponseTab.svelte** (client response):
```svelte
<div class="p-4 space-y-3">
  <div class="flex gap-4 text-sm text-gray-500">
    <span>Transformed Format: <code>{log.sourceScheme}</code></span>
    <span>Status: <code>{log.responseStatus}</code></span>
  </div>
  <JsonViewer data={log.responseBody} />
</div>
```

**MetadataTab.svelte:**
```svelte
<div class="p-4">
  <div class="grid grid-cols-3 gap-4 text-sm">
    <div>
      <span class="text-gray-500 block">Request ID</span>
      <p class="font-mono text-xs break-all">{log.requestId}</p>
    </div>
    <div>
      <span class="text-gray-500 block">Provider URL</span>
      <p class="font-mono text-xs truncate" title={log.providerUrl}>
        {log.providerUrl}
      </p>
    </div>
    <div>
      <span class="text-gray-500 block">Authentication</span>
      <p class="font-mono text-xs">
        {log.authScheme?.header}: {log.authScheme?.prefix}{log.authScheme?.maskedKey}
      </p>
    </div>
    <div>
      <span class="text-gray-500 block">Source Format</span>
      <p class="font-mono text-xs">{log.sourceScheme}</p>
    </div>
    <div>
      <span class="text-gray-500 block">Target Format</span>
      <p class="font-mono text-xs">{log.targetScheme}</p>
    </div>
    <div>
      <span class="text-gray-500 block">Matched Pattern</span>
      <p class="font-mono text-xs">{log.matchedPattern || 'N/A'}</p>
    </div>
    <div>
      <span class="text-gray-500 block">Duration</span>
      <p>{formatDuration(log.durationMs)}</p>
    </div>
    <div>
      <span class="text-gray-500 block">Timestamp</span>
      <p class="text-xs">{log.timestamp}</p>
    </div>
    <div>
      <span class="text-gray-500 block">Stream</span>
      <p>{log.stream ? 'Yes' : 'No'}</p>
    </div>
  </div>
</div>
```

### Phase 4: Utility Components

#### 4.1 JsonViewer Component
**File:** `gui/src/lib/components/JsonViewer.svelte`

```svelte
<script>
  let { data } = $props();
  
  function formatJson(obj) {
    return JSON.stringify(obj, null, 2);
  }
</script>

<div class="bg-gray-900 rounded-lg p-4 overflow-x-auto max-h-96 overflow-y-auto">
  <pre class="text-sm text-gray-100 font-mono whitespace-pre-wrap">
    {formatJson(data)}
  </pre>
</div>
```

#### 4.2 StatusIcon Component
**File:** `gui/src/lib/components/StatusIcon.svelte`

```svelte
<script>
  let { status, isStreaming } = $props();
  
  const icons = {
    completed: CheckCircle,
    error: XCircle,
    pending: Clock,
    streaming: Activity,
    unrouted: AlertTriangle,
  };
  
  const colors = {
    completed: 'text-green-600',
    error: 'text-red-600',
    pending: 'text-amber-600',
    streaming: 'text-blue-600',
    unrouted: 'text-orange-600',
  };
</script>

<span class={colors[status]}>
  {#if status === 'streaming'}
    <span class="animate-pulse">●</span>
  {:else}
    <svelte:component this={icons[status]} size={16} />
  {/if}
</span>
```

### Phase 5: Update Navigation

#### 5.1 Remove Monitor and Logs from Nav
**File:** `gui/src/routes/+layout.svelte`

Update `navItems` to remove Monitor and Logs:
```typescript
const navItems = [
  { path: '/', label: 'Dashboard', icon: LayoutDashboard },
  { path: '/test', label: 'Test Models', icon: Beaker },
  { path: '/providers', label: 'Providers', icon: Server },
  { path: '/routes', label: 'Routes', icon: Route },
  { path: '/config', label: 'Configuration', icon: Settings },
  { path: '/backups', label: 'Backups', icon: Database },
  // Monitor and Logs removed - now part of Dashboard
];
```

#### 5.2 Add Redirects (Optional)
Create redirect pages for backward compatibility:
**File:** `gui/src/routes/monitor/+page.svelte`:
```svelte
<script>
  import { goto } from '$app/navigation';
  goto('/');
</script>
```

**File:** `gui/src/routes/logs/+page.svelte`:
```svelte
<script>
  import { goto } from '$app/navigation';
  goto('/');
</script>
```

### Phase 6: Helper Functions

#### 6.1 Status Derivation
```typescript
function deriveStatus(log: LogEntry): 'completed' | 'error' | 'pending' | 'streaming' | 'unrouted' {
  if (!log.routed) return 'unrouted';
  if (log.error || log.responseStatus >= 400) return 'error';
  // For streaming detection, we need to track active requests separately
  // or add a status field to LogEntry
  return 'completed';
}
```

#### 6.2 Prompt Extraction
```typescript
function extractPrompt(requestBody: unknown): string {
  if (!requestBody || typeof requestBody !== 'object') return '';
  
  // OpenAI format
  if (requestBody.messages?.length > 0) {
    const lastUser = requestBody.messages.findLast(m => m.role === 'user');
    if (lastUser) {
      return typeof lastUser.content === 'string' 
        ? lastUser.content 
        : JSON.stringify(lastUser.content);
    }
  }
  
  // Anthropic format
  if (requestBody.prompt) {
    return requestBody.prompt;
  }
  
  return '';
}
```

#### 6.3 Prompt Truncation
```typescript
function truncatePrompt(prompt: string, maxLength: number = 50): string {
  if (!prompt) return '';
  if (prompt.length <= maxLength) return prompt;
  return prompt.slice(0, maxLength) + '…';
}
```

## Data Flow

### WebSocket Message Types

```typescript
// Server -> Client
interface WebSocketMessage {
  type: 'initial_logs' | 'log_entry' | 'request_update';
  logs?: LogEntry[];        // For initial_logs
  entry?: LogEntry;         // For log_entry  
  request?: ActiveRequest;  // For request_update (for real-time status)
}
```

### Real-Time Updates Flow

1. **On WebSocket connect**: Server sends `initial_logs` with recent 50 logs
2. **On new request**: Server sends `request_update` with ActiveRequest status
3. **On request complete**: Server sends `log_entry` with complete LogEntry
4. **Client merges**: Updates local logs array, preserving streaming status from ActiveRequest

### Stats Calculation (Derived)

```typescript
function calculateStats(logs: LogEntry[]): DashboardStats {
  const total = logs.length;
  const streaming = logs.filter(l => l.stream).length;
  const routed = logs.filter(l => l.routed).length;
  const unrouted = logs.filter(l => !l.routed).length;
  const completed = logs.filter(l => l.routed && l.responseStatus < 400 && !l.error).length;
  const errors = logs.filter(l => l.error || l.responseStatus >= 400).length;
  
  // Running = pending + streaming (need to track via ActiveRequest or add status field)
  const running = activeRequests.size; // From WebSocket tracking
  const runningStreaming = activeRequests.filter(r => r.status === 'streaming').length;
  
  const totalLatency = logs.reduce((sum, l) => sum + l.durationMs, 0);
  const avgLatency = total > 0 ? Math.round(totalLatency / total) : 0;
  
  const totalTokensPerSec = logs
    .filter(l => l.tokensPerSecond)
    .reduce((sum, l) => sum + (l.tokensPerSecond || 0), 0);
  const avgTokensPerSecond = totalTokensPerSec > 0 
    ? Math.round(totalTokensPerSec / logs.filter(l => l.tokensPerSecond).length)
    : 0;
    
  return {
    total, streaming, routed, unrouted,
    running, runningStreaming, completed, errors,
    avgLatency, avgTokensPerSecond
  };
}
```

## Implementation Order

1. **Phase 1.1** - Extend LogEntry types (backend + frontend)
2. **Phase 1.2** - Capture provider URL and auth in request handling
3. **Phase 1.3** - Add initial_logs WebSocket message
4. **Phase 1.4** - Add tokens-per-second calculation
5. **Phase 2** - Update frontend types
6. **Phase 3.1** - Create StatsBar component
7. **Phase 3.2** - Create MessageFilters component
8. **Phase 3.3** - Create Pagination component
9. **Phase 3.4** - Create MessageTile component with tabs
10. **Phase 3.5** - Create tab content components
11. **Phase 3.6** - Create new Dashboard page
12. **Phase 4** - Create utility components (JsonViewer, StatusIcon)
13. **Phase 5** - Update navigation
14. **Phase 6** - Test and validate

## Testing Checklist

- [ ] Stats cards show correct values and update in real-time
- [ ] Secondary stats (streaming count, unrouted count, errors, t/s) display correctly
- [ ] Filters work: search, status, provider, time range
- [ ] Filter counter shows "filtered/total"
- [ ] Pagination works correctly
- [ ] Items-per-page selector works
- [ ] Message tiles expand/collapse on click
- [ ] Collapsed view shows: status icon, source->target model, streaming indicator, time
- [ ] Collapsed view shows: provider icon, truncated prompt, duration, status code
- [ ] All 6 tabs work: Message, Request, T Req, Response, T Res, Metadata
- [ ] Message tab shows full prompt (collapsible) and response with MessageDisplay
- [ ] Request tab shows source format and original request body
- [ ] T Req tab shows target format and transformed request body
- [ ] Response tab shows raw upstream response (before transformation)
- [ ] T Res tab shows transformed response (as sent to client)
- [ ] Metadata tab shows provider URL and auth scheme
- [ ] Streaming indicator pulses for active streams
- [ ] Status icons correct: ✓ completed, ✗ error, ◐ pending, ⚠️ unrouted
- [ ] WebSocket reconnects on disconnect
- [ ] Mobile layout works correctly
- [ ] Navigation no longer shows Monitor and Logs

## Migration Notes

- `/monitor` and `/logs` routes can redirect to `/` for backward compatibility
- All functionality consolidated into single Dashboard page
- Existing LogEntry data without new fields will show "N/A" or empty values
- WebSocket protocol extended but backward compatible
