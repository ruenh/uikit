<script lang="ts">
  import { onMount } from 'svelte';
  import * as tg from '../../lib/tg';

  // State for popup results
  let lastPopupResult = $state<string>('');
  let lastAlertResult = $state<string>('');
  let lastConfirmResult = $state<string>('');

  // State for custom popup
  let customTitle = $state('Custom Popup');
  let customMessage = $state('This is a custom popup with multiple buttons!');

  onMount(() => {
    // Initialize Telegram WebApp
    tg.ready();
  });

  // Show custom popup with multiple buttons
  function showCustomPopup() {
    tg.showPopup(
      {
        title: customTitle,
        message: customMessage,
        buttons: [
          { id: 'save', type: 'default', text: 'Save' },
          { id: 'delete', type: 'destructive', text: 'Delete' },
          { id: 'cancel', type: 'cancel', text: 'Cancel' },
        ],
      },
      (buttonId) => {
        lastPopupResult = `Button clicked: ${buttonId}`;
        tg.hapticImpact('medium');
      }
    );
  }

  // Show simple popup with OK button
  function showSimplePopup() {
    tg.showPopup(
      {
        title: 'Simple Popup',
        message: 'This is a simple popup with just an OK button.',
        buttons: [{ type: 'ok' }],
      },
      (buttonId) => {
        lastPopupResult = `Simple popup closed with: ${buttonId}`;
        tg.hapticImpact('light');
      }
    );
  }

  // Show popup with close button
  function showClosePopup() {
    tg.showPopup(
      {
        title: 'Info',
        message: 'This popup has a close button instead of OK.',
        buttons: [{ type: 'close' }],
      },
      (buttonId) => {
        lastPopupResult = `Close popup dismissed with: ${buttonId}`;
      }
    );
  }

  // Show alert
  function showAlertDemo() {
    tg.showAlert('This is an alert message. It only has an OK button.', () => {
      lastAlertResult = 'Alert dismissed';
      tg.hapticNotification('success');
    });
  }

  // Show confirm
  function showConfirmDemo() {
    tg.showConfirm('Do you want to proceed with this action?', (confirmed) => {
      lastConfirmResult = confirmed ? 'User confirmed' : 'User cancelled';
      if (confirmed) {
        tg.hapticNotification('success');
      } else {
        tg.hapticNotification('warning');
      }
    });
  }

  // Show destructive confirm
  function showDestructiveConfirm() {
    tg.showPopup(
      {
        title: 'Delete Item',
        message: 'Are you sure you want to delete this item? This action cannot be undone.',
        buttons: [
          { id: 'delete', type: 'destructive', text: 'Delete' },
          { id: 'cancel', type: 'cancel', text: 'Cancel' },
        ],
      },
      (buttonId) => {
        lastPopupResult = buttonId === 'delete' ? 'Item deleted' : 'Deletion cancelled';
        if (buttonId === 'delete') {
          tg.hapticNotification('error');
        }
      }
    );
  }

  // Reset results
  function resetResults() {
    lastPopupResult = '';
    lastAlertResult = '';
    lastConfirmResult = '';
  }
</script>

