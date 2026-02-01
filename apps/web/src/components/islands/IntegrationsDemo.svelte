<script lang="ts">
  import { onMount } from 'svelte';
  import { api } from '../../lib/api';
  import { theme, type ThemeMode } from '../../lib/theme';
  import tg from '../../lib/tg';
  
  // Auth state
  let isAuthenticated = false;
  let isAuthenticating = false;
  let authError = '';
  let userInfo: {
    id: number;
    telegram_id: number;
    first_name: string;
    last_name?: string;
    username?: string;
  } | null = null;
  
  // Preferences state
  let preferences: {
    theme_mode: ThemeMode;
    reduced_motion: boolean;
  } | null = null;
  let isLoadingPrefs = false;
  let isSavingPrefs = false;
  let prefsError = '';
  let prefsSuccess = '';
  
  // Form state
  let selectedTheme: ThemeMode = 'premium';
  let reducedMotion = false;
  
  onMount(async () => {
    // Try to load preferences (will fail if not authenticated)
    await loadPreferences();
  });
  
  async function authenticate() {
    isAuthenticating = true;
    authError = '';
    
    try {
      // Get initData from Telegram
      const initData = tg.getInitData();
      
      if (!initData) {
        // Fallback for browser testing
        authError = 'Not running in Telegram. Using mock authentication for demo.';
        // In a real scenario, you'd need actual initData
        // For demo purposes, we'll show the error
        isAuthenticating = false;
        return;
      }
      
      // Validate with backend
      const response = await api.auth.validate(initData);
      
      if (response.success) {
        isAuthenticated = true;
        userInfo = response.user;
        
        // Load preferences after successful auth
        await loadPreferences();
      }
    } catch (error) {
      authError = error instanceof Error ? error.message : 'Authentication failed';
      console.error('[IntegrationsDemo] Auth error:', error);
    } finally {
      isAuthenticating = false;
    }
  }
  
  async function loadPreferences() {
    isLoadingPrefs = true;
    prefsError = '';
    
    try {
      preferences = await api.preferences.get();
      
      // Update form state
      selectedTheme = preferences.theme_mode;
      reducedMotion = preferences.reduced_motion;
      
      // If we got preferences, we're authenticated
      if (!isAuthenticated) {
        isAuthenticated = true;
        // Try to get user info from Telegram (unsafe, just for display)
        const user = tg.getUserUnsafe();
        if (user) {
          userInfo = {
            id: 0, // We don't have the DB id
            telegram_id: user.id,
            first_name: user.first_name,
            last_name: user.last_name,
            username: user.username,
          };
        }
      }
    } catch (error) {
      prefsError = error instanceof Error ? error.message : 'Failed to load preferences';
      console.warn('[IntegrationsDemo] Failed to load preferences:', error);
      // Not authenticated or other error
      isAuthenticated = false;
    } finally {
      isLoadingPrefs = false;
    }
  }
  
  async function savePreferences() {
    isSavingPrefs = true;
    prefsError = '';
    prefsSuccess = '';
    
    try {
      const updated = await api.preferences.update({
        theme_mode: selectedTheme,
        reduced_motion: reducedMotion,
      });
      
      preferences = updated;
      prefsSuccess = 'Preferences saved successfully!';
      
      // Apply theme immediately
      await theme.set(selectedTheme);
      
      // Clear success message after 3 seconds
      setTimeout(() => {
        prefsSuccess = '';
      }, 3000);
    } catch (error) {
      prefsError = error instanceof Error ? error.message : 'Failed to save preferences';
      console.error('[IntegrationsDemo] Save error:', error);
    } finally {
      isSavingPrefs = false;
    }
  }
  
  async function reloadPage() {
    window.location.reload();
  }
</script>

