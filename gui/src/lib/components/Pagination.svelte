<script lang="ts">
  interface Props {
    currentPage: number;
    totalPages: number;
    itemsPerPage: number;
    onPageChange: (page: number) => void;
    onItemsPerPageChange: (value: number) => void;
  }

  let {
    currentPage,
    totalPages,
    itemsPerPage,
    onPageChange,
    onItemsPerPageChange
  }: Props = $props();

  function getPageNumbers(): (number | string)[] {
    const pages: (number | string)[] = [];
    
    if (totalPages <= 7) {
      for (let i = 1; i <= totalPages; i++) {
        pages.push(i);
      }
    } else {
      // Always show first page
      pages.push(1);
      
      if (currentPage > 3) {
        pages.push('...');
      }
      
      // Show pages around current
      const start = Math.max(2, currentPage - 1);
      const end = Math.min(totalPages - 1, currentPage + 1);
      
      for (let i = start; i <= end; i++) {
        if (!pages.includes(i)) {
          pages.push(i);
        }
      }
      
      if (currentPage < totalPages - 2) {
        pages.push('...');
      }
      
      // Always show last page
      if (!pages.includes(totalPages)) {
        pages.push(totalPages);
      }
    }
    
    return pages;
  }

  function goToPage(page: number) {
    if (page >= 1 && page <= totalPages && page !== currentPage) {
      onPageChange(page);
    }
  }
</script>

<div class="flex items-center justify-between">
  <!-- Page Numbers -->
  <div class="flex items-center gap-1">
    <button
      onclick={() => goToPage(currentPage - 1)}
      disabled={currentPage === 1}
      class="px-3 py-1.5 rounded-lg text-sm font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
      class:bg-gray-100={currentPage !== 1}
      class:hover:bg-gray-200={currentPage !== 1}
      class:text-gray-700={currentPage !== 1}
    >
      ←
    </button>

    {#each getPageNumbers() as page}
      {#if page === '...'}
        <span class="px-2 py-1.5 text-gray-500">...</span>
      {:else}
        <button
          onclick={() => goToPage(page as number)}
          class="px-3 py-1.5 rounded-lg text-sm font-medium transition-colors"
          class:bg-blue-600={page === currentPage}
          class:text-white={page === currentPage}
          class:bg-gray-100={page !== currentPage}
          class:hover:bg-gray-200={page !== currentPage}
          class:text-gray-700={page !== currentPage}
        >
          {page}
        </button>
      {/if}
    {/each}

    <button
      onclick={() => goToPage(currentPage + 1)}
      disabled={currentPage === totalPages}
      class="px-3 py-1.5 rounded-lg text-sm font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
      class:bg-gray-100={currentPage !== totalPages}
      class:hover:bg-gray-200={currentPage !== totalPages}
      class:text-gray-700={currentPage !== totalPages}
    >
      →
    </button>
  </div>

  <!-- Items Per Page -->
  <select
    value={itemsPerPage}
    onchange={(e) => onItemsPerPageChange(parseInt(e.currentTarget.value))}
    class="px-3 py-1.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm bg-white"
  >
    <option value={10}>10 per page</option>
    <option value={25}>25 per page</option>
    <option value={50}>50 per page</option>
    <option value={100}>100 per page</option>
  </select>
</div>
