<script lang="ts">
  import { onMount, onDestroy } from "svelte";
  import * as tg from "../../lib/tg";

  let mainButtonText = $state("Click Me!");
  let mainButtonVisible = $state(false);
  let mainButtonColor = $state("#6366f1");
  let mainButtonTextColor = $state("#ffffff");
  let mainButtonClickCount = $state(0);

  let backButtonVisible = $state(false);
  let backButtonClickCount = $state(0);

  let mainButtonHandler: (() => void) | null = null;
  let backButtonHandler: (() => void) | null = null;

  onMount(() => {
    mainButtonHandler = () => { mainButtonClickCount++; tg.hapticImpact("medium"); };
    backButtonHandler = () => { backButtonClickCount++; tg.hapticImpact("light"); };
    tg.onMainButtonClick(mainButtonHandler);
    tg.onBackButtonClick(backButtonHandler);
  });

  onDestroy(() => {
    if (mainButtonHandler) tg.offMainButtonClick(mainButtonHandler);
    if (backButtonHandler) tg.offBackButtonClick(backButtonHandler);
    tg.hideMainButton();
    tg.hideBackButton();
  });

  function toggleMainButton() {
    if (mainButtonVisible) { tg.hideMainButton(); mainButtonVisible = false; return; }
    tg.setMainButtonParams({ text: mainButtonText, color: mainButtonColor, text_color: mainButtonTextColor, is_active: true, is_visible: true });
    tg.showMainButton();
    mainButtonVisible = true;
  }

  function updateMainButtonText() {
    tg.setMainButtonText(mainButtonText);
    tg.setMainButtonParams({ text: mainButtonText });
  }

  function updateMainButtonColor() {
    tg.setMainButtonParams({ color: mainButtonColor, text_color: mainButtonTextColor });
  }

  function toggleBackButton() {
    if (backButtonVisible) { tg.hideBackButton(); backButtonVisible = false; return; }
    tg.showBackButton();
    backButtonVisible = true;
  }

  function resetCounters() { mainButtonClickCount = 0; backButtonClickCount = 0; }
</script>

