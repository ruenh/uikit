<script lang="ts">
  import { onMount } from "svelte";
  import { theme, type ThemeMode } from "../../lib/theme";

  let currentTheme: ThemeMode = "premium";
  let isLoading = false;

  onMount(async () => {
    await theme.init();
    currentTheme = theme.current;
  });

  async function setMode(mode: ThemeMode) {
    if (isLoading) return;
    isLoading = true;
    try {
      await theme.set(mode);
      currentTheme = mode;
    } finally {
      isLoading = false;
    }
  }

  const btn = (mode: ThemeMode) =>
    `flex items-center gap-2 rounded-full px-4 py-2 text-sm font-medium transition
     ${currentTheme === mode
        ? "bg-[var(--gradient-primary)] text-white shadow-[var(--shadow-glow)]"
        : "text-[var(--color-text-secondary)] hover:bg-white/5 hover:text-white"}`;
</script>

<div class="inline-flex rounded-full border border-white/10 bg-white/5 p-1 backdrop-blur-md">
  <button class={btn("native")} disabled={isLoading} on:click={() => setMode("native")}>
    <span class="text-base">🎨</span><span class="hidden sm:inline">Native</span>
  </button>
  <button class={btn("premium")} disabled={isLoading} on:click={() => setMode("premium")}>
    <span class="text-base">✨</span><span class="hidden sm:inline">Premium</span>
  </button>
  <button class={btn("mixed")} disabled={isLoading} on:click={() => setMode("mixed")}>
    <span class="text-base">🎭</span><span class="hidden sm:inline">Mixed</span>
  </button>
</div>
