<script lang="ts">
  import { ChevronDown, ChevronUp, ExternalLink } from '@lucide/svelte';
  import type { LogEntry } from '$lib/utils/api';
  import StatusIcon from './StatusIcon.svelte';
  import JsonViewer from './JsonViewer.svelte';
  import MessageDisplay from './MessageDisplay.svelte';

  interface Props {
    log: LogEntry;
    isExpanded: boolean;
    activeTab: string;
    onToggle: () => void;
    onTabChange: (tab: string) => void;
  }

  let { log, isExpanded, activeTab, onToggle, onTabChange }: Props = $props();

  // Derive status from log
  function deriveStatus(log: LogEntry): 'completed' | 'error' | 'pending' | 'streaming' | 'unrouted' {
    if (!log.routed) return 'unrouted';
    if (log.error || log.responseStatus >= 400) return 'error';
    // Note: streaming/pending status comes from active requests tracking
    // For now, completed logs show as completed
    return 'completed';
  }

  const status = $derived(deriveStatus(log));

  // Format time
  function formatTime(timestamp: string): string {
    return new Date(timestamp).toLocaleTimeString();
  }

  // Format duration
  function formatDuration(ms: number): string {
    if (ms < 1000) return `${ms}ms`;
    return `${(ms / 1000).toFixed(1)}s`;
  }

  // Extract prompt from request body
  function extractPrompt(body: unknown): string {
    if (!body || typeof body !== 'object') return '';
    const b = body as Record<string, unknown>;
    
    // OpenAI format
    if (b.messages && Array.isArray(b.messages)) {
      const userMsgs = b.messages.filter((m: {role?: string}) => m.role === 'user');
      if (userMsgs.length > 0) {
        const lastMsg = userMsgs[userMsgs.length - 1];
        if (typeof lastMsg.content === 'string') return lastMsg.content;
        if (Array.isArray(lastMsg.content)) {
          return lastMsg.content.map((c: {text?: string}) => c.text || '').join(' ');
        }
      }
    }
    
    // Anthropic format
    if (typeof b.prompt === 'string') return b.prompt;
    
    return '';
  }

  // Truncate prompt
  function truncatePrompt(prompt: string, maxLength: number = 50): string {
    if (!prompt) return '';
    if (prompt.length <= maxLength) return prompt;
    return prompt.slice(0, maxLength) + '…';
  }

  // Extract response content for Message tab
  function extractResponseContent(body: unknown): string {
    if (!body || typeof body !== 'object') return '';
    const b = body as Record<string, unknown>;
    
    // OpenAI format
    if (b.choices && Array.isArray(b.choices) && b.choices.length > 0) {
      const choice = b.choices[0];
      if (choice.message?.content) return String(choice.message.content);
      if (choice.delta?.content) return String(choice.delta.content);
    }
    
    // Anthropic format
    if (b.content && Array.isArray(b.content) && b.content.length > 0) {
      return b.content.map((c: {text?: string}) => c.text || '').join('');
    }
    
    // String response
    if (typeof b === 'string') return b;
    
    return '';
  }

  // Extract reasoning content
  function extractReasoningContent(body: unknown): string {
    if (!body || typeof body !== 'object') return '';
    const b = body as Record<string, unknown>;
    
    // DeepSeek/OpenAI reasoning
    if (b.choices && Array.isArray(b.choices) && b.choices.length > 0) {
      const choice = b.choices[0];
      if (choice.message?.reasoning_content) return String(choice.message.reasoning_content);
    }
    
    // Anthropic thinking
    if (b.content && Array.isArray(b.content)) {
      const thinking = b.content.find((c: {type?: string}) => c.type === 'thinking');
      if (thinking?.thinking) return thinking.thinking;
    }
    
    return '';
  }

  const prompt = $derived(extractPrompt(log.requestBody));
  const responseContent = $derived(extractResponseContent(log.responseBody));
  const reasoningContent = $derived(extractReasoningContent(log.responseBody));

  // Tabs configuration
  const tabs = [
    { id: 'message', label: 'Message' },
    { id: 'request', label: 'Request' },
    { id: 'transformedRequest', label: 'T Req' },
    { id: 'response', label: 'Response' },
    { id: 'transformedResponse', label: 'T Res' },
    { id: 'metadata', label: 'Metadata' },
  ];
</script>

