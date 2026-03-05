# Changelog

## [Unreleased] - Code Review Fixes

### Added
- `Main.qml` with `IpcHandler` and `toggle()` function for keybind compatibility
- `pluginDir` readonly property in `Main.qml` using `Settings.configDir` for portable path resolution

### Changed
- Plugin renamed to **Hyprland Visual Layer** with `hyprland` tag in manifest
- All code comments translated from Spanish to English
- All Spanish fallback strings replaced with English equivalents matching `en.json`
- All Spanish fallback strings replaced with values from `en.json`
- `pluginApi?.tr("key") || "fallback"` pattern used everywhere — removed custom `tr()` wrappers from all modules
- Plugin directory path now uses `Settings.configDir + "plugins/noctalia-visual-layer"` instead of `Quickshell.env("HOME") + "/.config/..."`
- All hardcoded spacing/margin values replaced with `Style.marginXXS` / `Style.marginXS` / `Style.marginS` / `Style.marginM` / `Style.marginL` constants
- `BarWidget`: `openPanel()` replaced with `togglePanel()` (correct pluginApi method)
- `BarWidget`: removed non-functional Settings context menu (no settings entry point)
- Scanner processes now guard against empty `pluginDir` on startup; re-run via `onPluginDirChanged`
- Image source in `WelcomeModule` uses `pluginDir` property instead of hardcoded path
- `font.family: Style.fontMono` removed from `BorderModule` (property does not exist)

### Fixed
- `Component.onDestruction` added to `Panel.qml`, `AnimationModule`, `BorderModule`, `ShaderModule` to terminate bash processes and prevent memory leaks
- Scanner processes no longer fire with empty path when `pluginDir` is not yet resolved
- `console.log` / `console.error` replaced with `Logger.i` / `Logger.e` throughout

### Removed
- `runHypr: null` unused property removed from all modules and `Panel.qml`
- Orphaned `widget.menu_settings` translation key removed from all 16 i18n files
- Custom `tr()` helper functions removed from `AnimationModule`, `BorderModule`, `ShaderModule`, `WelcomeModule`
