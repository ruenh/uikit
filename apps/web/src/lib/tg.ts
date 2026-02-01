// apps/web/src/lib/tg.ts
// Telegram WebApp API adapter with graceful fallbacks
// Source: https://core.telegram.org/bots/webapps

/**
 * Telegram WebApp API types
 * Based on official Telegram Mini Apps documentation
 */
interface TelegramWebApp {
  initData: string;
  initDataUnsafe: {
    query_id?: string;
    user?: {
      id: number;
      first_name: string;
      last_name?: string;
      username?: string;
      language_code?: string;
      is_premium?: boolean;
    };
    auth_date: number;
    hash: string;
  };
  version: string;
  platform: string;
  colorScheme: 'light' | 'dark';
  themeParams: {
    bg_color?: string;
    text_color?: string;
    hint_color?: string;
    link_color?: string;
    button_color?: string;
    button_text_color?: string;
    secondary_bg_color?: string;
  };
  isExpanded: boolean;
  viewportHeight: number;
  viewportStableHeight: number;
  headerColor: string;
  backgroundColor: string;
  isClosingConfirmationEnabled: boolean;
  BackButton: {
    isVisible: boolean;
    onClick(callback: () => void): void;
    offClick(callback: () => void): void;
    show(): void;
    hide(): void;
  };
  MainButton: {
    text: string;
    color: string;
    textColor: string;
    isVisible: boolean;
    isActive: boolean;
    isProgressVisible: boolean;
    setText(text: string): void;
    onClick(callback: () => void): void;
    offClick(callback: () => void): void;
    show(): void;
    hide(): void;
    enable(): void;
    disable(): void;
    showProgress(leaveActive?: boolean): void;
    hideProgress(): void;
    setParams(params: {
      text?: string;
      color?: string;
      text_color?: string;
      is_active?: boolean;
      is_visible?: boolean;
    }): void;
  };
  HapticFeedback: {
    impactOccurred(style: 'light' | 'medium' | 'heavy' | 'rigid' | 'soft'): void;
    notificationOccurred(type: 'error' | 'success' | 'warning'): void;
    selectionChanged(): void;
  };
  ready(): void;
  expand(): void;
  close(): void;
  showPopup(params: {
    title?: string;
    message: string;
    buttons?: Array<{
      id?: string;
      type?: 'default' | 'ok' | 'close' | 'cancel' | 'destructive';
      text?: string;
    }>;
  }, callback?: (buttonId: string) => void): void;
  showAlert(message: string, callback?: () => void): void;
  showConfirm(message: string, callback?: (confirmed: boolean) => void): void;
  onEvent(eventType: string, callback: () => void): void;
  offEvent(eventType: string, callback: () => void): void;
  sendData(data: string): void;
  openLink(url: string, options?: { try_instant_view?: boolean }): void;
  openTelegramLink(url: string): void;
  openInvoice(url: string, callback?: (status: string) => void): void;
}

declare global {
  interface Window {
    Telegram?: {
      WebApp: TelegramWebApp;
    };
  }
}

/**
 * Check if Telegram WebApp API is available
 */
export function isAvailable(): boolean {
  return typeof window !== 'undefined' && 
         window.Telegram !== undefined && 
         window.Telegram.WebApp !== undefined;
}

/**
 * Get Telegram WebApp instance (if available)
 */
function getTelegramWebApp(): TelegramWebApp | null {
  if (!isAvailable()) {
    return null;
  }
  return window.Telegram!.WebApp;
}

/**
 * Log warning when API is unavailable
 */
function warnUnavailable(method: string): void {
  console.warn(`[TMA Studio] Telegram WebApp API not available. Method "${method}" called in browser mode.`);
}

// ============================================================================
// Initialization Methods
// ============================================================================

/**
 * Signal that the Mini App is ready
 * MUST be called before any other WebApp API calls
 * Source: https://core.telegram.org/bots/webapps#initializing-mini-apps
 */
export function ready(): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.ready();
  } else {
    warnUnavailable('ready');
  }
}

