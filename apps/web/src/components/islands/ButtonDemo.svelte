<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import * as tg from '../../lib/tg';

  // State for MainButton
  let mainButtonText = $state('Click Me!');
  let mainButtonVisible = $state(false);
  let mainButtonColor = $state('#6366f1');
  let mainButtonTextColor = $state('#ffffff');
  let mainButtonClickCount = $state(0);

  // State for BackButton
  let backButtonVisible = $state(false);
  let backButtonClickCount = $state(0);

  // Handlers
  let mainButtonHandler: (() => void) | null = null;
  let backButtonHandler: (() => void) | null = null;

  onMount(() => {
    // Initialize handlers
    mainButtonHandler = () => {
      mainButtonClickCount++;
      tg.hapticImpact('medium');
    };

    backButtonHandler = () => {
      backButtonClickCount++;
      tg.hapticImpact('light');
    };

    // Register handlers
    tg.onMainButtonClick(mainButtonHandler);
    tg.onBackButtonClick(backButtonHandler);
  });

  onDestroy(() => {
    // Clean up handlers
    if (mainButtonHandler) {
      tg.offMainButtonClick(mainButtonHandler);
    }
    if (backButtonHandler) {
      tg.offBackButtonClick(backButtonHandler);
    }

    // Hide buttons on unmount
    tg.hideMainButton();
    tg.hideBackButton();
  });

  // MainButton actions
  function toggleMainButton() {
    if (mainButtonVisible) {
      tg.hideMainButton();
      mainButtonVisible = false;
    } else {
      tg.setMainButtonParams({
        text: mainButtonText,
        color: mainButtonColor,
        text_color: mainButtonTextColor,
        is_active: true,
        is_visible: true,
      });
      tg.showMainButton();
      mainButtonVisible = true;
    }
  }

  function updateMainButtonText() {
    tg.setMainButtonText(mainButtonText);
    tg.setMainButtonParams({
      text: mainButtonText,
    });
  }

  function updateMainButtonColor() {
    tg.setMainButtonParams({
      color: mainButtonColor,
      text_color: mainButtonTextColor,
    });
  }

  // BackButton actions
  function toggleBackButton() {
    if (backButtonVisible) {
      tg.hideBackButton();
      backButtonVisible = false;
    } else {
      tg.showBackButton();
      backButtonVisible = true;
    }
  }

  function resetCounters() {
    mainButtonClickCount = 0;
    backButtonClickCount = 0;
  }
</script>

