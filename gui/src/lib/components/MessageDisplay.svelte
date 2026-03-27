<script lang="ts">
  import { Brain, ChevronDown, ChevronUp } from '@lucide/svelte';
  
  interface Props {
    content: string;
    reasoningContent?: string;
    isStreaming?: boolean;
    class?: string;
  }
  
  let { 
    content, 
    reasoningContent = '', 
    isStreaming = false,
    class: className = ''
  }: Props = $props();
  
  let reasoningExpanded = $state(true);
  
  // Auto-expand reasoning when new content arrives, collapse when cleared
  $effect(() => {
    if (reasoningContent) {
      reasoningExpanded = true;
    }
  });
</script>

<div class="space-y-4 {className}">
  <!-- Reasoning Content (Thinking) - Collapsible Grey Box -->
  {#if reasoningContent}
    <div class="bg-gray-50 border border-gray-200 rounded-lg overflow-hidden">
      <button
        onclick={() => reasoningExpanded = !reasoningExpanded}
        class="w-full px-4 py-3 flex items-center justify-between text-sm font-medium text-gray-700 hover:bg-gray-100 transition-colors"
        aria-expanded={reasoningExpanded}
      >
        <div class="flex items-center gap-2">
          <Brain size={16} class="text-gray-500" />
          <span>Reasoning</span>
          <span class="text-xs text-gray-400 italic">(model's thought process)</span>
        </div>
        {#if reasoningExpanded}
          <ChevronUp size={16} class="text-gray-400" />
        {:else}
          <ChevronDown size={16} class="text-gray-400" />
        {/if}
      </button>
      {#if reasoningExpanded}
        <div class="px-4 pb-4 border-t border-gray-100">
          <div class="pt-3 prose prose-sm max-w-none">
            <div class="whitespace-pre-wrap text-gray-600 text-sm leading-relaxed italic font-serif">
              {reasoningContent}
              {#if isStreaming}
                <span class="text-gray-400 not-italic">thinking...</span>
              {/if}
            </div>
          </div>
        </div>
      {/if}
    </div>
  {/if}

  <!-- Main Content -->
  {#if content || isStreaming}
    <div class="prose prose-sm max-w-none">
      <div class="whitespace-pre-wrap text-gray-800 leading-relaxed">
        {content}
        {#if isStreaming}
          <span class="inline-block w-2 h-4 bg-blue-500 ml-1 animate-pulse"></span>
        {/if}
      </div>
    </div>
  {/if}
</div>