/**
 * Expand the Mini App to full height
 * Source: https://core.telegram.org/bots/webapps#expanding-the-mini-app
 */
export function expand(): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.expand();
  } else {
    warnUnavailable('expand');
  }
}

/**
 * Close the Mini App
 */
export function close(): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.close();
  } else {
    warnUnavailable('close');
  }
}

// ============================================================================
// MainButton Methods
// ============================================================================

/**
 * Show the MainButton
 */
export function showMainButton(): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.MainButton.show();
  } else {
    warnUnavailable('showMainButton');
  }
}

/**
 * Hide the MainButton
 */
export function hideMainButton(): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.MainButton.hide();
  } else {
    warnUnavailable('hideMainButton');
  }
}

/**
 * Set MainButton parameters
 * Source: https://core.telegram.org/bots/webapps#mainbutton
 */
export function setMainButtonParams(params: {
  text?: string;
  color?: string;
  text_color?: string;
  is_active?: boolean;
  is_visible?: boolean;
}): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.MainButton.setParams(params);
  } else {
    warnUnavailable('setMainButtonParams');
  }
}

/**
 * Set MainButton text
 */
export function setMainButtonText(text: string): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.MainButton.setText(text);
  } else {
    warnUnavailable('setMainButtonText');
  }
}

/**
 * Add click handler to MainButton
 */
export function onMainButtonClick(callback: () => void): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.MainButton.onClick(callback);
  } else {
    warnUnavailable('onMainButtonClick');
  }
}

/**
 * Remove click handler from MainButton
 */
export function offMainButtonClick(callback: () => void): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.MainButton.offClick(callback);
  } else {
    warnUnavailable('offMainButtonClick');
  }
}

// ============================================================================
// BackButton Methods
// ============================================================================

/**
 * Show the BackButton
 */
export function showBackButton(): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.BackButton.show();
  } else {
    warnUnavailable('showBackButton');
  }
}

/**
 * Hide the BackButton
 */
export function hideBackButton(): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.BackButton.hide();
  } else {
    warnUnavailable('hideBackButton');
  }
}

/**
 * Add click handler to BackButton
 */
export function onBackButtonClick(callback: () => void): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.BackButton.onClick(callback);
  } else {
    warnUnavailable('onBackButtonClick');
  }
}

/**
 * Remove click handler from BackButton
 */
export function offBackButtonClick(callback: () => void): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.BackButton.offClick(callback);
  } else {
    warnUnavailable('offBackButtonClick');
  }
}

// ============================================================================
// Popup Methods
// ============================================================================

/**
 * Show a popup with custom buttons
 * Browser fallback: Uses native alert
 * Source: https://core.telegram.org/bots/webapps#popups
 */
export function showPopup(
  params: {
    title?: string;
    message: string;
    buttons?: Array<{
      id?: string;
      type?: 'default' | 'ok' | 'close' | 'cancel' | 'destructive';
      text?: string;
    }>;
  },
  callback?: (buttonId: string) => void
): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.showPopup(params, callback);
  } else {
    warnUnavailable('showPopup');
    // Browser fallback
    const title = params.title ? `${params.title}\n\n` : '';
    alert(`${title}${params.message}`);
    if (callback) {
      callback('ok');
    }
  }
}

/**
 * Show an alert popup
 * Browser fallback: Uses native alert
 */
export function showAlert(message: string, callback?: () => void): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.showAlert(message, callback);
  } else {
    warnUnavailable('showAlert');
    // Browser fallback
    alert(message);
    if (callback) {
      callback();
    }
  }
}

/**
 * Show a confirm popup
 * Browser fallback: Uses native confirm
 */
export function showConfirm(message: string, callback?: (confirmed: boolean) => void): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.showConfirm(message, callback);
  } else {
    warnUnavailable('showConfirm');
    // Browser fallback
    const confirmed = confirm(message);
    if (callback) {
      callback(confirmed);
    }
  }
}

// ============================================================================
// Theme Methods
// ============================================================================

/**
 * Get current theme parameters
 * Returns null if API is unavailable
 */
