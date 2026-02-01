<script lang="ts">
  import { onMount } from 'svelte';
  import { theme, type ThemeMode } from '../../lib/theme';
  
  let currentTheme: ThemeMode = 'premium';
  let isLoading = false;
  
  onMount(async () => {
    // Load theme from backend on mount
    await theme.init();
    currentTheme = theme.current;
  });
  
  async function handleThemeChange(mode: ThemeMode) {
    if (isLoading) return;
    
    isLoading = true;
    try {
      await theme.set(mode);
      currentTheme = mode;
    } catch (error) {
      console.error('[ThemeSwitcher] Failed to change theme:', error);
    } finally {
      isLoading = false;
    }
  }
</script>

<div class="theme-switcher">
  <div class="theme-buttons">
    <button
      class="theme-button"
      class:active={currentTheme === 'native'}
      disabled={isLoading}
      on:click={() => handleThemeChange('native')}
    >
      <span class="theme-icon">🎨</span>
      <span class="theme-label">Native</span>
    </button>
    
    <button
      class="theme-button"
      class:active={currentTheme === 'premium'}
      disabled={isLoading}
      on:click={() => handleThemeChange('premium')}
    >
      <span class="theme-icon">✨</span>
      <span class="theme-label">Premium</span>
    </button>
    
    <button
      class="theme-button"
      class:active={currentTheme === 'mixed'}
      disabled={isLoading}
      on:click={() => handleThemeChange('mixed')}
    >
      <span class="theme-icon">🎭</span>
      <span class="theme-label">Mixed</span>
    </button>
  </div>
</div>

<style>
  .theme-switcher {
    display: inline-block;
  }
  
  .theme-buttons {
    display: flex;
    gap: var(--space-sm, 8px);
    padding: var(--space-xs, 4px);
    background: var(--glass-bg, rgba(255, 255, 255, 0.05));
    backdrop-filter: blur(var(--glass-blur, 12px));
    -webkit-backdrop-filter: blur(var(--glass-blur, 12px));
    border: 1px solid var(--glass-border, rgba(255, 255, 255, 0.1));
    border-radius: var(--radius-full, 9999px);
  }
  
  .theme-button {
    display: flex;
    align-items: center;
    gap: var(--space-xs, 4px);
    padding: var(--space-sm, 8px) var(--space-md, 16px);
    background: transparent;
    border: none;
    border-radius: var(--radius-full, 9999px);
    color: var(--color-text-secondary, #a0a0b0);
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
  }
  
  .theme-button:hover:not(:disabled) {
    background: var(--glass-bg, rgba(255, 255, 255, 0.05));
    color: var(--color-text-primary, #ffffff);
  }
  
  .theme-button.active {
    background: var(--gradient-primary, linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%));
    color: var(--color-text-primary, #ffffff);
    box-shadow: var(--shadow-glow, 0 0 32px rgba(99, 102, 241, 0.4));
  }
  
  .theme-button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  
  .theme-icon {
    font-size: 16px;
  }
  
  .theme-label {
    font-size: 14px;
  }
  
  @media (max-width: 640px) {
    .theme-label {
      display: none;
    }
    
    .theme-button {
      padding: var(--space-sm, 8px);
    }
  }
</style>
