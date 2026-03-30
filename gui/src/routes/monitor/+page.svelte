<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  
  onMount(() => {
    goto('/');
  });
</script>

<div class="flex items-center justify-center h-64">
  <p class="text-gray-500">Redirecting to Dashboard...</p>
</div>
