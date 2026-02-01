# Telegram Mini Apps Standards and Best Practices

## Overview

This document provides comprehensive guidelines for building Telegram Mini Apps, including security best practices, initData validation algorithms, and common pitfalls with solutions.

**Official Documentation Sources:**
- [Telegram Mini Apps Official Documentation](https://core.telegram.org/bots/webapps)
- [Telegram Mini Apps Platform Docs](https://docs.telegram-mini-apps.com/platform/init-data)

---

## Table of Contents

1. [Essential Best Practices](#essential-best-practices)
2. [InitData Validation Algorithm](#initdata-validation-algorithm)
3. [Security Guidelines](#security-guidelines)
4. [Common Pitfalls and Solutions](#common-pitfalls-and-solutions)
5. [WebApp API Integration](#webapp-api-integration)
6. [Theme and Viewport Handling](#theme-and-viewport-handling)
7. [Testing and Debugging](#testing-and-debugging)

---

## Essential Best Practices

### 1. Early Initialization

**Rule:** Always call `Telegram.WebApp.ready()` as early as possible.

```javascript
// ✅ CORRECT: Call ready() as soon as essential UI is loaded
window.Telegram.WebApp.ready();
```

**Why:** This hides the loading placeholder and shows your Mini App. If not called, the placeholder remains until the page fully loads, creating a poor user experience.

**Source:** [Telegram WebApp API - ready() method](https://core.telegram.org/bots/webapps#initializing-mini-apps)

---

### 2. Load Official Script First

**Rule:** Include `telegram-web-app.js` in the `<head>` tag before any other scripts.

```html
<!-- ✅ CORRECT: Load in <head> before other scripts -->
<head>
  <script src="https://telegram.org/js/telegram-web-app.js"></script>
  <!-- Your other scripts here -->
</head>
```

**Why:** This ensures the `window.Telegram.WebApp` object is available before your application code runs.

**Source:** [Telegram WebApp API - Initializing Mini Apps](https://core.telegram.org/bots/webapps#initializing-mini-apps)

---

### 3. Never Trust Client-Side Data

**Rule:** Treat all data from `initDataUnsafe` as untrusted until server-side validation.

```javascript
// ❌ WRONG: Using initDataUnsafe directly
const userId = window.Telegram.WebApp.initDataUnsafe.user?.id;
await grantAdminAccess(userId); // SECURITY RISK!

// ✅ CORRECT: Send initData to server for validation
const initData = window.Telegram.WebApp.initData;
const response = await fetch('/api/auth/validate', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ initData }),
});
const { user } = await response.json();
// Now user data is validated and can be trusted
```

**Why:** Client-side data can be tampered with. Only server-validated data is trustworthy.

**Source:** [Telegram WebApp API - Validating data](https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app)

---

### 4. Expand Mini App on Launch

**Rule:** Call `expand()` to maximize the visible area.

```javascript
window.Telegram.WebApp.ready();
window.Telegram.WebApp.expand();
```

**Why:** By default, Mini Apps may open in a collapsed state. Expanding provides more screen space for your interface.

**Source:** [Telegram WebApp API - expand() method](https://core.telegram.org/bots/webapps#initializing-mini-apps)

---

### 5. Respect Theme Changes

**Rule:** Listen to `themeChanged` events and update your UI accordingly.

```javascript
window.Telegram.WebApp.onEvent('themeChanged', () => {
  const themeParams = window.Telegram.WebApp.themeParams;
  
  // Update CSS variables
  document.documentElement.style.setProperty('--tg-bg-color', themeParams.bg_color);
  document.documentElement.style.setProperty('--tg-text-color', themeParams.text_color);
  // ... update other theme properties
});
```

**Why:** Users expect Mini Apps to match their Telegram theme (light/dark mode). Ignoring theme changes creates a jarring experience.

**Source:** [Telegram WebApp API - ThemeParams](https://core.telegram.org/bots/webapps#themeparams)

---

### 6. Handle Viewport Changes

**Rule:** Listen to `viewportChanged` events and adjust layout for stable states.

```javascript
window.Telegram.WebApp.onEvent('viewportChanged', (event) => {
  if (event.isStateStable) {
    // Viewport has finished resizing
    const height = window.Telegram.WebApp.viewportStableHeight;
    // Adjust layout based on stable height
  }
});
```

**Why:** Users can expand/collapse Mini Apps. Your UI should adapt smoothly without content jumps.

**Source:** [Telegram WebApp API - viewportChanged event](https://core.telegram.org/bots/webapps#events-available-for-mini-apps)

---

### 7. Use Safe Area Insets

**Rule:** Respect safe area insets to avoid overlap with system UI.

```css
/* ✅ CORRECT: Use CSS variables for safe areas */
.content {
  padding-top: var(--tg-safe-area-inset-top);
  padding-bottom: var(--tg-safe-area-inset-bottom);
  padding-left: var(--tg-safe-area-inset-left);
  padding-right: var(--tg-safe-area-inset-right);
}
```

**Why:** Devices with notches or navigation bars need safe area padding to prevent content from being obscured.

**Source:** [Telegram WebApp API - SafeAreaInset](https://core.telegram.org/bots/webapps#safeareainset)

---

## InitData Validation Algorithm

### Overview

InitData validation is **critical** for security. It ensures that data received from the client was genuinely issued by Telegram and hasn't been tampered with.

**Source:** [Telegram WebApp API - Validating data](https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app)

---

### Algorithm Steps

#### Step 1: Parse InitData as Query Parameters

InitData is a query string (e.g., `query_id=...&user=...&auth_date=...&hash=...`).

```python
from urllib.parse import parse_qsl

parsed = dict(parse_qsl(init_data))
```

---

#### Step 2: Extract and Remove Hash

The `hash` parameter is the signature to verify. Extract it and remove it from the data.

```python
hash_value = parsed.pop('hash', None)
if not hash_value:
    raise ValueError("No hash in initData")
```

---

#### Step 3: Validate auth_date (TTL Check)

Check that the data isn't too old to prevent replay attacks.

```python
from datetime import datetime

auth_date = parsed.get('auth_date')
if not auth_date:
    raise ValueError("No auth_date in initData")

auth_timestamp = int(auth_date)
current_timestamp = int(datetime.utcnow().timestamp())
age_seconds = current_timestamp - auth_timestamp

MAX_AGE_SECONDS = 86400  # 24 hours for demo; use 300-600 for production

if age_seconds > MAX_AGE_SECONDS:
    raise ValueError(f"initData expired (age: {age_seconds}s)")

if age_seconds < 0:
    raise ValueError("auth_date is in the future")
```

**Production Recommendation:** Use 300-600 seconds (5-10 minutes) for tighter security. Longer TTLs (24 hours) are acceptable for demos but increase replay attack risk.

---

#### Step 4: Create Data-Check-String

Sort remaining key-value pairs alphabetically and join with newlines.

```python
data_check_string = '\n'.join(
    f"{k}={v}" for k, v in sorted(parsed.items())
)
```

**Example:**
```
auth_date=1234567890
query_id=AAHdF6IQAAAAAN0XohDhrOrc
user={"id":123456789,"first_name":"John"}
```

---

#### Step 5: Create Secret Key

Create HMAC-SHA256 signature of bot token using `"WebAppData"` as key.

```python
import hmac
import hashlib

secret_key = hmac.new(
    key=b"WebAppData",
    msg=bot_token.encode(),
    digestmod=hashlib.sha256
).digest()
```

**Critical:** The constant string `"WebAppData"` is specified by Telegram and must be used exactly.

**Source:** [Telegram WebApp API - Validating data](https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app)

---

#### Step 6: Calculate Hash

Create HMAC-SHA256 signature of data-check-string using secret key.

```python
calculated_hash = hmac.new(
    key=secret_key,
    msg=data_check_string.encode(),
    digestmod=hashlib.sha256
).hexdigest()
```

---

#### Step 7: Compare Hashes (Constant-Time)

Use constant-time comparison to prevent timing attacks.

```python
if not hmac.compare_digest(calculated_hash, hash_value):
    raise ValueError("Invalid hash")
```

**Why constant-time?** Regular string comparison (`==`) can leak timing information, allowing attackers to guess the hash byte-by-byte.

---

### Complete Python Implementation

```python
import hmac
import hashlib
from urllib.parse import parse_qsl
from datetime import datetime

def validate_init_data(init_data: str, bot_token: str, max_age_seconds: int = 86400) -> dict:
    """
    Validate Telegram initData using HMAC-SHA256.
    
    Args:
        init_data: Raw initData string from Telegram
        bot_token: Bot token for HMAC validation
        max_age_seconds: Maximum age of initData (default: 86400 = 24 hours)
    
    Returns:
        Parsed and validated data dictionary
    
    Raises:
        ValueError: If validation fails or initData is expired
    
    Source: https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app
    """
    try:
        # Step 1: Parse query string
        parsed = dict(parse_qsl(init_data))
        
        # Step 2: Extract hash
        hash_value = parsed.pop('hash', None)
        if not hash_value:
            raise ValueError("No hash in initData")
        
        # Step 3: Validate auth_date (TTL check)
        auth_date = parsed.get('auth_date')
        if not auth_date:
            raise ValueError("No auth_date in initData")
        
        auth_timestamp = int(auth_date)
        current_timestamp = int(datetime.utcnow().timestamp())
        age_seconds = current_timestamp - auth_timestamp
        
        if age_seconds > max_age_seconds:
            raise ValueError(f"initData expired (age: {age_seconds}s, max: {max_age_seconds}s)")
        
        if age_seconds < 0:
            raise ValueError("auth_date is in the future")
        
        # Step 4: Create data-check-string
        data_check_string = '\n'.join(
            f"{k}={v}" for k, v in sorted(parsed.items())
        )
        
        # Step 5: Create secret key
        secret_key = hmac.new(
            key=b"WebAppData",
            msg=bot_token.encode(),
            digestmod=hashlib.sha256
        ).digest()
        
        # Step 6: Calculate hash
        calculated_hash = hmac.new(
            key=secret_key,
            msg=data_check_string.encode(),
            digestmod=hashlib.sha256
        ).hexdigest()
        
        # Step 7: Compare hashes (constant-time)
        if not hmac.compare_digest(calculated_hash, hash_value):
            raise ValueError("Invalid hash")
        
        return parsed
    
    except Exception as e:
        raise ValueError(f"Validation failed: {str(e)}")
```

---

### JavaScript/TypeScript Implementation

```typescript
import crypto from 'crypto';

function validateInitData(
  initData: string,
  botToken: string,
  maxAgeSeconds: number = 86400
): Record<string, string> {
  // Step 1: Parse query string
  const params = new URLSearchParams(initData);
  const data: Record<string, string> = {};
  
  params.forEach((value, key) => {
    data[key] = value;
  });
  
  // Step 2: Extract hash
  const hash = data.hash;
  if (!hash) {
    throw new Error('No hash in initData');
  }
  delete data.hash;
  
  // Step 3: Validate auth_date
  const authDate = data.auth_date;
  if (!authDate) {
    throw new Error('No auth_date in initData');
  }
  
  const authTimestamp = parseInt(authDate);
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const ageSeconds = currentTimestamp - authTimestamp;
  
  if (ageSeconds > maxAgeSeconds) {
    throw new Error(`initData expired (age: ${ageSeconds}s)`);
  }
  
  if (ageSeconds < 0) {
    throw new Error('auth_date is in the future');
  }
  
  // Step 4: Create data-check-string
  const dataCheckString = Object.keys(data)
    .sort()
    .map(key => `${key}=${data[key]}`)
    .join('\n');
  
  // Step 5: Create secret key
  const secretKey = crypto
    .createHmac('sha256', 'WebAppData')
    .update(botToken)
    .digest();
  
  // Step 6: Calculate hash
  const calculatedHash = crypto
    .createHmac('sha256', secretKey)
    .update(dataCheckString)
    .digest('hex');
  
  // Step 7: Compare hashes (constant-time)
  if (!crypto.timingSafeEqual(Buffer.from(hash), Buffer.from(calculatedHash))) {
    throw new Error('Invalid hash');
  }
  
  return data;
}
```

---

## Security Guidelines

### 1. Never Expose Bot Token

**Rule:** Store bot token only in environment variables, never in code or logs.

```python
# ❌ WRONG: Hardcoded token
BOT_TOKEN = "1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"

# ✅ CORRECT: Environment variable
import os
BOT_TOKEN = os.environ.get('BOT_TOKEN')
if not BOT_TOKEN:
    raise ValueError("BOT_TOKEN environment variable not set")
```

**Why:** Exposed tokens allow attackers to impersonate your bot and access user data.

---

### 2. Use HTTPS in Production

**Rule:** Mini Apps MUST use HTTPS in production.

**Why:** Telegram requires HTTPS for security. HTTP is only allowed in the test environment.

**Source:** [Telegram WebApp API - Testing](https://core.telegram.org/bots/webapps#testing-mini-apps)

---

### 3. Implement Session Management Securely

**Rule:** Use HttpOnly cookies for session tokens, not localStorage.

```python
# ✅ CORRECT: HttpOnly cookie
response.set_cookie(
    key="session",
    value=jwt_token,
    httponly=True,      # Prevents JavaScript access
    secure=True,        # HTTPS only
    samesite="none",    # Cross-domain (Mini App → API)
    max_age=86400,      # 24 hours
)
```

**Why:** HttpOnly cookies prevent XSS attacks. localStorage is accessible to JavaScript and vulnerable to XSS.

---

### 4. Configure CORS Correctly

**Rule:** When using cookies, CORS must have explicit origins (not `"*"`).

```python
# ❌ WRONG: Wildcard with credentials
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],           # FAILS with credentials
    allow_credentials=True,
)

# ✅ CORRECT: Explicit origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://app.yourdomain.com"],  # Explicit list
    allow_credentials=True,
)
```

**Why:** Browsers reject wildcard origins when `credentials: 'include'` is used.

**Source:** [MDN - CORS credentials](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#requests_with_credentials)

---

### 5. Validate auth_date TTL

**Rule:** Reject initData older than a reasonable threshold.

**Recommendations:**
- **Demo/Development:** 24 hours (86400 seconds)
- **Production:** 5-10 minutes (300-600 seconds)

**Why:** Shorter TTLs reduce replay attack windows. Balance security with UX (clock skew, slow networks).

---

## Common Pitfalls and Solutions

### Pitfall 1: Not Calling ready()

**Problem:** Mini App shows loading placeholder indefinitely.

**Solution:** Call `Telegram.WebApp.ready()` as early as possible.

```javascript
// ✅ Call ready() immediately after essential UI loads
window.Telegram.WebApp.ready();
```

---

### Pitfall 2: Using initDataUnsafe Without Validation

**Problem:** Security vulnerability - client data can be tampered with.

**Solution:** Always validate initData on the server before trusting it.

```javascript
// ❌ WRONG
const userId = window.Telegram.WebApp.initDataUnsafe.user?.id;

// ✅ CORRECT
const initData = window.Telegram.WebApp.initData;
const { user } = await validateOnServer(initData);
```

---

### Pitfall 3: Ignoring Theme Changes

**Problem:** Mini App doesn't match user's Telegram theme (light/dark).

**Solution:** Listen to `themeChanged` events and update CSS variables.

```javascript
window.Telegram.WebApp.onEvent('themeChanged', () => {
  applyTheme(window.Telegram.WebApp.themeParams);
});
```

---

### Pitfall 4: Not Handling Viewport Changes

**Problem:** Layout breaks when user expands/collapses Mini App.

**Solution:** Use `viewportStableHeight` and listen to `viewportChanged` events.

```javascript
window.Telegram.WebApp.onEvent('viewportChanged', (event) => {
  if (event.isStateStable) {
    adjustLayout(window.Telegram.WebApp.viewportStableHeight);
  }
});
```

---

### Pitfall 5: Incorrect CORS Configuration

**Problem:** API requests fail with CORS errors when using cookies.

**Solution:** Use explicit origins (not `"*"`) with `allow_credentials=True`.

```python
# ✅ CORRECT
allow_origins=["https://app.yourdomain.com"],
allow_credentials=True,
```

---

### Pitfall 6: Missing Safe Area Padding

**Problem:** Content overlaps with notches or navigation bars on mobile devices.

**Solution:** Use CSS safe area variables.

```css
.container {
  padding-top: var(--tg-safe-area-inset-top);
  padding-bottom: var(--tg-safe-area-inset-bottom);
}
```

---

### Pitfall 7: Not Checking API Availability

**Problem:** Calling WebApp API methods that don't exist in older Telegram versions.

**Solution:** Use `isVersionAtLeast()` to check version support.

```javascript
if (window.Telegram.WebApp.isVersionAtLeast('6.1')) {
  window.Telegram.WebApp.BackButton.show();
} else {
  console.warn('BackButton not supported in this Telegram version');
}
```

---

### Pitfall 8: Expired initData

**Problem:** Server rejects authentication because initData is too old.

**Solution:** Implement reasonable TTL and handle expiration gracefully.

```python
# Server-side
MAX_AGE_SECONDS = 600  # 10 minutes for production

if age_seconds > MAX_AGE_SECONDS:
    return {"error": "Session expired, please reload the Mini App"}
```

---

### Pitfall 9: Not Using Constant-Time Comparison

**Problem:** Timing attacks can leak hash information.

**Solution:** Use `hmac.compare_digest()` (Python) or `crypto.timingSafeEqual()` (Node.js).

```python
# ❌ WRONG: Timing attack vulnerable
if calculated_hash == hash_value:
    pass

# ✅ CORRECT: Constant-time comparison
if hmac.compare_digest(calculated_hash, hash_value):
    pass
```

---

### Pitfall 10: HTTP in Production

**Problem:** Telegram rejects HTTP Mini Apps in production.

**Solution:** Use HTTPS with valid SSL certificate (Let's Encrypt).

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d app.yourdomain.com
```

---

## WebApp API Integration

### Availability Checks

Always check if Telegram WebApp API is available before using it.

```javascript
function isTelegramWebApp() {
  return typeof window !== 'undefined' && 
         window.Telegram && 
         window.Telegram.WebApp;
}

if (isTelegramWebApp()) {
  window.Telegram.WebApp.ready();
} else {
  console.warn('Not running in Telegram WebApp environment');
}
```

---

### MainButton Usage

```javascript
const mainButton = window.Telegram.WebApp.MainButton;

// Configure button
mainButton.setText('Continue');
mainButton.show();

// Handle click
mainButton.onClick(() => {
  console.log('Main button clicked');
  // Perform action
});

// Show loading
mainButton.showProgress();

// Hide loading
mainButton.hideProgress();

// Hide button
mainButton.hide();
```

**Source:** [Telegram WebApp API - BottomButton](https://core.telegram.org/bots/webapps#bottombutton)

---

### BackButton Usage

```javascript
const backButton = window.Telegram.WebApp.BackButton;

// Show back button
backButton.show();

// Handle click
backButton.onClick(() => {
  console.log('Back button clicked');
  // Navigate back
});

// Hide back button
backButton.hide();
```

**Source:** [Telegram WebApp API - BackButton](https://core.telegram.org/bots/webapps#backbutton)

---

### Popup Methods

```javascript
// Simple alert
window.Telegram.WebApp.showAlert('Operation completed!', () => {
  console.log('Alert closed');
});

// Confirmation dialog
window.Telegram.WebApp.showConfirm('Are you sure?', (confirmed) => {
  if (confirmed) {
    console.log('User confirmed');
  }
});

// Custom popup
window.Telegram.WebApp.showPopup({
  title: 'Choose an option',
  message: 'Please select one of the following:',
  buttons: [
    { id: 'option1', type: 'default', text: 'Option 1' },
    { id: 'option2', type: 'default', text: 'Option 2' },
    { type: 'cancel' }
  ]
}, (buttonId) => {
  console.log('Button clicked:', buttonId);
});
```

**Source:** [Telegram WebApp API - Popup methods](https://core.telegram.org/bots/webapps#initializing-mini-apps)

---

### Haptic Feedback

```javascript
const haptic = window.Telegram.WebApp.HapticFeedback;

// Impact feedback
haptic.impactOccurred('light');   // light, medium, heavy, rigid, soft
haptic.impactOccurred('medium');
haptic.impactOccurred('heavy');

// Notification feedback
haptic.notificationOccurred('success');  // success, error, warning
haptic.notificationOccurred('error');

// Selection feedback
haptic.selectionChanged();
```

**Source:** [Telegram WebApp API - HapticFeedback](https://core.telegram.org/bots/webapps#hapticfeedback)

---

## Theme and Viewport Handling

### Theme Parameters

Access current theme colors:

```javascript
const theme = window.Telegram.WebApp.themeParams;

console.log(theme.bg_color);              // Background color
console.log(theme.text_color);            // Text color
console.log(theme.hint_color);            // Hint text color
console.log(theme.link_color);            // Link color
console.log(theme.button_color);          // Button color
console.log(theme.button_text_color);     // Button text color
console.log(theme.secondary_bg_color);    // Secondary background
```

**CSS Variables:** Theme colors are also available as CSS variables:

```css
.container {
  background-color: var(--tg-theme-bg-color);
  color: var(--tg-theme-text-color);
}

.button {
  background-color: var(--tg-theme-button-color);
  color: var(--tg-theme-button-text-color);
}
```

**Source:** [Telegram WebApp API - ThemeParams](https://core.telegram.org/bots/webapps#themeparams)

---

### Viewport Handling

```javascript
// Current viewport height (changes during animations)
const currentHeight = window.Telegram.WebApp.viewportHeight;

// Stable viewport height (only updates when stable)
const stableHeight = window.Telegram.WebApp.viewportStableHeight;

// Check if expanded
const isExpanded = window.Telegram.WebApp.isExpanded;

// Expand to full height
window.Telegram.WebApp.expand();

// Listen to viewport changes
window.Telegram.WebApp.onEvent('viewportChanged', (event) => {
  if (event.isStateStable) {
    console.log('Viewport stable at:', window.Telegram.WebApp.viewportStableHeight);
  }
});
```

**CSS Variables:**

```css
.full-height {
  height: var(--tg-viewport-height);        /* Dynamic height */
  min-height: var(--tg-viewport-stable-height);  /* Stable height */
}
```

**Source:** [Telegram WebApp API - Viewport](https://core.telegram.org/bots/webapps#initializing-mini-apps)

---

## Testing and Debugging

### Test Environment

Use Telegram's test environment for development:

1. **iOS:** Download [Telegram Beta](https://testflight.apple.com/join/u6iogfd0)
2. **Android:** Download test APK from [Telegram's website](https://telegram.org/android)
3. **Desktop:** Use test server flag

**Test API Endpoint:**
```
https://api.telegram.org/bot<token>/test/METHOD_NAME
```

**Note:** Test environment allows HTTP (no HTTPS required).

**Source:** [Telegram WebApp API - Testing](https://core.telegram.org/bots/webapps#testing-mini-apps)

---

### Debug Mode

Enable debug mode to inspect Mini Apps:

**iOS:**
1. Open Settings → Advanced → Experimental Settings
2. Enable "WebView Inspecting"
3. Connect device to Mac
4. Open Safari → Develop → [Device] → [Mini App]

**Android:**
1. Enable USB debugging on device
2. Connect to computer
3. Open Chrome → `chrome://inspect`
4. Find Mini App WebView

**Desktop (Windows/Linux):**
- Right-click in Mini App → "Inspect Element"

**macOS:**
1. Open Mini App
2. Press `Cmd+Option+I` to open DevTools

**Source:** [Telegram WebApp API - Debug Mode](https://core.telegram.org/bots/webapps#debug-mode-for-mini-apps)

---

### Common Debug Checks

```javascript
// Check if running in Telegram
console.log('Is Telegram:', !!window.Telegram?.WebApp);

// Check version
console.log('Version:', window.Telegram.WebApp.version);

// Check platform
console.log('Platform:', window.Telegram.WebApp.platform);

// Check initData
console.log('InitData:', window.Telegram.WebApp.initData);

// Check theme
console.log('Theme:', window.Telegram.WebApp.themeParams);

// Check viewport
console.log('Viewport height:', window.Telegram.WebApp.viewportHeight);
console.log('Is expanded:', window.Telegram.WebApp.isExpanded);
```

---

## Additional Resources

### Official Documentation

- **Telegram Mini Apps:** https://core.telegram.org/bots/webapps
- **Bot API:** https://core.telegram.org/bots/api
- **Mini Apps Platform:** https://docs.telegram-mini-apps.com/

### Community Resources

- **Telegram Mini Apps GitHub:** https://github.com/Telegram-Mini-Apps/telegram-apps
- **@BotFather:** Create and configure bots
- **@DurgerKingBot:** Official demo Mini App

---

## Checklist for Production

Before deploying your Mini App to production, verify:

- [ ] `Telegram.WebApp.ready()` is called early
- [ ] InitData validation implemented on server
- [ ] auth_date TTL check implemented (5-10 minutes recommended)
- [ ] Bot token stored in environment variables only
- [ ] HTTPS enabled with valid SSL certificate
- [ ] CORS configured with explicit origins
- [ ] HttpOnly cookies used for session management
- [ ] Theme changes handled (`themeChanged` event)
- [ ] Viewport changes handled (`viewportChanged` event)
- [ ] Safe area insets respected
- [ ] Version checks for API features (`isVersionAtLeast()`)
- [ ] Error handling for all API calls
- [ ] Fallbacks for non-Telegram environments
- [ ] Debug mode disabled in production
- [ ] No console errors in Telegram WebView

---

## Summary

Building secure and user-friendly Telegram Mini Apps requires:

1. **Early initialization** with `ready()` and `expand()`
2. **Server-side validation** of initData using HMAC-SHA256
3. **Secure session management** with HttpOnly cookies
4. **Theme and viewport reactivity** for seamless UX
5. **Proper error handling** and fallbacks
6. **HTTPS in production** with correct CORS configuration

By following these standards and avoiding common pitfalls, you'll create Mini Apps that are secure, performant, and provide an excellent user experience within the Telegram ecosystem.

---

**Document Version:** 1.0  
**Last Updated:** 2025  
**Sources:** Official Telegram documentation (core.telegram.org, docs.telegram-mini-apps.com)