export function getThemeParams(): TelegramWebApp['themeParams'] | null {
  const tg = getTelegramWebApp();
  if (tg) {
    return tg.themeParams;
  }
  return null;
}

/**
 * Get color scheme (light or dark)
 * Returns 'light' as default if API is unavailable
 */
export function getColorScheme(): 'light' | 'dark' {
  const tg = getTelegramWebApp();
  if (tg) {
    return tg.colorScheme;
  }
  return 'light';
}

/**
 * Apply theme parameters to CSS custom properties
 * Maps Telegram theme colors to CSS variables
 */
export function applyThemeToCSS(): void {
  const themeParams = getThemeParams();
  if (!themeParams) {
    return;
  }

  const root = document.documentElement;

  // Map Telegram theme params to CSS variables
  if (themeParams.bg_color) {
    root.style.setProperty('--tg-bg-color', themeParams.bg_color);
  }
  if (themeParams.text_color) {
    root.style.setProperty('--tg-text-color', themeParams.text_color);
  }
  if (themeParams.hint_color) {
    root.style.setProperty('--tg-hint-color', themeParams.hint_color);
  }
  if (themeParams.link_color) {
    root.style.setProperty('--tg-link-color', themeParams.link_color);
  }
  if (themeParams.button_color) {
    root.style.setProperty('--tg-button-color', themeParams.button_color);
  }
  if (themeParams.button_text_color) {
    root.style.setProperty('--tg-button-text-color', themeParams.button_text_color);
  }
  if (themeParams.secondary_bg_color) {
    root.style.setProperty('--tg-secondary-bg-color', themeParams.secondary_bg_color);
  }
}

/**
 * Listen for theme changes
 * Automatically applies new theme to CSS when theme changes
 */
export function onThemeChanged(callback: () => void): void {
  const tg = getTelegramWebApp();
  if (tg) {
    const handler = () => {
      applyThemeToCSS();
      callback();
    };
    tg.onEvent('themeChanged', handler);
  } else {
    warnUnavailable('onThemeChanged');
  }
}

/**
 * Remove theme change listener
 */
export function offThemeChanged(callback: () => void): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.offEvent('themeChanged', callback);
  } else {
    warnUnavailable('offThemeChanged');
  }
}

// ============================================================================
// Viewport Methods
// ============================================================================

/**
 * Get current viewport height
 * Returns 0 if API is unavailable
 */
export function getViewportHeight(): number {
  const tg = getTelegramWebApp();
  if (tg) {
    return tg.viewportHeight;
  }
  return 0;
}

/**
 * Get stable viewport height (excludes keyboard)
 * Returns 0 if API is unavailable
 */
export function getViewportStableHeight(): number {
  const tg = getTelegramWebApp();
  if (tg) {
    return tg.viewportStableHeight;
  }
  return 0;
}

/**
 * Check if Mini App is expanded
 * Returns false if API is unavailable
 */
export function isExpanded(): boolean {
  const tg = getTelegramWebApp();
  if (tg) {
    return tg.isExpanded;
  }
  return false;
}

/**
 * Listen for viewport changes
 */
export function onViewportChanged(callback: () => void): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.onEvent('viewportChanged', callback);
  } else {
    warnUnavailable('onViewportChanged');
  }
}

/**
 * Remove viewport change listener
 */
export function offViewportChanged(callback: () => void): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.offEvent('viewportChanged', callback);
  } else {
    warnUnavailable('offViewportChanged');
  }
}

// ============================================================================
// InitData Methods
// ============================================================================

/**
 * Get raw initData string
 * This is the signed data that should be sent to backend for validation
 * CRITICAL: This data is untrusted until validated server-side
 * Source: https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app
 */
export function getInitData(): string {
  const tg = getTelegramWebApp();
  if (tg) {
    return tg.initData;
  }
  warnUnavailable('getInitData');
  return '';
}

/**
 * Get parsed initData (unsafe - not validated)
 * CRITICAL: This data is UNTRUSTED and should NEVER be used for authentication
 * Always validate initData server-side using HMAC-SHA256
 * Use this only for UI display purposes (e.g., showing user name)
 * Source: https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app
 */
