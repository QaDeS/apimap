<script lang="ts">
  import { CheckCircle, XCircle, Clock, Activity, AlertTriangle } from '@lucide/svelte';

  interface Props {
    status: 'completed' | 'error' | 'pending' | 'streaming' | 'unrouted';
    size?: number;
  }

  let { status, size = 16 }: Props = $props();

  const colors = {
    completed: 'text-green-600',
    error: 'text-red-600',
    pending: 'text-amber-600',
    streaming: 'text-blue-600',
    unrouted: 'text-orange-600',
  };

  const icons = {
    completed: CheckCircle,
    error: XCircle,
    pending: Clock,
    streaming: Activity,
    unrouted: AlertTriangle,
  };

  const labels = {
    completed: 'Completed',
    error: 'Error',
    pending: 'Pending',
    streaming: 'Streaming',
    unrouted: 'Unrouted',
  };
</script>

<span class="inline-flex items-center gap-1.5 {colors[status]}" title={labels[status]}>
  {#if status === 'streaming'}
    <span class="relative flex h-3 w-3">
      <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-blue-400 opacity-75"></span>
      <span class="relative inline-flex rounded-full h-3 w-3 bg-blue-500"></span>
    </span>
  {:else}
    {@const Icon = icons[status]}
    <Icon {size} />
  {/if}
</span>
