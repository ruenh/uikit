// apps/web/src/lib/theme.ts
// Theme management with database synchronization
// Source: Design document section 3 (Theme Management)
// Requirements: 6.1, 6.6

import { api } from './api';

/**
 * Theme mode types
 * - native: Use Telegram's themeParams for all colors
 * - premium: Use custom premium design colors
 * - mixed: Blend Telegram theme colors with premium design elements
 * 
 * Source: Requirements 6.2, 6.3, 6.4
 */
export type ThemeMode = 'native' | 'premium' | 'mixed';

/**
 * Theme management module
 * 
 * Provides theme switching with database synchronization.
 * Theme preference persists across sessions via backend API.
 * 
 * Usage:
 * - Call theme.init() on page load to restore saved theme
 * - Call theme.set(mode) to change theme (syncs to database)
 * - Call theme.load() to manually fetch theme from backend
 */
export const theme = {
  /**
   * Current theme mode
   * Default: 'premium'
   */
  current: 'premium' as ThemeMode,
  
  /**
   * Set theme mode and sync to database
   * 
   * @param mode - Theme mode to set ('native', 'premium', or 'mixed')
   * 
   * Steps:
   * 1. Update current theme in memory
   * 2. Apply theme to DOM (data-theme attribute)
   * 3. Sync to backend database (if authenticated)
   * 
   * Error handling:
   * - If backend sync fails, logs warning but continues (theme still works locally)
   * - If DOM update fails, falls back to 'premium' theme
   * 
   * Requirements: 6.1, 6.6
   */
  set: async (mode: ThemeMode): Promise<void> => {
    try {
      // Update in-memory state
      theme.current = mode;
      
      // Apply to DOM
      document.documentElement.setAttribute('data-theme', mode);
      
      // Sync to backend (if authenticated)
      try {
        await api.preferences.update({ theme_mode: mode });
      } catch (error) {
        // Log warning but don't fail - theme still works locally
        console.warn('[Theme] Failed to sync to backend:', error);
        // Continue anyway - theme is applied locally
      }
    } catch (error) {
      // Critical error - fall back to default theme
      console.error('[Theme] Failed to set theme:', error);
      document.documentElement.setAttribute('data-theme', 'premium');
    }
  },
  
  /**
   * Load theme from backend API
   * 
   * @returns Theme mode from database, or 'premium' as fallback
   * 
   * Error handling:
   * - If API call fails (not authenticated, network error, etc.), returns 'premium'
   * - Logs warning for debugging
   * 
   * Requirements: 6.6
   */
  load: async (): Promise<ThemeMode> => {
    try {
      const prefs = await api.preferences.get();
      return prefs.theme_mode;
    } catch (error) {
      // Not authenticated or API error - use default
      console.warn('[Theme] Failed to load from backend, using default:', error);
      return 'premium';
    }
  },
  
  /**
   * Initialize theme on page load
   * 
   * Steps:
   * 1. Load theme preference from backend
   * 2. Update in-memory state
   * 3. Apply to DOM
   * 
   * This should be called once on page load to restore user's saved theme.
   * 
   * Error handling:
   * - If load fails, falls back to 'premium' theme
   * - Always applies a theme (never leaves DOM in inconsistent state)
   * 
   * Requirements: 6.6
   */
  init: async (): Promise<void> => {
    const mode = await theme.load();
    theme.current = mode;
    document.documentElement.setAttribute('data-theme', mode);
  },
};