export function getInitDataUnsafe(): TelegramWebApp['initDataUnsafe'] | null {
  const tg = getTelegramWebApp();
  if (tg) {
    return tg.initDataUnsafe;
  }
  warnUnavailable('getInitDataUnsafe');
  return null;
}

/**
 * Get Telegram user info (unsafe - not validated)
 * CRITICAL: This data is UNTRUSTED
 * Use only for UI display, never for authentication
 */
export function getUserUnsafe(): TelegramWebApp['initDataUnsafe']['user'] | null {
  const initDataUnsafe = getInitDataUnsafe();
  if (initDataUnsafe && initDataUnsafe.user) {
    return initDataUnsafe.user;
  }
  return null;
}

// ============================================================================
// Haptic Feedback Methods
// ============================================================================

/**
 * Trigger impact haptic feedback
 * Source: https://core.telegram.org/bots/webapps#hapticfeedback
 */
export function hapticImpact(style: 'light' | 'medium' | 'heavy' | 'rigid' | 'soft'): void {
  const tg = getTelegramWebApp();
  if (tg && tg.HapticFeedback) {
    tg.HapticFeedback.impactOccurred(style);
  } else {
    warnUnavailable('hapticImpact');
  }
}

/**
 * Trigger notification haptic feedback
 */
export function hapticNotification(type: 'error' | 'success' | 'warning'): void {
  const tg = getTelegramWebApp();
  if (tg && tg.HapticFeedback) {
    tg.HapticFeedback.notificationOccurred(type);
  } else {
    warnUnavailable('hapticNotification');
  }
}

/**
 * Trigger selection changed haptic feedback
 */
export function hapticSelection(): void {
  const tg = getTelegramWebApp();
  if (tg && tg.HapticFeedback) {
    tg.HapticFeedback.selectionChanged();
  } else {
    warnUnavailable('hapticSelection');
  }
}

// ============================================================================
// Utility Methods
// ============================================================================

/**
 * Get platform information
 */
export function getPlatform(): string {
  const tg = getTelegramWebApp();
  if (tg) {
    return tg.platform;
  }
  return 'unknown';
}

/**
 * Get Telegram WebApp API version
 */
export function getVersion(): string {
  const tg = getTelegramWebApp();
  if (tg) {
    return tg.version;
  }
  return '0.0';
}

/**
 * Open a link in external browser
 */
export function openLink(url: string, options?: { try_instant_view?: boolean }): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.openLink(url, options);
  } else {
    warnUnavailable('openLink');
    window.open(url, '_blank');
  }
}

/**
 * Open a Telegram link (t.me/...)
 */
export function openTelegramLink(url: string): void {
  const tg = getTelegramWebApp();
  if (tg) {
    tg.openTelegramLink(url);
  } else {
    warnUnavailable('openTelegramLink');
    window.open(url, '_blank');
  }
}

// ============================================================================
// Default Export (Namespace Object)
// ============================================================================

export default {
  // Availability
  isAvailable,
  
  // Initialization
  ready,
  expand,
  close,
  
  // MainButton
  showMainButton,
  hideMainButton,
  setMainButtonParams,
  setMainButtonText,
  onMainButtonClick,
  offMainButtonClick,
  
  // BackButton
  showBackButton,
  hideBackButton,
  onBackButtonClick,
  offBackButtonClick,
  
  // Popups
  showPopup,
  showAlert,
  showConfirm,
  
  // Theme
  getThemeParams,
  getColorScheme,
  applyThemeToCSS,
  onThemeChanged,
  offThemeChanged,
  
  // Viewport
  getViewportHeight,
  getViewportStableHeight,
  isExpanded,
  onViewportChanged,
  offViewportChanged,
  
  // InitData
  getInitData,
  getInitDataUnsafe,
  getUserUnsafe,
  
  // Haptics
  hapticImpact,
  hapticNotification,
  hapticSelection,
  
  // Utility
  getPlatform,
  getVersion,
  openLink,
  openTelegramLink,
};
