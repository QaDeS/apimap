<script lang="ts">
  import { onMount } from 'svelte';
  import { AlertTriangle, CheckCircle, Activity, Clock, Server, Route, Zap, Plus, X, Eye, RefreshCw } from '@lucide/svelte';
  
  import { resolveApiUrl } from '$lib/utils/api';
  const API_URL = resolveApiUrl();

  // Check if we're in dev mode (Vite env)
  const isDev = import.meta.env.DEV;

  // Simple local state
  let status = $state<any>(null);
  let unrouted: any[] = $state([]);
  let loading = $state(true);
  let error = $state<string | null>(null);
  let apiUrl = $state<string>(API_URL);

  // Fetch with timeout
  async function fetchWithTimeout(url: string, options: RequestInit = {}, timeoutMs = 5000): Promise<Response> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      clearTimeout(timeoutId);
      return response;
    } catch (err) {
      clearTimeout(timeoutId);
      if (err instanceof Error && err.name === 'AbortError') {
        throw new Error(`Request timeout after ${timeoutMs}ms - API server not responding`);
      }
      throw err;
    }
  }

  async function loadData() {
    console.log('Loading data from:', API_URL);
    try {
      const res = await fetchWithTimeout(`${API_URL}/admin/status`);
      if (!res.ok) throw new Error(`Failed to load status: HTTP ${res.status}`);
      status = await res.json();
      error = null; // Clear any previous error
      
      const unroutedRes = await fetchWithTimeout(`${API_URL}/admin/unrouted`);
      if (unroutedRes.ok) {
        const data = await unroutedRes.json();
        unrouted = data.unrouted;
      }
    } catch (err) {
      console.error('Failed to load data:', err);
      error = err instanceof Error ? err.message : 'Unknown error';
    } finally {
      loading = false;
    }
  }

  function retry() {
    loading = true;
    error = null;
    loadData();
  }

  onMount(() => {
    loadData();
    const interval = setInterval(loadData, 5000);
    return () => clearInterval(interval);
  });
</script>

<div class="space-y-6">
  <div>
    <h1 class="text-2xl font-bold text-gray-900">Dashboard</h1>
    <p class="text-gray-600 mt-1">Overview of your model router</p>
  </div>

  {#if loading}
    <div class="text-center py-12 text-gray-500">
      <div class="inline-block animate-spin mr-2">
        <RefreshCw size={20} />
      </div>
      Connecting to API at {apiUrl}...
    </div>
  {:else if error}
    <div class="bg-red-50 border border-red-200 rounded-lg p-4">
      <div class="flex items-start gap-3">
        <AlertTriangle class="text-red-500 flex-shrink-0 mt-0.5" size={20} />
        <div class="flex-1">
          <h3 class="font-medium text-red-800">Connection Error</h3>
          {#if isDev}
            <!-- Detailed error in dev mode -->
            <p class="text-red-700 text-sm mt-1">{error}</p>
            <p class="text-red-600 text-xs mt-2">API URL: {apiUrl}</p>
          {:else}
            <!-- Generic error in production -->
            <p class="text-red-700 text-sm mt-1">Unable to connect to the API server. Please try again later.</p>
          {/if}
          
          {#if isDev && (error.includes('timeout') || error.includes('Failed to fetch') || error.includes('NetworkError'))}
            <div class="mt-3 bg-yellow-50 border border-yellow-200 rounded-lg p-3">
              <p class="text-yellow-800 text-sm font-medium">API Server Not Running?</p>
              <p class="text-yellow-700 text-xs mt-1">
                The GUI requires the API server to be running. Try one of these:
              </p>
              <ul class="text-yellow-700 text-xs mt-1 ml-4 list-disc">
                <li>Run from project root: <code class="bg-yellow-100 px-1 rounded">bun run dev</code></li>
                <li>Or run API separately: <code class="bg-yellow-100 px-1 rounded">bun run start</code></li>
              </ul>
            </div>
          {/if}
          
          <button 
            onclick={retry}
            class="mt-3 px-3 py-1.5 bg-red-100 hover:bg-red-200 text-red-700 text-sm font-medium rounded-lg flex items-center gap-2 transition-colors"
          >
            <RefreshCw size={14} />
            Retry
          </button>
        </div>
      </div>
    </div>
  {:else if status}
    <!-- Stats Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <div class="bg-white rounded-xl border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">Total Requests</p>
            <p class="text-2xl font-bold text-gray-900 mt-1">{status.totalRequests.toLocaleString()}</p>
          </div>
          <div class="w-12 h-12 bg-blue-50 rounded-lg flex items-center justify-center">
            <Activity class="text-blue-600" size={24} />
          </div>
        </div>
      </div>

      <div class="bg-white rounded-xl border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">Routed</p>
            <p class="text-2xl font-bold text-green-600 mt-1">{status.routedRequests.toLocaleString()}</p>
          </div>
          <div class="w-12 h-12 bg-green-50 rounded-lg flex items-center justify-center">
            <CheckCircle class="text-green-600" size={24} />
          </div>
        </div>
      </div>

      <div class="bg-white rounded-xl border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">Unrouted</p>
            <p class="text-2xl font-bold {status.unroutedRequests > 0 ? 'text-red-600' : 'text-gray-900'} mt-1">
              {status.unroutedRequests.toLocaleString()}
            </p>
          </div>
          <div class="w-12 h-12 rounded-lg flex items-center justify-center {status.unroutedRequests > 0 ? 'bg-red-50' : 'bg-gray-50'}">
            <AlertTriangle class={status.unroutedRequests > 0 ? 'text-red-600' : 'text-gray-400'} size={24} />
          </div>
        </div>
      </div>

      <div class="bg-white rounded-xl border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">Avg Latency</p>
            <p class="text-2xl font-bold text-gray-900 mt-1">{status.averageLatency}ms</p>
          </div>
          <div class="w-12 h-12 bg-purple-50 rounded-lg flex items-center justify-center">
            <Clock class="text-purple-600" size={24} />
          </div>
        </div>
      </div>
    </div>

    <!-- Unrouted Requests -->
    {#if unrouted.length > 0}
      <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <AlertTriangle class="text-red-500" size={24} />
            <div>
              <h2 class="text-lg font-semibold text-gray-900">Unrouted Requests</h2>
              <p class="text-sm text-gray-600">These requests couldn't be routed</p>
            </div>
          </div>
        </div>

        <div class="divide-y divide-gray-200">
          {#each unrouted.slice(0, 5) as request}
            <div class="p-4">
              <div class="flex items-center justify-between">
                <div>
                  <span class="font-mono text-sm font-medium text-gray-900">{request.model}</span>
                  <div class="text-sm text-gray-500 mt-1">
                    {request.endpoint} · {new Date(request.timestamp).toLocaleTimeString()}
                  </div>
                </div>
              </div>
            </div>
          {/each}
        </div>
      </div>
    {/if}
  {/if}
</div>
