<script lang="ts">
  interface Props {
    data: unknown;
    maxHeight?: string;
  }

  let { data, maxHeight = '24rem' }: Props = $props();

  function formatJson(obj: unknown): string {
    if (obj === undefined || obj === null) return 'null';
    try {
      return JSON.stringify(obj, null, 2);
    } catch {
      return String(obj);
    }
  }
</script>

<div 
  class="bg-gray-900 rounded-lg p-4 overflow-x-auto overflow-y-auto"
  style="max-height: {maxHeight}"
>
  <pre class="text-sm text-gray-100 font-mono whitespace-pre-wrap">{formatJson(data)}</pre>
</div>