<div class="space-y-6">
  <!-- MainButton card -->
  <section class="glass rounded-2xl p-5 sm:p-6 shadow-[var(--shadow-md)]">
    <h2 class="text-xl font-semibold">MainButton</h2>
    <p class="mt-2 text-sm leading-relaxed text-[var(--color-text-secondary)]">
      The MainButton is a prominent button at the bottom of the Mini App. It's controlled by the WebApp API and appears in the Telegram interface.
    </p>

    <div class="mt-4 flex flex-col sm:flex-row gap-3 sm:items-center">
      <button class="w-full sm:w-auto rounded-xl px-4 py-3 font-semibold text-white bg-[var(--gradient-primary)] shadow-[var(--shadow-glow)] active:translate-y-[1px] transition"
        on:click={toggleMainButton}>
        {mainButtonVisible ? "Hide" : "Show"} MainButton
      </button>

      <div class="text-sm text-[var(--color-text-secondary)]">
        Status: <span class="text-white">{mainButtonVisible ? "Visible" : "Hidden"}</span>
      </div>
    </div>

    <div class="mt-5 grid gap-4">
      <div>
        <div class="text-sm font-semibold">Button Text</div>
        <div class="mt-2 flex flex-col sm:flex-row gap-3">
          <input
            class="w-full rounded-xl border border-white/10 bg-black/30 px-3 py-3 text-sm outline-none focus:border-[var(--color-accent-primary)]"
            type="text"
            bind:value={mainButtonText}
            placeholder="Enter button text" />
          <button class="w-full sm:w-auto rounded-xl px-4 py-3 font-semibold bg-white/10 border border-white/10 hover:bg-white/15 disabled:opacity-50 transition"
            on:click={updateMainButtonText}
            disabled={!mainButtonVisible}>
            Update text
          </button>
        </div>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div>
          <div class="text-sm font-semibold">Button Color</div>
          <div class="mt-2 flex items-center gap-3">
            <input class="h-11 w-12 rounded-xl border border-white/10 bg-transparent" type="color" bind:value={mainButtonColor} />
            <input class="w-full rounded-xl border border-white/10 bg-black/30 px-3 py-3 text-sm outline-none focus:border-[var(--color-accent-primary)]"
              type="text" bind:value={mainButtonColor} />
          </div>
        </div>

        <div>
          <div class="text-sm font-semibold">Text Color</div>
          <div class="mt-2 flex items-center gap-3">
            <input class="h-11 w-12 rounded-xl border border-white/10 bg-transparent" type="color" bind:value={mainButtonTextColor} />
            <input class="w-full rounded-xl border border-white/10 bg-black/30 px-3 py-3 text-sm outline-none focus:border-[var(--color-accent-primary)]"
              type="text" bind:value={mainButtonTextColor} />
          </div>
        </div>
      </div>

      <button class="w-full rounded-xl px-4 py-3 font-semibold bg-white/10 border border-white/10 hover:bg-white/15 disabled:opacity-50 transition"
        on:click={updateMainButtonColor}
        disabled={!mainButtonVisible}>
        Update colors
      </button>

      <div class="rounded-xl border border-[rgba(99,102,241,.25)] bg-[rgba(99,102,241,.10)] p-4 text-center">
        <div class="text-sm text-[var(--color-text-secondary)]">MainButton Clicks</div>
        <div class="mt-1 text-3xl font-extrabold">{mainButtonClickCount}</div>
      </div>

      <details class="rounded-xl border border-white/10 bg-black/20">
        <summary class="cursor-pointer select-none px-4 py-3 text-sm font-semibold">
          Show code
        </summary>
        <pre class="overflow-x-auto px-4 pb-4 text-xs leading-relaxed text-white/90"><code>{`import * as tg from './lib/tg';

// Show MainButton
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

  <!-- BackButton card -->
  <section class="glass rounded-2xl p-5 sm:p-6 shadow-[var(--shadow-md)]">
    <h2 class="text-xl font-semibold">BackButton</h2>
    <p class="mt-2 text-sm leading-relaxed text-[var(--color-text-secondary)]">
      The BackButton appears in the Mini App header and provides navigation functionality.
    </p>

    <div class="mt-4 flex flex-col sm:flex-row gap-3 sm:items-center">
      <button class="w-full sm:w-auto rounded-xl px-4 py-3 font-semibold bg-white/10 border border-white/10 hover:bg-white/15 transition"
        on:click={toggleBackButton}>
        {backButtonVisible ? "Hide" : "Show"} BackButton
      </button>

      <div class="text-sm text-[var(--color-text-secondary)]">
        Status: <span class="text-white">{backButtonVisible ? "Visible" : "Hidden"}</span>
      </div>
    </div>

    <div class="mt-4 rounded-xl border border-white/10 bg-black/20 p-4 text-center">
      <div class="text-sm text-[var(--color-text-secondary)]">BackButton Clicks</div>
      <div class="mt-1 text-3xl font-extrabold">{backButtonClickCount}</div>
    </div>

    <details class="mt-4 rounded-xl border border-white/10 bg-black/20">
      <summary class="cursor-pointer select-none px-4 py-3 text-sm font-semibold">
        Show code
      </summary>
      <pre class="overflow-x-auto px-4 pb-4 text-xs leading-relaxed text-white/90"><code>{`import * as tg from './lib/tg';

// Show BackButton
tg.showBackButton();

// Handle clicks
tg.onBackButtonClick(() => {
  console.log('BackButton clicked!');
  tg.hapticImpact('light');
});

// Hide button
tg.hideBackButton();`}</code></pre>
    </details>
  </section>

  <!-- Reset Button -->
  <div class="text-center">
    <button class="w-full sm:w-auto rounded-xl px-6 py-3 font-semibold bg-white/10 border border-white/10 hover:bg-white/15 transition"
      on:click={resetCounters}>
      Reset counters
    </button>
  </div>
</div>
