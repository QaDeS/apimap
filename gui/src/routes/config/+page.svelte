<script lang="ts">
  import { onMount } from 'svelte';
  import { beforeNavigate } from '$app/navigation';
  import {
    Settings,
    Save, 
    AlertCircle, 
    CheckCircle,
    Download,
    Upload,
    RotateCcw,
    Trash2,
    Edit2,
    X,
    Check,
    Clock,
    FileText
  } from '@lucide/svelte';
  import { config, isLoadingConfig } from '$lib/stores';
  import { configApi, backupApi } from '$lib/utils/api';
  import type { ConfigBackup } from '$lib/utils/api';
  import YAML from 'yaml';

  let configYaml = $state('');
  let hasChanges = $state(false);
  let saveError: string | null = $state(null);
  let saveSuccess = $state(false);
  let parseError: string | null = $state(null);

  // Backup state
  let backups: ConfigBackup[] = $state([]);
  let activeBackup: string | null = $state(null);
  let isLoadingBackups = $state(false);
  let backupError: string | null = $state(null);
  let backupSuccess = $state(false);
  let restoringFilename: string | null = $state(null);
  let deletingFilename: string | null = $state(null);

  // Editing state
  let editingNameFilename: string | null = $state(null);
  let editingNameValue = $state('');

  async function loadConfig() {
    isLoadingConfig.set(true);
    try {
      const data = await configApi.get();
      config.set(data);
      configYaml = YAML.stringify(data);
      parseError = null;
    } catch (err) {
      console.error('Failed to load config:', err);
      saveError = err instanceof Error ? err.message : 'Failed to load config';
    } finally {
      isLoadingConfig.set(false);
    }
  }

  async function loadBackups() {
    isLoadingBackups = true;
    try {
      const data = await backupApi.list();
      backups = data.backups;
      activeBackup = data.activeBackup;
    } catch (err) {
      backupError = err instanceof Error ? err.message : 'Failed to load backups';
    } finally {
      isLoadingBackups = false;
    }
  }

  function onConfigChange(newValue: string) {
    configYaml = newValue;
    hasChanges = true;
    saveSuccess = false;
    
    // Validate YAML
    try {
      YAML.parse(newValue);
      parseError = null;
    } catch (err) {
      parseError = err instanceof Error ? err.message : 'Invalid YAML';
    }
  }

  async function saveConfig() {
    if (parseError) return;
    
    saveError = null;
    try {
      const parsed = YAML.parse(configYaml);
      await configApi.save(parsed);
      hasChanges = false;
      saveSuccess = true;
      setTimeout(() => saveSuccess = false, 3000);
      await loadBackups();
    } catch (err) {
      saveError = err instanceof Error ? err.message : 'Failed to save config';
    }
  }

  async function restoreBackup(filename: string) {
    if (!confirm(`Restore this version? Your current config will be backed up first.`)) {
      return;
    }
    
    restoringFilename = filename;
    backupError = null;
    try {
      await backupApi.restore(filename);
      backupSuccess = true;
      setTimeout(() => backupSuccess = false, 3000);
      await loadConfig();
      await loadBackups();
    } catch (err) {
      backupError = err instanceof Error ? err.message : 'Failed to restore backup';
    } finally {
      restoringFilename = null;
    }
  }

  async function deleteBackup(filename: string) {
    if (!confirm(`Delete this version?`)) {
      return;
    }
    
    deletingFilename = filename;
    backupError = null;
    try {
      await backupApi.delete(filename);
      await loadBackups();
    } catch (err) {
      backupError = err instanceof Error ? err.message : 'Failed to delete backup';
    } finally {
      deletingFilename = null;
    }
  }

  function startEditingName(backup: ConfigBackup) {
    editingNameFilename = backup.filename;
    editingNameValue = backup.name || '';
  }

  function cancelEditingName() {
    editingNameFilename = null;
    editingNameValue = '';
  }

  async function saveBackupName(filename: string) {
    backupError = null;
    try {
      await backupApi.update(filename, { name: editingNameValue });
      await loadBackups();
      cancelEditingName();
    } catch (err) {
      backupError = err instanceof Error ? err.message : 'Failed to rename backup';
    }
  }

  function downloadConfig() {
    const blob = new Blob([configYaml], { type: 'text/yaml' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `apimap-config-${new Date().toISOString().split('T')[0]}.yaml`;
    a.click();
    URL.revokeObjectURL(url);
  }

  function handleFileUpload(event: Event) {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const content = e.target?.result as string;
        onConfigChange(content);
      };
      reader.readAsText(file);
    }
  }

  function formatSize(bytes: number): string {
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  function formatDate(dateStr: string): string {
    return new Date(dateStr).toLocaleString();
  }

  function getBackupDisplayName(backup: ConfigBackup): string {
    if (backup.name) return backup.name;
    return backup.filename.replace(/\.ya?ml$/, '');
  }

  function getActiveBackupDisplayName(): string {
    if (!activeBackup) return '';
    const backup = backups.find(b => b.filename === activeBackup);
    if (backup) return getBackupDisplayName(backup);
    return activeBackup.replace(/\.ya?ml$/, '');
  }

  function scrollToBackup(filename: string) {
    const el = document.getElementById(`backup-${filename}`);
    if (el) {
      el.scrollIntoView({ behavior: 'smooth', block: 'center' });
      // Briefly highlight
      el.classList.add('bg-blue-100');
      setTimeout(() => el.classList.remove('bg-blue-100'), 1500);
    }
  }

  function isRestoredFromOldBackup(): boolean {
    return !!activeBackup && activeBackup !== backups[0]?.filename;
  }

  // Warn on unsaved changes
  beforeNavigate(({ cancel }) => {
    if (hasChanges && !confirm('You have unsaved configuration changes. Leave without saving?')) {
      cancel();
    }
  });

  function handleBeforeUnload(e: BeforeUnloadEvent) {
    if (hasChanges) {
      e.preventDefault();
    }
  }

  onMount(() => {
    loadConfig();
    loadBackups();
  });
</script>

<svelte:window onbeforeunload={handleBeforeUnload} />

<svelte:head>
  <title>Configuration - API Map</title>
</svelte:head>

<div class="space-y-6">
  <!-- Header -->
  <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
    <div>
      <h1 class="text-2xl font-bold text-gray-900">Configuration</h1>
      <p class="text-gray-600 mt-1">Edit the router configuration YAML directly</p>
    </div>
    <div class="flex gap-3">
      <button
        type="button"
        onclick={downloadConfig}
        class="flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 font-medium rounded-lg hover:bg-gray-200 transition-colors"
      >
        <Download size={18} />
        Download
      </button>
      <label class="flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 font-medium rounded-lg hover:bg-gray-200 transition-colors cursor-pointer">
        <Upload size={18} />
        Upload
        <input
          type="file"
          accept=".yaml,.yml"
          onchange={handleFileUpload}
          class="hidden"
        />
      </label>
      <button
        type="button"
        onclick={saveConfig}
        disabled={!hasChanges || !!parseError}
        class="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
      >
        <Save size={18} />
        Save Changes
      </button>
    </div>
  </div>

  {#if saveError}
    <div class="bg-red-50 border border-red-200 rounded-lg p-4 flex items-center gap-3 text-red-700">
      <AlertCircle size={20} />
      {saveError}
    </div>
  {/if}

  {#if saveSuccess}
    <div class="bg-green-50 border border-green-200 rounded-lg p-4 flex items-center gap-3 text-green-700">
      <CheckCircle size={20} />
      Configuration saved successfully!
    </div>
  {/if}

  {#if backupError}
    <div class="bg-red-50 border border-red-200 rounded-lg p-4 flex items-center gap-3 text-red-700">
      <AlertCircle size={20} />
      {backupError}
    </div>
  {/if}

  {#if backupSuccess}
    <div class="bg-green-50 border border-green-200 rounded-lg p-4 flex items-center gap-3 text-green-700">
      <CheckCircle size={20} />
      Version restored successfully!
    </div>
  {/if}

  {#if parseError}
    <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 flex items-center gap-3 text-yellow-700">
      <AlertCircle size={20} />
      <div>
        <p class="font-medium">YAML Parse Error</p>
        <p class="text-sm">{parseError}</p>
      </div>
    </div>
  {/if}

  {#if $isLoadingConfig}
    <div class="text-center py-12 text-gray-500">Loading configuration...</div>
  {:else}
    <div class="grid grid-cols-1 xl:grid-cols-4 gap-6">
      <!-- Editor -->
      <div class="xl:col-span-3 space-y-6">
        <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
          <div class="px-6 py-4 border-b border-gray-200 bg-gray-50 flex items-center justify-between">
            <div class="flex items-center gap-3">
              <Settings class="text-blue-600" size={24} />
              <h2 class="text-lg font-semibold text-gray-900">config.yaml</h2>
            </div>
            {#if hasChanges}
              <span class="text-sm text-amber-600 font-medium">Unsaved changes</span>
            {/if}
          </div>

          <div class="p-0">
            <textarea
              value={configYaml}
              oninput={(e) => onConfigChange(e.currentTarget.value)}
              class="w-full h-[600px] p-6 font-mono text-sm bg-gray-900 text-gray-100 resize-none focus:outline-none"
              spellcheck="false"
              aria-label="Configuration YAML"
            ></textarea>
          </div>
        </div>

        <!-- Help Section -->
        <div class="bg-blue-50 rounded-xl border border-blue-200 p-6">
          <h3 class="font-semibold text-blue-900 mb-3 flex items-center gap-2">
            <AlertCircle size={20} />
            Configuration Reference
          </h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-blue-800">
            <div>
              <h4 class="font-medium mb-2">Server Settings</h4>
              <ul class="space-y-1 list-disc list-inside">
                <li><code>server.port</code> - HTTP port (default: 3000)</li>
                <li><code>server.externalPort</code> - External port for Docker/reverse proxy</li>
                <li><code>server.externalHost</code> - External hostname for reverse proxy</li>
                <li><code>server.host</code> - Bind address (default: 0.0.0.0)</li>
                <li><code>server.timeout</code> - Request timeout in seconds (default: 120)</li>
                <li><code>server.cors.origin</code> - CORS allowed origins</li>
              </ul>
            </div>
            <div>
              <h4 class="font-medium mb-2">Provider Settings</h4>
              <ul class="space-y-1 list-disc list-inside">
                <li><code>baseUrl</code> - Provider API endpoint</li>
                <li><code>apiKey</code> - Direct API key (optional)</li>
                <li><code>apiKeyEnv</code> - Environment variable name</li>
                <li><code>authHeader</code> - Authentication header name</li>
                <li><code>authPrefix</code> - Authentication prefix (e.g., "Bearer ")</li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      <!-- Version List -->
      <div class="xl:col-span-1">
        <div class="bg-white rounded-xl border border-gray-200 overflow-hidden sticky top-6">
          <div class="px-4 py-3 border-b border-gray-200 bg-gray-50">
            <h2 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">Versions</h2>
          </div>

          <div class="max-h-[600px] overflow-y-auto">
            <!-- Current Config -->
            <div class="px-4 py-3 border-b border-gray-200 bg-green-50/60">
              <div class="flex items-center justify-between gap-2">
                <div class="min-w-0 flex-1">
                  <div class="flex items-center gap-2">
                    <span class="font-medium text-sm text-gray-900 truncate">Current Config</span>
                    <span class="px-1.5 py-0.5 bg-green-200 text-green-800 text-[10px] font-bold rounded uppercase tracking-wider">Active</span>
                  </div>
                  {#if isRestoredFromOldBackup()}
                    <button
                      type="button"
                      onclick={() => activeBackup && scrollToBackup(activeBackup)}
                      class="text-[11px] text-blue-600 mt-0.5 truncate text-left hover:underline"
                      title="Jump to restored version: {getActiveBackupDisplayName()}"
                    >
                      Restored: {getActiveBackupDisplayName()}
                    </button>
                  {:else if hasChanges}
                    <p class="text-[11px] text-amber-600 mt-0.5">Unsaved changes</p>
                  {:else}
                    <p class="text-[11px] text-gray-500 mt-0.5">Running configuration</p>
                  {/if}
                </div>
                <div class="shrink-0">
                  <FileText class="text-green-600" size={16} />
                </div>
              </div>
            </div>

            <!-- Backups -->
            {#if isLoadingBackups && backups.length === 0}
              <div class="p-3 text-center text-gray-500 text-xs">Loading...</div>
            {:else if backups.length === 0}
              <div class="p-4 text-center text-gray-500 text-xs">
                No saved versions yet.
                <br />Save changes to create one.
              </div>
            {:else}
              <div class="divide-y divide-gray-100">
                {#each backups as backup}
                  <div id="backup-{backup.filename}" class="px-4 py-2 hover:bg-gray-50 transition-colors {activeBackup === backup.filename ? 'bg-emerald-100 border-l-4 border-emerald-500' : ''}">
                    <!-- Name / Edit Name -->
                    {#if editingNameFilename === backup.filename}
                      <div class="flex items-center gap-1">
                        <input
                          type="text"
                          bind:value={editingNameValue}
                          placeholder="Name"
                          class="flex-1 min-w-0 px-1.5 py-0.5 text-xs border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500"
                          onkeydown={(e) => {
                            if (e.key === 'Enter') saveBackupName(backup.filename);
                            if (e.key === 'Escape') cancelEditingName();
                          }}
                        />
                        <button
                          type="button"
                          onclick={() => saveBackupName(backup.filename)}
                          class="p-0.5 text-green-600 hover:bg-green-50 rounded"
                        >
                          <Check size={12} />
                        </button>
                        <button
                          type="button"
                          onclick={cancelEditingName}
                          class="p-0.5 text-gray-500 hover:bg-gray-100 rounded"
                        >
                          <X size={12} />
                        </button>
                      </div>
                    {:else}
                      <div class="flex items-center justify-between gap-2 group">
                        <span class="font-medium text-sm text-gray-900 truncate" title={getBackupDisplayName(backup)}>
                          {getBackupDisplayName(backup)}
                        </span>
                        <div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                          {#if activeBackup === backup.filename}
                            <span class="px-1.5 py-0.5 bg-emerald-600 text-white text-[10px] font-bold rounded uppercase tracking-wider shadow-sm">Restored</span>
                          {/if}
                          <button
                            type="button"
                            onclick={() => startEditingName(backup)}
                            class="p-0.5 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded"
                            title="Rename"
                          >
                            <Edit2 size={12} />
                          </button>
                        </div>
                      </div>
                    {/if}

                    <!-- Meta + Actions -->
                    <div class="flex items-center justify-between mt-1">
                      <div class="flex items-center gap-2 text-[11px] text-gray-500">
                        <span class="flex items-center gap-0.5">
                          <Clock size={10} />
                          {formatDate(backup.createdAt)}
                        </span>
                        <span>{formatSize(backup.size)}</span>
                      </div>
                      <div class="flex items-center gap-0.5">
                        <button
                          type="button"
                          onclick={() => restoreBackup(backup.filename)}
                          disabled={restoringFilename === backup.filename}
                          class="p-1 text-blue-600 hover:bg-blue-50 rounded transition-colors disabled:opacity-50"
                          title="Restore"
                        >
                          <RotateCcw size={14} />
                        </button>
                        <button
                          type="button"
                          onclick={() => deleteBackup(backup.filename)}
                          disabled={deletingFilename === backup.filename}
                          class="p-1 text-red-500 hover:bg-red-50 rounded transition-colors disabled:opacity-50"
                          title="Delete"
                        >
                          <Trash2 size={14} />
                        </button>
                      </div>
                    </div>
                  </div>
                {/each}
              </div>
            {/if}
          </div>
        </div>
      </div>
    </div>
  {/if}
</div>
