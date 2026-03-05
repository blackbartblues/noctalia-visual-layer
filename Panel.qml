import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Controls
import qs.Commons
import qs.Widgets
import qs.Services.UI
import "./modules"

Item {
    id: root

    property var pluginApi: null
    readonly property int barHeight: 20

    readonly property string pluginDir: Settings.configDir + "plugins/noctalia-visual-layer"

    // --- SCRIPT ENGINE ---
    Process {
        id: bashProcess
        onStdoutChanged: Logger.i("NVL", stdout)
        onStderrChanged: Logger.e("NVL", stderr)
    }

    function runScript(scriptName, args) {
        bashProcess.command = ["bash", pluginDir + "/assets/scripts/" + scriptName, args]
        bashProcess.running = true
    }

    Component.onDestruction: {
        if (bashProcess.running) bashProcess.terminate()
    }

    property real contentPreferredWidth: 700 * Style.uiScaleRatio
    property real contentPreferredHeight: 700 * Style.uiScaleRatio

    anchors.fill: parent

    NBox {
        anchors.fill: parent
        anchors.topMargin: root.barHeight
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginL
            spacing: Style.marginM

            // 1. CENTERED HEADER
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginS
                Layout.bottomMargin: Style.marginL

                Item { Layout.fillWidth: true }

                NIcon {
                    icon: "adjustments-horizontal"
                    color: Color.mPrimary
                    pointSize: Style.fontSizeXXL
                }

                ColumnLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignCenter
                    NText {
                        text: pluginApi?.tr("panel.header_title") || "Hyprland Visual"
                        pointSize: Style.fontSizeXL
                        font.weight: Font.Bold
                        color: Color.mPrimary
                    }
                    NText {
                        text: pluginApi?.tr("panel.header_subtitle") || "Aesthetic Control Center"
                        pointSize: Style.fontSizeS
                        color: Color.mOnSurfaceVariant
                    }
                }

                Item { Layout.fillWidth: true }
            }

            // 2. NAVIGATION BAR
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginM

                TabItem {
                    label: pluginApi?.tr("panel.tabs.home") || "Home"
                    iconName: "home"
                    index: 0
                    accentColor: "#38bdf8"
                    isSelected: stackLayout.currentIndex === 0
                }
                TabItem {
                    label: pluginApi?.tr("panel.tabs.animations") || "Animations"
                    iconName: "movie"
                    index: 1
                    accentColor: "#fbbf24"
                    isSelected: stackLayout.currentIndex === 1
                }
                TabItem {
                    label: pluginApi?.tr("panel.tabs.borders") || "Borders"
                    iconName: "border-all"
                    index: 2
                    accentColor: "#10b981"
                    isSelected: stackLayout.currentIndex === 2
                }
                TabItem {
                    label: pluginApi?.tr("panel.tabs.effects") || "Effects"
                    iconName: "wand"
                    index: 3
                    accentColor: "#c084fc"
                    isSelected: stackLayout.currentIndex === 3
                }
            }

            // 3. CONTENT AREA
            NBox {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Color.mSurfaceVariant
                radius: Style.radiusM
                clip: true

                StackLayout {
                    id: stackLayout
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    currentIndex: 0

                    // Pass pluginApi and pluginDir to child modules
                    WelcomeModule   { pluginApi: root.pluginApi; pluginDir: root.pluginDir; runScript: root.runScript }
                    AnimationModule { pluginApi: root.pluginApi; pluginDir: root.pluginDir; runScript: root.runScript }
                    BorderModule    { pluginApi: root.pluginApi; pluginDir: root.pluginDir; runScript: root.runScript }
                    ShaderModule    { pluginApi: root.pluginApi; pluginDir: root.pluginDir; runScript: root.runScript }
                }
            }
        }
    }

    component TabItem : Rectangle {
        id: tabRoot
        property string label
        property string iconName
        property color accentColor: Color.mPrimary
        property int index
        property bool isSelected

        Layout.fillWidth: true
        height: 40 * Style.uiScaleRatio
        radius: Style.radiusM

        readonly property color currentAccent: isSelected ? Color.mPrimary : accentColor

        color: isSelected
        ? Qt.alpha(Color.mPrimary, 0.15)
        : (tabMouse.containsMouse ? Qt.alpha(accentColor, 0.1) : "transparent")

        border.width: 1
        border.color: isSelected
        ? Color.mPrimary
        : (tabMouse.containsMouse ? accentColor : Qt.alpha(accentColor, 0.2))

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        MouseArea {
            id: tabMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: stackLayout.currentIndex = index
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: Style.marginM

            NIcon {
                icon: iconName
                color: (isSelected || tabMouse.containsMouse) ? tabRoot.currentAccent : Color.mOnSurfaceVariant
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            NText {
                text: label
                font.weight: isSelected ? Font.Bold : Font.Normal
                color: (isSelected || tabMouse.containsMouse) ? Color.mOnSurface : Color.mOnSurfaceVariant
                pointSize: Style.fontSizeS
            }
        }
    }
}
