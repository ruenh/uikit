# Frontend Update Guide

## Quick Update (Production)

SSH to your server and run:

```bash
cd /opt/tma-studio
git pull
cd apps/web
npm install
npm run build
systemctl reload nginx
```

## What Changed

### UI Redesign (Astro-style)
- **Layout.astro**: Fixed HTML structure, proper global.css import
- **index.astro**: Hero section with gradients, glass cards grid
- **NavigationTile.astro**: Glass morphism cards with hover effects
- **DemoCard.astro**: Minimal glass card component
- **ThemeSwitcher.svelte**: Compact pill-style switcher

### Design System
- Tailwind utility classes + CSS tokens from global.css
- Glass morphism effects (backdrop-blur, border-white/10)
- Gradient backgrounds with radial overlays
- Glow shadows on hover
- Responsive typography with clamp()

### No Breaking Changes
- Astro + Svelte islands architecture preserved
- Backend/bot unchanged
- All existing routes work
- Theme switching functionality intact

## Verification

After update, check:
1. https://givexy.ru - should show new hero design
2. Theme switcher - should work (Native/Premium/Mixed)
3. Navigation tiles - should have glass effect and hover glow
4. All demo pages - should load correctly

## Rollback (if needed)

```bash
cd /opt/tma-studio
git log --oneline -5  # find previous commit hash
git checkout <previous-hash>
cd apps/web
npm run build
systemctl reload nginx
```
