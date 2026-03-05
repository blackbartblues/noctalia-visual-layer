import Quickshell
import qs.Commons
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null

    // Plugin directory — accessible from all modules via pluginApi.mainInstance.pluginDir
    readonly property string pluginDir: Settings.configDir + "plugins/noctalia-visual-layer"

    IpcHandler {
        target: "plugin:noctalia-visual-layer"

        function toggle() {
            if (root.pluginApi) {
                root.pluginApi.withCurrentScreen(screen => {
                    root.pluginApi.togglePanel(screen);
                });
            }
        }
    }
}
