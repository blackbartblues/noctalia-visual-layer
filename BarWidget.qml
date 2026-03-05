import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

NIconButton {
  id: root

  property var pluginApi: null

  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  // --- STANDARD SETTINGS LOGIC ---
  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  // Icon color from config, fallback to "onSurface"
  readonly property string iconColorKey: cfg.iconColor ?? defaults.iconColor ?? "onSurface"

  // --- PLUGIN DATA ---
  icon: "adjustments-horizontal"
  tooltipText: pluginApi?.tr("widget.tooltip") || "Hyprland Visual Layer"

  // --- SYSTEM STYLES ---
  tooltipDirection: BarService.getTooltipDirection(screen?.name)
  baseSize: Style.getCapsuleHeightForScreen(screen?.name)
  applyUiScale: false

  customRadius: Style.radiusL

  // Capsule colors
  colorBg: Style.capsuleColor
  colorFg: Color.resolveColorKey(iconColorKey)

  border.color: Style.capsuleBorderColor
  border.width: Style.capsuleBorderWidth

  // --- INTERACTION ---
  onClicked: {
    if (pluginApi) {
      pluginApi.togglePanel(root.screen);
    }
  }

}