<div class="space-y-8">
  <!-- MainButton Demo -->
  <section class="demo-card">
    <h2 class="text-2xl font-bold mb-4 text-white">MainButton</h2>
    <p class="text-gray-300 mb-6">
      The MainButton is a prominent button at the bottom of the Mini App. It's controlled by the WebApp API and appears in the Telegram interface.
    </p>

    <div class="space-y-4">
      <!-- Toggle MainButton -->
      <div>
        <button
          onclick={toggleMainButton}
          class="btn-primary"
        >
          {mainButtonVisible ? 'Hide' : 'Show'} MainButton
        </button>
        <p class="text-sm text-gray-400 mt-2">
          Status: <span class="font-semibold">{mainButtonVisible ? 'Visible' : 'Hidden'}</span>
        </p>
      </div>

      <!-- Text Input -->
      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Button Text
        </label>
        <div class="flex gap-2">
          <input
            type="text"
            bind:value={mainButtonText}
            class="input-field flex-1"
            placeholder="Enter button text"
          />
          <button
            onclick={updateMainButtonText}
            class="btn-secondary"
            disabled={!mainButtonVisible}
          >
            Update Text
          </button>
        </div>
      </div>

      <!-- Color Inputs -->
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-300 mb-2">
            Button Color
          </label>
          <div class="flex gap-2">
            <input
              type="color"
              bind:value={mainButtonColor}
              class="color-input"
            />
            <input
              type="text"
              bind:value={mainButtonColor}
              class="input-field flex-1"
              placeholder="#6366f1"
            />
          </div>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-300 mb-2">
            Text Color
          </label>
          <div class="flex gap-2">
            <input
              type="color"
              bind:value={mainButtonTextColor}
              class="color-input"
            />
            <input
              type="text"
              bind:value={mainButtonTextColor}
              class="input-field flex-1"
              placeholder="#ffffff"
            />
          </div>
        </div>
      </div>

      <button
        onclick={updateMainButtonColor}
        class="btn-secondary"
        disabled={!mainButtonVisible}
      >
        Update Colors
      </button>

      <!-- Click Counter -->
      <div class="stats-card">
        <p class="text-sm text-gray-400">MainButton Clicks:</p>
        <p class="text-3xl font-bold text-white">{mainButtonClickCount}</p>
      </div>

      <!-- Code Snippet -->
      <details class="code-snippet">
        <summary class="cursor-pointer text-sm font-medium text-gray-300 mb-2">
          Show Code
        </summary>
        <pre class="text-xs overflow-x-auto"><code>{`import * as tg from './lib/tg';

// Show MainButton with custom text and colors
tg.setMainButtonParams({
  text: '${mainButtonText}',
  color: '${mainButtonColor}',
  text_color: '${mainButtonTextColor}',
  is_active: true,
  is_visible: true,
});
tg.showMainButton();

// Handle clicks
tg.onMainButtonClick(() => {
  console.log('MainButton clicked!');
  tg.hapticImpact('medium');
});

// Update text
tg.setMainButtonText('New Text');

// Hide button
tg.hideMainButton();`}</code></pre>
      </details>
    </div>
  </section>

  <!-- BackButton Demo -->
  <section class="demo-card">
    <h2 class="text-2xl font-bold mb-4 text-white">BackButton</h2>
    <p class="text-gray-300 mb-6">
      The BackButton appears in the Mini App header and provides navigation functionality. It's commonly used for going back to previous screens.
    </p>

    <div class="space-y-4">
      <!-- Toggle BackButton -->
      <div>
        <button
          onclick={toggleBackButton}
          class="btn-primary"
        >
          {backButtonVisible ? 'Hide' : 'Show'} BackButton
        </button>
        <p class="text-sm text-gray-400 mt-2">
          Status: <span class="font-semibold">{backButtonVisible ? 'Visible' : 'Hidden'}</span>
        </p>
      </div>

      <!-- Click Counter -->
      <div class="stats-card">
        <p class="text-sm text-gray-400">BackButton Clicks:</p>
        <p class="text-3xl font-bold text-white">{backButtonClickCount}</p>
      </div>

      <!-- Code Snippet -->
      <details class="code-snippet">
        <summary class="cursor-pointer text-sm font-medium text-gray-300 mb-2">
          Show Code
        </summary>
        <pre class="text-xs overflow-x-auto"><code>{`import * as tg from './lib/tg';

// Show BackButton
tg.showBackButton();

// Handle clicks
tg.onBackButtonClick(() => {
  console.log('BackButton clicked!');
  tg.hapticImpact('light');
  // Navigate back or perform action
});

// Hide button
tg.hideBackButton();`}</code></pre>
      </details>
    </div>
  </section>

  <!-- Reset Button -->
  <div class="text-center">
    <button
      onclick={resetCounters}
      class="btn-secondary"
    >
      Reset Counters
    </button>
  </div>
</div>

<style>
  .demo-card {
    background: rgba(255, 255, 255, 0.05);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 16px;
    padding: 1.5rem;
  }

  .stats-card {
    background: rgba(99, 102, 241, 0.1);
    border: 1px solid rgba(99, 102, 241, 0.3);
    border-radius: 12px;
    padding: 1rem;
    text-align: center;
  }

  .code-snippet {
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 8px;
    padding: 1rem;
    margin-top: 1rem;
  }

  .code-snippet pre {
    margin-top: 0.5rem;
    color: #e5e7eb;
    font-family: 'Courier New', monospace;
  }

  .btn-primary {
    background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
    color: white;
    padding: 0.75rem 1.5rem;
    border-radius: 12px;
    font-weight: 600;
    border: none;
    cursor: pointer;
    transition: all 0.2s;
  }

  .btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(99, 102, 241, 0.4);
  }

  .btn-primary:active {
    transform: translateY(0);
  }

  .btn-secondary {
    background: rgba(255, 255, 255, 0.1);
    color: white;
    padding: 0.75rem 1.5rem;
    border-radius: 12px;
    font-weight: 600;
    border: 1px solid rgba(255, 255, 255, 0.2);
    cursor: pointer;
    transition: all 0.2s;
  }

  .btn-secondary:hover:not(:disabled) {
    background: rgba(255, 255, 255, 0.15);
    border-color: rgba(255, 255, 255, 0.3);
  }

  .btn-secondary:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  .input-field {
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 8px;
    padding: 0.5rem 0.75rem;
    color: white;
    font-size: 0.875rem;
  }

  .input-field:focus {
    outline: none;
    border-color: #6366f1;
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
  }

  .color-input {
    width: 48px;
    height: 40px;
    border-radius: 8px;
    border: 1px solid rgba(255, 255, 255, 0.2);
    cursor: pointer;
    background: transparent;
  }

  .color-input::-webkit-color-swatch-wrapper {
    padding: 2px;
  }

  .color-input::-webkit-color-swatch {
    border: none;
    border-radius: 6px;
  }
</style>
