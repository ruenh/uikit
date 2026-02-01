// apps/web/src/lib/api.ts
// API client for backend communication with cookie-based authentication
// Source: Design document section 2 (API Client)
// Requirements: 3.2, 10.1, 10.2

const API_BASE_URL = import.meta.env.PUBLIC_API_URL || 'https://api.yourdomain.com';

/**
 * Response from POST /api/auth/validate
 */
interface AuthResponse {
  success: boolean;
  user: {
    id: number;
    telegram_id: number;
    first_name: string;
    last_name?: string;
    username?: string;
  };
}

/**
 * Response from GET/PUT /api/preferences
 */
interface PreferencesResponse {
  theme_mode: 'native' | 'premium' | 'mixed';
  reduced_motion: boolean;
}

/**
 * API client with cookie-based authentication
 * 
 * CRITICAL: All authenticated endpoints MUST use credentials: 'include'
 * to send HttpOnly session cookies with requests.
 * 
 * Source: FastAPI CORS + cookie authentication pattern
 * Verified: credentials: 'include' required for cross-origin cookie transmission
 */
export const api = {
  /**
   * Authentication endpoints
   */
  auth: {
    /**
     * Validate Telegram initData and establish authenticated session
     * 
     * @param initData - Raw initData string from Telegram WebApp
     * @returns User information and success status
     * @throws Error if authentication fails
     * 
     * Side effect: Sets HttpOnly session cookie on success
     */
    validate: async (initData: string): Promise<AuthResponse> => {
      const response = await fetch(`${API_BASE_URL}/api/auth/validate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include', // REQUIRED: Include cookies in request/response
        body: JSON.stringify({ initData }),
      });
      
      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.detail || `Auth failed: ${response.status}`);
      }
      
      return response.json();
    },
  },
  
  /**
   * User preferences endpoints
   */
  preferences: {
    /**
     * Get user preferences from database
     * 
     * @returns User preferences (theme_mode, reduced_motion)
     * @throws Error if not authenticated or request fails
     * 
     * Requires: Valid session cookie (set by auth.validate)
     */
    get: async (): Promise<PreferencesResponse> => {
      const response = await fetch(`${API_BASE_URL}/api/preferences`, {
        credentials: 'include', // REQUIRED: Include session cookie
      });
      
      if (!response.ok) {
        throw new Error(`Failed to get preferences: ${response.status}`);
      }
      
      return response.json();
    },
    
    /**
     * Update user preferences in database
     * 
     * @param prefs - Partial preferences object to update
     * @returns Updated preferences
     * @throws Error if not authenticated or request fails
     * 
     * Requires: Valid session cookie (set by auth.validate)
     */
    update: async (prefs: Partial<PreferencesResponse>): Promise<PreferencesResponse> => {
      const response = await fetch(`${API_BASE_URL}/api/preferences`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include', // REQUIRED: Include session cookie
        body: JSON.stringify(prefs),
      });
      
      if (!response.ok) {
        throw new Error(`Failed to update preferences: ${response.status}`);
      }
      
      return response.json();
    },
  },
  
  /**
   * Health check endpoint
   */
  health: {
    /**
     * Check API and database health
     * 
     * @returns Health status object
     * 
     * Note: No authentication required
     */
    check: async (): Promise<{ status: string; database?: string }> => {
      const response = await fetch(`${API_BASE_URL}/api/health`);
      return response.json();
    },
  },
};