<div class="integrations-demo">
  <!-- Authentication Section -->
  <section class="demo-section">
    <h3 class="section-title">🔐 Authentication</h3>
    
    {#if !isAuthenticated}
      <div class="auth-card">
        <p class="info-text">
          Click the button below to authenticate with Telegram's initData.
          The backend will validate the data using HMAC-SHA256 and create a secure session.
        </p>
        
        <button
          class="action-button primary"
          disabled={isAuthenticating}
          on:click={authenticate}
        >
          {isAuthenticating ? 'Authenticating...' : 'Authenticate with Telegram'}
        </button>
        
        {#if authError}
          <div class="error-message">
            ⚠️ {authError}
          </div>
        {/if}
      </div>
    {:else}
      <div class="auth-card success">
        <div class="success-badge">✅ Authenticated</div>
        
        {#if userInfo}
          <div class="user-info">
            <div class="user-field">
              <span class="field-label">Name:</span>
              <span class="field-value">
                {userInfo.first_name}
                {#if userInfo.last_name}{userInfo.last_name}{/if}
              </span>
            </div>
            
            {#if userInfo.username}
              <div class="user-field">
                <span class="field-label">Username:</span>
                <span class="field-value">@{userInfo.username}</span>
              </div>
            {/if}
            
            <div class="user-field">
              <span class="field-label">Telegram ID:</span>
              <span class="field-value">{userInfo.telegram_id}</span>
            </div>
            
            {#if userInfo.id > 0}
              <div class="user-field">
                <span class="field-label">Database ID:</span>
                <span class="field-value">{userInfo.id}</span>
              </div>
            {/if}
          </div>
        {/if}
        
        <p class="info-text small">
          🔒 Session is stored in an HttpOnly cookie (secure, not accessible via JavaScript)
        </p>
      </div>
    {/if}
  </section>
  
  <!-- Preferences Section -->
  <section class="demo-section">
    <h3 class="section-title">⚙️ Preferences Management</h3>
    
    {#if !isAuthenticated}
      <div class="info-card">
        <p class="info-text">
          Please authenticate first to manage preferences.
        </p>
      </div>
    {:else}
      <div class="prefs-card">
        {#if isLoadingPrefs}
          <div class="loading-state">
            <div class="spinner"></div>
            <p>Loading preferences...</p>
          </div>
        {:else}
          <!-- Current Preferences -->
          {#if preferences}
            <div class="current-prefs">
              <h4 class="subsection-title">Current Preferences (from Database)</h4>
              <div class="prefs-display">
                <div class="pref-item">
                  <span class="pref-label">Theme Mode:</span>
                  <span class="pref-value badge">{preferences.theme_mode}</span>
                </div>
                <div class="pref-item">
                  <span class="pref-label">Reduced Motion:</span>
                  <span class="pref-value badge">{preferences.reduced_motion ? 'Enabled' : 'Disabled'}</span>
                </div>
              </div>
            </div>
          {/if}
          
          <!-- Update Form -->
          <div class="prefs-form">
            <h4 class="subsection-title">Update Preferences</h4>
            
            <div class="form-group">
              <label class="form-label" for="theme-select">Theme Mode</label>
              <select
                id="theme-select"
                class="form-select"
                bind:value={selectedTheme}
                disabled={isSavingPrefs}
              >
                <option value="native">Native (Telegram colors)</option>
                <option value="premium">Premium (Custom design)</option>
                <option value="mixed">Mixed (Blend both)</option>
              </select>
            </div>
            
            <div class="form-group">
              <label class="form-checkbox">
                <input
                  type="checkbox"
                  bind:checked={reducedMotion}
                  disabled={isSavingPrefs}
                />
                <span>Enable reduced motion</span>
              </label>
            </div>
            
            <button
              class="action-button primary"
              disabled={isSavingPrefs}
              on:click={savePreferences}
            >
              {isSavingPrefs ? 'Saving...' : 'Save Preferences'}
            </button>
            
            {#if prefsSuccess}
              <div class="success-message">
                ✅ {prefsSuccess}
              </div>
            {/if}
            
            {#if prefsError}
              <div class="error-message">
                ⚠️ {prefsError}
              </div>
            {/if}
          </div>
        {/if}
      </div>
    {/if}
  </section>
  
  <!-- Round-Trip Demo -->
  <section class="demo-section">
    <h3 class="section-title">🔄 Persistence Demo</h3>
    
    <div class="demo-card">
      <p class="info-text">
        Test the full round-trip: update preferences → reload page → preferences restored from database.
      </p>
      
      <ol class="demo-steps">
        <li>Change theme or reduced motion setting above</li>
        <li>Click "Save Preferences" (syncs to database)</li>
        <li>Click "Reload Page" below</li>
        <li>Observe that your preferences are restored after reload</li>
      </ol>
      
      <button
        class="action-button secondary"
        on:click={reloadPage}
      >
        🔄 Reload Page
      </button>
      
      <p class="info-text small">
        💡 Preferences persist across sessions because they're stored in the database,
        not just in localStorage or memory.
      </p>
    </div>
  </section>
</div>

<style>
  .integrations-demo {
    display: flex;
    flex-direction: column;
    gap: var(--space-xl, 32px);
  }
  
  .demo-section {
    display: flex;
    flex-direction: column;
    gap: var(--space-md, 16px);
  }
  
  .section-title {
    font-size: 24px;
    font-weight: 700;
    color: var(--color-text-primary, #ffffff);
    margin: 0;
  }
  
  .subsection-title {
    font-size: 18px;
    font-weight: 600;
    color: var(--color-text-primary, #ffffff);
    margin: 0 0 var(--space-sm, 8px) 0;
  }
  
  /* Cards */
  .auth-card,
  .prefs-card,
  .info-card,
  .demo-card {
    background: var(--glass-bg, rgba(255, 255, 255, 0.05));
    backdrop-filter: blur(var(--glass-blur, 12px));
    -webkit-backdrop-filter: blur(var(--glass-blur, 12px));
    border: 1px solid var(--glass-border, rgba(255, 255, 255, 0.1));
    border-radius: var(--radius-lg, 24px);
    padding: var(--space-lg, 24px);
    display: flex;
    flex-direction: column;
    gap: var(--space-md, 16px);
  }
  
  .auth-card.success {
    border-color: rgba(34, 197, 94, 0.3);
    background: rgba(34, 197, 94, 0.05);
  }
  
  .success-badge {
    display: inline-flex;
    align-items: center;
    gap: var(--space-xs, 4px);
    padding: var(--space-xs, 4px) var(--space-sm, 8px);
    background: rgba(34, 197, 94, 0.2);
    border: 1px solid rgba(34, 197, 94, 0.3);
    border-radius: var(--radius-md, 16px);
    color: #22c55e;
    font-size: 14px;
    font-weight: 600;
    width: fit-content;
  }
  
  /* User Info */
  .user-info {
    display: flex;
    flex-direction: column;
    gap: var(--space-sm, 8px);
    padding: var(--space-md, 16px);
    background: rgba(0, 0, 0, 0.2);
    border-radius: var(--radius-md, 16px);
  }
  
  .user-field {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: var(--space-md, 16px);
  }
  
  .field-label {
    font-size: 14px;
    color: var(--color-text-secondary, #a0a0b0);
    font-weight: 500;
  }
  
  .field-value {
    font-size: 14px;
    color: var(--color-text-primary, #ffffff);
    font-weight: 600;
    font-family: 'Courier New', monospace;
  }
  
  /* Preferences Display */
  .current-prefs {
    display: flex;
    flex-direction: column;
    gap: var(--space-sm, 8px);
  }
  
  .prefs-display {
    display: flex;
    flex-direction: column;
    gap: var(--space-sm, 8px);
    padding: var(--space-md, 16px);
    background: rgba(0, 0, 0, 0.2);
    border-radius: var(--radius-md, 16px);
  }
  
  .pref-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: var(--space-md, 16px);
  }
  
  .pref-label {
    font-size: 14px;
    color: var(--color-text-secondary, #a0a0b0);
    font-weight: 500;
  }
  
  .pref-value {
    font-size: 14px;
    color: var(--color-text-primary, #ffffff);
    font-weight: 600;
  }
  
  .badge {
    padding: var(--space-xs, 4px) var(--space-sm, 8px);
    background: var(--gradient-primary, linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%));
    border-radius: var(--radius-sm, 8px);
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }
  
  /* Form */
  .prefs-form {
    display: flex;
    flex-direction: column;
    gap: var(--space-md, 16px);
    padding-top: var(--space-md, 16px);
    border-top: 1px solid var(--glass-border, rgba(255, 255, 255, 0.1));
  }
  
  .form-group {
    display: flex;
    flex-direction: column;
    gap: var(--space-xs, 4px);
  }
  
  .form-label {
    font-size: 14px;
    font-weight: 600;
    color: var(--color-text-primary, #ffffff);
  }
  
  .form-select {
    padding: var(--space-sm, 8px) var(--space-md, 16px);
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid var(--glass-border, rgba(255, 255, 255, 0.1));
    border-radius: var(--radius-md, 16px);
    color: var(--color-text-primary, #ffffff);
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
  }
  
  .form-select:hover:not(:disabled) {
    border-color: var(--color-accent-primary, #6366f1);
  }
  
  .form-select:focus {
    outline: none;
    border-color: var(--color-accent-primary, #6366f1);
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
  }
  
  .form-select:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  
  .form-checkbox {
    display: flex;
    align-items: center;
    gap: var(--space-sm, 8px);
    font-size: 14px;
    color: var(--color-text-primary, #ffffff);
    cursor: pointer;
  }
  
  .form-checkbox input[type="checkbox"] {
    width: 20px;
    height: 20px;
    cursor: pointer;
  }
  
  /* Buttons */
  .action-button {
    padding: var(--space-sm, 8px) var(--space-lg, 24px);
    border: none;
    border-radius: var(--radius-md, 16px);
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: var(--space-xs, 4px);
  }
  
  .action-button.primary {
    background: var(--gradient-primary, linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%));
    color: var(--color-text-primary, #ffffff);
    box-shadow: var(--shadow-md, 0 4px 16px rgba(0, 0, 0, 0.2));
  }
  
  .action-button.primary:hover:not(:disabled) {
    box-shadow: var(--shadow-glow, 0 0 32px rgba(99, 102, 241, 0.4));
    transform: translateY(-2px);
  }
  
  .action-button.secondary {
    background: rgba(255, 255, 255, 0.1);
    color: var(--color-text-primary, #ffffff);
    border: 1px solid var(--glass-border, rgba(255, 255, 255, 0.2));
  }
  
  .action-button.secondary:hover:not(:disabled) {
    background: rgba(255, 255, 255, 0.15);
    border-color: var(--color-accent-primary, #6366f1);
  }
  
  .action-button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    transform: none;
  }
  
  /* Messages */
  .info-text {
    font-size: 14px;
    line-height: 1.6;
    color: var(--color-text-secondary, #a0a0b0);
    margin: 0;
  }
  
  .info-text.small {
    font-size: 12px;
    opacity: 0.8;
  }
  
  .error-message {
    padding: var(--space-sm, 8px) var(--space-md, 16px);
    background: rgba(239, 68, 68, 0.1);
    border: 1px solid rgba(239, 68, 68, 0.3);
    border-radius: var(--radius-md, 16px);
    color: #ef4444;
    font-size: 14px;
  }
  
  .success-message {
    padding: var(--space-sm, 8px) var(--space-md, 16px);
    background: rgba(34, 197, 94, 0.1);
    border: 1px solid rgba(34, 197, 94, 0.3);
    border-radius: var(--radius-md, 16px);
    color: #22c55e;
    font-size: 14px;
  }
  
  /* Loading State */
  .loading-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: var(--space-md, 16px);
    padding: var(--space-xl, 32px);
  }
  
  .spinner {
    width: 40px;
    height: 40px;
    border: 3px solid rgba(255, 255, 255, 0.1);
    border-top-color: var(--color-accent-primary, #6366f1);
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }
  
  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
  
  /* Demo Steps */
  .demo-steps {
    margin: 0;
    padding-left: var(--space-lg, 24px);
    color: var(--color-text-secondary, #a0a0b0);
    font-size: 14px;
    line-height: 1.8;
  }
  
  .demo-steps li {
    margin-bottom: var(--space-xs, 4px);
  }
  
  /* Responsive */
  @media (max-width: 640px) {
    .auth-card,
    .prefs-card,
    .info-card,
    .demo-card {
      padding: var(--space-md, 16px);
    }
    
    .user-field,
    .pref-item {
      flex-direction: column;
      align-items: flex-start;
      gap: var(--space-xs, 4px);
    }
  }
</style>
