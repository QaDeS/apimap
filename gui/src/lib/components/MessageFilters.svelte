<script lang="ts">
  import { Search } from '@lucide/svelte';
  import type { ProviderInfo } from '$lib/utils/api';

  interface Props {
    search: string;
    status: 'all' | 'streaming' | 'pending' | 'completed' | 'error' | 'unrouted';
    provider: string;
    timeRange: '1h' | '24h' | '7d' | 'all';
    providers: ProviderInfo[];
    filteredCount: number;
    totalCount: number;
    onSearchChange: (value: string) => void;
    onStatusChange: (value: 'all' | 'streaming' | 'pending' | 'completed' | 'error' | 'unrouted') => void;
    onProviderChange: (value: string) => void;
    onTimeRangeChange: (value: '1h' | '24h' | '7d' | 'all') => void;
  }

  let {
    search,
    status,
    provider,
    timeRange,
    providers,
    filteredCount,
    totalCount,
    onSearchChange,
    onStatusChange,
    onProviderChange,
    onTimeRangeChange
  }: Props = $props();
</script>

<div class="bg-white rounded-xl border border-gray-200 p-4">
  <div class="flex flex-col lg:flex-row gap-4 items-stretch lg:items-center">
    <!-- Search -->
    <div class="relative flex-1">
      <Search class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
      <input
        type="text"
        placeholder="Search model, provider, request ID..."
        value={search}
        oninput={(e) => onSearchChange(e.currentTarget.value)}
        class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
      />
    </div>

    <!-- Filters -->
    <div class="flex flex-wrap gap-2 items-center">
      <select
        value={status}
        onchange={(e) => onStatusChange(e.currentTarget.value as typeof status)}
        class="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm bg-white"
      >
        <option value="all">All Status</option>
        <option value="streaming">Streaming</option>
        <option value="pending">Pending</option>
        <option value="completed">Completed</option>
        <option value="error">Error</option>
        <option value="unrouted">Unrouted</option>
      </select>

      <select
        value={provider}
        onchange={(e) => onProviderChange(e.currentTarget.value)}
        class="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm bg-white"
      >
        <option value="all">All Providers</option>
        {#each providers as p}
          <option value={p.id}>{p.name}</option>
        {/each}
      </select>

      <select
        value={timeRange}
        onchange={(e) => onTimeRangeChange(e.currentTarget.value as typeof timeRange)}
        class="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm bg-white"
      >
        <option value="1h">Last Hour</option>
        <option value="24h">Last 24h</option>
        <option value="7d">Last 7 Days</option>
        <option value="all">All Time</option>
      </select>

      <!-- Counter -->
      <span class="text-sm text-gray-500 ml-2">
        {filteredCount.toLocaleString()}/{totalCount.toLocaleString()}
      </span>
    </div>
  </div>
</div>