<div class="bg-white rounded-lg border border-gray-200 overflow-hidden">
  <!-- Collapsed Header -->
  <button
    type="button"
    class="w-full px-4 py-3 flex items-center gap-3 hover:bg-gray-50 transition-colors text-left"
    onclick={onToggle}
  >
    <!-- Expand Icon -->
    {#if isExpanded}
      <ChevronDown size={18} class="text-gray-400 flex-shrink-0" />
    {:else}
      <ChevronUp size={18} class="text-gray-400 flex-shrink-0 rotate-[-90deg]" />
    {/if}

    <!-- Status Icon -->
    <StatusIcon {status} />

    <!-- Model Info -->
    <div class="flex items-center gap-1 min-w-0">
      <span class="font-mono text-sm text-gray-900 truncate">{log.model}</span>
      <span class="text-gray-400">→</span>
      <span class="font-mono text-sm text-gray-600 truncate">{log.targetModel}</span>
    </div>

    <!-- Streaming Indicator -->
    {#if log.stream}
      <span class="flex-shrink-0" title="Streaming request">
        <span class="relative flex h-2 w-2">
          <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-blue-400 opacity-75"></span>
          <span class="relative inline-flex rounded-full h-2 w-2 bg-blue-500"></span>
        </span>
      </span>
    {/if}

    <!-- Spacer -->
    <div class="flex-1"></div>

    <!-- Time -->
    <span class="text-sm text-gray-500 flex-shrink-0">⏰ {formatTime(log.timestamp)}</span>
  </button>

  <!-- Collapsed Summary Line -->
  {#if !isExpanded}
    <div class="px-4 pb-3 flex items-center gap-3 text-sm">
      <!-- Provider -->
      <span class="flex items-center gap-1 text-gray-600 flex-shrink-0">
        <ExternalLink size={12} />
        {log.provider}
      </span>
      
      <!-- Prompt Preview -->
      <span class="text-gray-700 truncate flex-1" title={prompt}>
        {truncatePrompt(prompt, 60)}
      </span>
      
      <!-- Duration -->
      <span class="text-gray-500 flex-shrink-0">{formatDuration(log.durationMs)}</span>
      
      <!-- Status Code -->
      <span 
        class="px-2 py-0.5 rounded text-xs font-mono flex-shrink-0"
        class:bg-green-100={log.responseStatus < 400}
        class:text-green-700={log.responseStatus < 400}
        class:bg-red-100={log.responseStatus >= 400}
        class:text-red-700={log.responseStatus >= 400}
      >
        ({log.responseStatus})
      </span>
    </div>
  {/if}

  <!-- Expanded Content -->
  {#if isExpanded}
    <div class="border-t border-gray-200">
      <!-- Summary Line (also shown when expanded) -->
      <div class="px-4 py-2 flex items-center gap-3 text-sm bg-gray-50 border-b border-gray-200">
        <span class="flex items-center gap-1 text-gray-600">
          <ExternalLink size={12} />
          {log.provider}
        </span>
        <span class="text-gray-700 truncate flex-1" title={prompt}>
          {truncatePrompt(prompt, 80)}
        </span>
        <span class="text-gray-500">{formatDuration(log.durationMs)}</span>
        <span 
          class="px-2 py-0.5 rounded text-xs font-mono"
          class:bg-green-100={log.responseStatus < 400}
          class:text-green-700={log.responseStatus < 400}
          class:bg-red-100={log.responseStatus >= 400}
          class:text-red-700={log.responseStatus >= 400}
        >
          ({log.responseStatus})
        </span>
      </div>

      <!-- Tabs -->
      <div class="flex border-b border-gray-200 overflow-x-auto">
        {#each tabs as tab}
          <button
            type="button"
            onclick={() => onTabChange(tab.id)}
            class="px-4 py-2 text-sm font-medium border-b-2 transition-colors whitespace-nowrap"
            class:border-blue-500={activeTab === tab.id}
            class:text-blue-600={activeTab === tab.id}
            class:border-transparent={activeTab !== tab.id}
            class:text-gray-500={activeTab !== tab.id}
            class:hover:text-gray-700={activeTab !== tab.id}
          >
            {tab.label}
          </button>
        {/each}
      </div>

      <!-- Tab Content -->
      <div class="p-4">
        <!-- Message Tab -->
        {#if activeTab === 'message'}
          <div class="space-y-4">
            <!-- Prompt -->
            {#if prompt}
              <div class="bg-blue-50 rounded-lg p-4">
                <h4 class="text-sm font-medium text-blue-700 mb-2">Prompt</h4>
                <pre class="text-sm text-blue-900 whitespace-pre-wrap">{prompt}</pre>
              </div>
            {/if}
            
            <!-- Response -->
            <div>
              <h4 class="text-sm font-medium text-gray-700 mb-2">Response</h4>
              <MessageDisplay 
                content={responseContent}
                reasoningContent={reasoningContent}
                isStreaming={false}
              />
            </div>
          </div>
        {/if}

        <!-- Request Tab -->
        {#if activeTab === 'request'}
          <div class="space-y-3">
            <div class="flex flex-wrap gap-4 text-sm text-gray-500">
              <span>Format: <code class="bg-gray-100 px-1.5 py-0.5 rounded">{log.sourceScheme}</code></span>
              <span>Endpoint: <code class="bg-gray-100 px-1.5 py-0.5 rounded">{log.method} {log.path}</code></span>
            </div>
            <JsonViewer data={log.requestBody} />
          </div>
        {/if}

        <!-- Transformed Request Tab -->
        {#if activeTab === 'transformedRequest'}
          <div class="space-y-3">
            <div class="flex flex-wrap gap-4 text-sm text-gray-500">
              <span>Target Format: <code class="bg-gray-100 px-1.5 py-0.5 rounded">{log.targetScheme}</code></span>
              <span>Provider: <code class="bg-gray-100 px-1.5 py-0.5 rounded">{log.provider}</code></span>
            </div>
            {#if log.transformedBody}
              <JsonViewer data={log.transformedBody} />
            {:else}
              <p class="text-gray-500 italic">No transformation applied</p>
            {/if}
          </div>
        {/if}

        <!-- Response Tab (raw upstream) -->
        {#if activeTab === 'response'}
          <div class="space-y-3">
            <div class="flex flex-wrap gap-4 text-sm text-gray-500">
              <span>Original Format: <code class="bg-gray-100 px-1.5 py-0.5 rounded">{log.targetScheme}</code></span>
              <span>From: <code class="bg-gray-100 px-1.5 py-0.5 rounded">{log.provider}</code></span>
            </div>
            {#if log.rawUpstreamResponse}
              <JsonViewer data={log.rawUpstreamResponse} />
            {:else if log.responseBody}
              <JsonViewer data={log.responseBody} />
            {:else}
              <p class="text-gray-500 italic">No response captured</p>
            {/if}
          </div>
        {/if}

        <!-- Transformed Response Tab -->
        {#if activeTab === 'transformedResponse'}
          <div class="space-y-3">
            <div class="flex flex-wrap gap-4 text-sm text-gray-500">
              <span>Transformed Format: <code class="bg-gray-100 px-1.5 py-0.5 rounded">{log.sourceScheme}</code></span>
              <span>Status: <code class="bg-gray-100 px-1.5 py-0.5 rounded">{log.responseStatus}</code></span>
            </div>
            {#if log.transformedResponse}
              <JsonViewer data={log.transformedResponse} />
            {:else if log.responseBody}
              <JsonViewer data={log.responseBody} />
            {:else}
              <p class="text-gray-500 italic">No transformed response</p>
            {/if}
          </div>
        {/if}

        <!-- Metadata Tab -->
        {#if activeTab === 'metadata'}
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 text-sm">
            <div>
              <span class="text-gray-500 block text-xs uppercase tracking-wider">Request ID</span>
              <p class="font-mono text-xs break-all text-gray-900">{log.requestId}</p>
            </div>
            <div>
              <span class="text-gray-500 block text-xs uppercase tracking-wider">Provider URL</span>
              <p class="font-mono text-xs break-all text-gray-900" title={log.providerUrl}>
                {log.providerUrl || 'N/A'}
              </p>
            </div>
            <div>
              <span class="text-gray-500 block text-xs uppercase tracking-wider">Authentication</span>
              <p class="font-mono text-xs text-gray-900">
                {#if log.authScheme}
                  {log.authScheme.header}: {log.authScheme.prefix}{log.authScheme.maskedKey}
                {:else}
                  N/A
                {/if}
              </p>
            </div>
            <div>
              <span class="text-gray-500 block text-xs uppercase tracking-wider">Source Format</span>
              <p class="font-mono text-xs text-gray-900">{log.sourceScheme}</p>
            </div>
            <div>
              <span class="text-gray-500 block text-xs uppercase tracking-wider">Target Format</span>
              <p class="font-mono text-xs text-gray-900">{log.targetScheme}</p>
            </div>
            <div>
              <span class="text-gray-500 block text-xs uppercase tracking-wider">Matched Pattern</span>
              <p class="font-mono text-xs text-gray-900">{log.matchedPattern || 'N/A'}</p>
            </div>
            <div>
              <span class="text-gray-500 block text-xs uppercase tracking-wider">Duration</span>
              <p class="text-gray-900">{formatDuration(log.durationMs)}</p>
            </div>
            <div>
              <span class="text-gray-500 block text-xs uppercase tracking-wider">Timestamp</span>
              <p class="text-xs text-gray-900">{log.timestamp}</p>
            </div>
            <div>
              <span class="text-gray-500 block text-xs uppercase tracking-wider">Stream</span>
              <p class="text-gray-900">{log.stream ? 'Yes' : 'No'}</p>
            </div>
            {#if log.tokensPerSecond}
              <div>
                <span class="text-gray-500 block text-xs uppercase tracking-wider">Tokens/Second</span>
                <p class="text-gray-900">{log.tokensPerSecond}</p>
              </div>
            {/if}
          </div>
        {/if}
      </div>
    </div>
  {/if}
</div>