<div class="space-y-8">
  <!-- Custom Popup Demo -->
  <section class="demo-card">
    <h2 class="text-2xl font-bold mb-4 text-white">Custom Popup</h2>
    <p class="text-gray-300 mb-6">
      The showPopup method allows you to create custom popups with multiple buttons and different button types.
      You can customize the title, message, and button configuration.
    </p>

    <div class="space-y-4">
      <!-- Custom inputs -->
      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Popup Title
        </label>
        <input
          type="text"
          bind:value={customTitle}
          class="input-field w-full"
          placeholder="Enter popup title"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Popup Message
        </label>
        <textarea
          bind:value={customMessage}
          class="input-field w-full"
          rows="3"
          placeholder="Enter popup message"
        ></textarea>
      </div>

      <!-- Popup buttons -->
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <button onclick={showCustomPopup} class="btn-primary">
          Show Custom Popup
        </button>
        <button onclick={showSimplePopup} class="btn-secondary">
          Show Simple Popup
        </button>
        <button onclick={showClosePopup} class="btn-secondary">
          Show Close Popup
        </button>
        <button onclick={showDestructiveConfirm} class="btn-destructive">
          Show Destructive
        </button>
      </div>

      <!-- Result display -->
      {#if lastPopupResult}
        <div class="result-card">
          <p class="text-sm text-gray-400">Last Popup Result:</p>
          <p class="text-lg font-semibold text-white">{lastPopupResult}</p>
        </div>
      {/if}

      <!-- Code Snippet -->
      <details class="code-snippet">
        <summary class="cursor-pointer text-sm font-medium text-gray-300 mb-2">
          Show Code
        </summary>
        <pre class="text-xs overflow-x-auto"><code>{`import * as tg from './lib/tg';

// Show custom popup with multiple buttons
tg.showPopup(
  {
    title: '${customTitle}',
    message: '${customMessage}',
    buttons: [
      { id: 'save', type: 'default', text: 'Save' },
      { id: 'delete', type: 'destructive', text: 'Delete' },
      { id: 'cancel', type: 'cancel', text: 'Cancel' },
    ],
  },
  (buttonId) => {
    console.log('Button clicked:', buttonId);
    tg.hapticImpact('medium');
  }
);

// Button types:
// - 'default': Regular button
// - 'ok': OK button (default)
// - 'close': Close button
// - 'cancel': Cancel button
// - 'destructive': Red/destructive action button`}</code></pre>
      </details>
    </div>
  </section>

  <!-- Alert Demo -->
  <section class="demo-card">
    <h2 class="text-2xl font-bold mb-4 text-white">Alert</h2>
    <p class="text-gray-300 mb-6">
      The showAlert method displays a simple alert message with an OK button. It's useful for showing
      informational messages or notifications to the user.
    </p>

    <div class="space-y-4">
      <button onclick={showAlertDemo} class="btn-primary">
        Show Alert
      </button>

      {#if lastAlertResult}
        <div class="result-card">
          <p class="text-sm text-gray-400">Last Alert Result:</p>
          <p class="text-lg font-semibold text-white">{lastAlertResult}</p>
        </div>
      {/if}

      <!-- Code Snippet -->
      <details class="code-snippet">
        <summary class="cursor-pointer text-sm font-medium text-gray-300 mb-2">
          Show Code
        </summary>
        <pre class="text-xs overflow-x-auto"><code>{`import * as tg from './lib/tg';

// Show alert with callback
tg.showAlert('This is an alert message.', () => {
  console.log('Alert dismissed');
  tg.hapticNotification('success');
});

// Browser fallback: Uses native alert() when not in Telegram`}</code></pre>
      </details>
    </div>
  </section>

  <!-- Confirm Demo -->
  <section class="demo-card">
    <h2 class="text-2xl font-bold mb-4 text-white">Confirm</h2>
    <p class="text-gray-300 mb-6">
      The showConfirm method displays a confirmation dialog with OK and Cancel buttons. The callback
      receives a boolean indicating whether the user confirmed or cancelled.
    </p>

    <div class="space-y-4">
      <button onclick={showConfirmDemo} class="btn-primary">
        Show Confirm
      </button>

      {#if lastConfirmResult}
        <div class="result-card">
          <p class="text-sm text-gray-400">Last Confirm Result:</p>
          <p class="text-lg font-semibold text-white">{lastConfirmResult}</p>
        </div>
      {/if}

      <!-- Code Snippet -->
      <details class="code-snippet">
        <summary class="cursor-pointer text-sm font-medium text-gray-300 mb-2">
          Show Code
        </summary>
        <pre class="text-xs overflow-x-auto"><code>{`import * as tg from './lib/tg';

// Show confirm dialog
tg.showConfirm('Do you want to proceed?', (confirmed) => {
  if (confirmed) {
    console.log('User confirmed');
    tg.hapticNotification('success');
  } else {
    console.log('User cancelled');
    tg.hapticNotification('warning');
  }
});

// Browser fallback: Uses native confirm() when not in Telegram`}</code></pre>
      </details>
    </div>
  </section>

  <!-- Button Types Reference -->
  <section class="demo-card">
    <h2 class="text-2xl font-bold mb-4 text-white">Button Types Reference</h2>
    <div class="space-y-3">
      <div class="reference-item">
        <span class="reference-type">default</span>
        <span class="text-gray-300">Regular button with default styling</span>
      </div>
      <div class="reference-item">
        <span class="reference-type">ok</span>
        <span class="text-gray-300">OK button (used in alerts)</span>
      </div>
      <div class="reference-item">
        <span class="reference-type">close</span>
        <span class="text-gray-300">Close button (dismisses popup)</span>
      </div>
      <div class="reference-item">
        <span class="reference-type">cancel</span>
        <span class="text-gray-300">Cancel button (negative action)</span>
      </div>
      <div class="reference-item">
        <span class="reference-type text-red-400">destructive</span>
        <span class="text-gray-300">Destructive action button (red/warning)</span>
      </div>
    </div>
  </section>

  <!-- Reset Button -->
  <div class="text-center">
    <button onclick={resetResults} class="btn-secondary">
      Reset Results
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

  .result-card {
    background: rgba(99, 102, 241, 0.1);
    border: 1px solid rgba(99, 102, 241, 0.3);
    border-radius: 12px;
    padding: 1rem;
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

  .reference-item {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 0.75rem;
    background: rgba(0, 0, 0, 0.2);
    border-radius: 8px;
  }

  .reference-type {
    font-family: 'Courier New', monospace;
    font-size: 0.875rem;
    font-weight: 600;
    color: #6366f1;
    min-width: 120px;
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
    width: 100%;
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
    width: 100%;
  }

  .btn-secondary:hover {
    background: rgba(255, 255, 255, 0.15);
    border-color: rgba(255, 255, 255, 0.3);
  }

  .btn-destructive {
    background: rgba(239, 68, 68, 0.2);
    color: #fca5a5;
    padding: 0.75rem 1.5rem;
    border-radius: 12px;
    font-weight: 600;
    border: 1px solid rgba(239, 68, 68, 0.4);
    cursor: pointer;
    transition: all 0.2s;
    width: 100%;
  }

  .btn-destructive:hover {
    background: rgba(239, 68, 68, 0.3);
    border-color: rgba(239, 68, 68, 0.6);
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

  textarea.input-field {
    resize: vertical;
    font-family: inherit;
  }

  @media (max-width: 640px) {
    .demo-card {
      padding: 1rem;
    }
  }
</style>
