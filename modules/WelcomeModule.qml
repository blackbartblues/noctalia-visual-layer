import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.settings 1.0 as LabSettings
import Quickshell
import Quickshell.Io
import qs.Widgets
import qs.Commons

NScrollView {
    id: welcomeRoot

    property var pluginApi: null
    property var runScript: null
    property string pluginDir: ""

    Layout.fillWidth: true
    Layout.fillHeight: true
    contentHeight: mainLayout.implicitHeight + 100
    clip: true

    // --- PERSISTENCE ---
    LabSettings.Settings {
        id: welcomeSettings
        fileName: welcomeRoot.pluginDir + "/assets/welcome.conf"
        property bool isSystemActive: false
    }

    ColumnLayout {
        id: mainLayout
        width: welcomeRoot.availableWidth
        spacing: Style.marginXL
        Layout.margins: Style.marginL

        // --- HEADER ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: Style.marginXL
            Layout.bottomMargin: Style.marginM
            Layout.alignment: Qt.AlignHCenter

            Image {
                source: welcomeRoot.pluginDir + "/assets/owl_neon.png"
                fillMode: Image.PreserveAspectFit
                Layout.preferredHeight: 400 * Style.uiScaleRatio
                Layout.preferredWidth: 600 * Style.uiScaleRatio
                Layout.alignment: Qt.AlignHCenter
                smooth: true
            }
        }

        NDivider { Layout.fillWidth: true }

        // --- ACTIVATION ---
        ProCard {
            title: welcomeRoot.pluginApi?.tr("welcome.activation_title") || "System Activation"
            iconName: "power"
            accentColor: welcomeSettings.isSystemActive ? Color.mPrimary : "#ef4444"
            description: welcomeSettings.isSystemActive
            ? (welcomeRoot.pluginApi?.tr("welcome.system_active") || "The system is operational. Visual effects are safely managed by NVL.")
            : (welcomeRoot.pluginApi?.tr("welcome.system_inactive") || "System halted. Requires acceptance of the persistence contract to continue.")

            extraContent: ColumnLayout {
                spacing: Style.marginM
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: Style.marginL
                    NText {
                        text: welcomeRoot.pluginApi?.tr("welcome.enable_label") || "Enable Visual Layer"
                        font.weight: Font.Bold
                        pointSize: Style.fontSizeL
                        color: Color.mOnSurface
                    }
                    Item { Layout.fillWidth: true }
                    VisualSwitch {
                        checked: welcomeSettings.isSystemActive
                        onToggled: {
                            welcomeSettings.isSystemActive = checked
                            if (welcomeRoot.runScript) {
                                welcomeRoot.runScript("init.sh", checked ? "enable" : "disable")
                            }
                        }
                    }
                }

                Rectangle {
                    visible: !welcomeSettings.isSystemActive
                    Layout.fillWidth: true
                    implicitHeight: warnCol.implicitHeight + 24
                    color: Qt.alpha("#ef4444", 0.08)
                    radius: Style.radiusM
                    border.color: Qt.alpha("#ef4444", 0.3)
                    border.width: 1
                    RowLayout {
                        id: warnCol
                        anchors.fill: parent; anchors.margins: Style.marginL; spacing: Style.marginL
                        NIcon { icon: "alert-circle"; color: "#ef4444"; pointSize: 20; Layout.alignment: Qt.AlignTop }
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: Style.marginXS
                            NText {
                                text: welcomeRoot.pluginApi?.tr("welcome.warning.title") || "SECURE PERSISTENCE CONTRACT"
                                font.weight: Font.Bold; color: "#ef4444"; pointSize: Style.fontSizeS
                            }
                            NText {
                                text: welcomeRoot.pluginApi?.tr("welcome.warning.text") || "Upon activation, NVL will deploy a <b>guardian shield</b> and inject a secure path into your <code>hyprland.conf</code>. If you uninstall the plugin from the Shell, the system will self-clean on the next reboot without causing Hyprland errors."
                                color: Color.mOnSurfaceVariant; wrapMode: Text.WordWrap; textFormat: Text.RichText; Layout.fillWidth: true; pointSize: Style.fontSizeS
                            }
                        }
                    }
                }
            }
        }

        // --- FEATURES ---
        ProCard {
            title: welcomeRoot.pluginApi?.tr("welcome.features.title") || "Features & Benefits"
            iconName: "star"; accentColor: "#fbbf24"
            description: welcomeRoot.pluginApi?.tr("welcome.features.description") || "Noctalia Visual Layer is the aesthetic evolution of your desktop."
            extraContent: ColumnLayout {
                spacing: Style.marginS
                Repeater {
                    model: [
                        welcomeRoot.pluginApi?.tr("welcome.features.list.fluid_anim") || "✨ <b>Fluid Animations</b>",
                        welcomeRoot.pluginApi?.tr("welcome.features.list.smart_borders") || "🎨 <b>Smart Borders</b>",
                        welcomeRoot.pluginApi?.tr("welcome.features.list.realtime_shaders") || "🕶️ <b>Real-Time Shaders</b>",
                        welcomeRoot.pluginApi?.tr("welcome.features.list.non_destructive") || "🛡️ <b>Non-Destructive</b>"
                    ]
                    delegate: RowLayout {
                        spacing: Style.marginM
                        NIcon { icon: "check"; color: Color.mPrimary; pointSize: 12 }
                        NText { text: modelData; color: Color.mOnSurfaceVariant; pointSize: 10; textFormat: Text.RichText }
                    }
                }
            }
        }

        // --- TECHNICAL DOCUMENTATION ---
        ProCard {
            title: welcomeRoot.pluginApi?.tr("welcome.docs.title") || "Architecture & Documentation"
            iconName: "book"; accentColor: "#38bdf8"
            description: welcomeRoot.pluginApi?.tr("welcome.docs.description") || "Discover how NVL works under the hood."

            extraContent: ColumnLayout {
                spacing: Style.marginL

                // Technical summary
                NText {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    color: "#a9b1d6"
                    font.pointSize: 10
                    textFormat: Text.RichText
                    text: welcomeRoot.pluginApi?.tr("welcome.docs.summary") || "<b>Noctalia Visual Layer</b> uses a real-time <i>Fragments and Assembly</i> system. It never touches your main configuration. Everything is safely generated in an isolated <code>overlay.conf</code> master file."
                }

                // Action buttons row
                RowLayout {
                    spacing: Style.marginM
                    Layout.fillWidth: true

                    NButton {
                        text: welcomeRoot.pluginApi?.tr("welcome.docs.btn_readme") || "Read Full Manual"
                        icon: "external-link"
                        Layout.fillWidth: true
                        onClicked: {
                            // Open README with the system default application
                            Qt.openUrlExternally("file://" + welcomeRoot.pluginDir + "/LEEME.md")
                        }
                    }

                    NButton {
                        text: welcomeRoot.pluginApi?.tr("welcome.docs.btn_folder") || "Browse Files"
                        icon: "folder"
                        Layout.fillWidth: true
                        onClicked: {
                            // Open file manager at the plugin folder
                            Qt.openUrlExternally("file://" + welcomeRoot.pluginDir + "/")
                        }
                    }
                }
            }
        }

        // --- CREDITS ---
        ProCard {
            title: welcomeRoot.pluginApi?.tr("welcome.credits.title") || "Credits"
            iconName: "heart"; accentColor: "#f472b6"
            description: welcomeRoot.pluginApi?.tr("welcome.credits.description") || "Special thanks to the <b>HyDE Project</b>."

            extraContent: ColumnLayout {
                spacing: Style.marginM
                NButton {
                    text: welcomeRoot.pluginApi?.tr("welcome.credits.btn_hyde") || "Inspired by HyDE Project"
                    icon: "brand-github"; Layout.fillWidth: true
                    onClicked: Qt.openUrlExternally("https://github.com/HyDE-Project/")
                }
                NDivider { Layout.fillWidth: true }
                RowLayout {
                    spacing: Style.marginM
                    NIcon { icon: "code"; color: Color.mOnSurfaceVariant; pointSize: Style.fontSizeL }
                    ColumnLayout {
                        spacing: Style.marginXXS
                        NText { text: welcomeRoot.pluginApi?.tr("welcome.credits.ai_title") || "AI Co-Programmed"; font.weight: Font.Bold }
                        NText {
                            text: welcomeRoot.pluginApi?.tr("welcome.credits.ai_desc") || "QML Architecture assistance by Gemini (Google)."
                            color: Color.mOnSurfaceVariant; wrapMode: Text.Wrap; Layout.fillWidth: true; pointSize: Style.fontSizeS
                        }
                    }
                }
            }
        }
        Item { Layout.preferredHeight: 50 }
    }

    // --- HELPER COMPONENTS ---
    component ProCard : NBox {
        id: cardRoot
        property string title; property string iconName; property string description
        property color accentColor; property Component extraContent: null
        Layout.fillWidth: true; Layout.leftMargin: Style.marginL; Layout.rightMargin: Style.marginL
        implicitHeight: cardCol.implicitHeight + (Style.marginL * 2)
        radius: Style.radiusM
        border.color: Qt.alpha(accentColor, 0.3); border.width: 1
        color: Qt.alpha(accentColor, 0.03)

        ColumnLayout {
            id: cardCol; anchors.fill: parent; anchors.margins: Style.marginL; spacing: Style.marginM
            RowLayout {
                spacing: Style.marginM
                NIcon { icon: iconName; color: accentColor; pointSize: Style.fontSizeL }
                NText { text: cardRoot.title; font.weight: Font.Bold; pointSize: Style.fontSizeL }
            }
            NDivider { Layout.fillWidth: true; opacity: 0.2 }
            NText { text: cardRoot.description; color: Color.mOnSurface; wrapMode: Text.WordWrap; Layout.fillWidth: true; textFormat: Text.RichText }
            Loader { active: extraContent !== null; sourceComponent: extraContent; Layout.fillWidth: true }
        }
    }

    component VisualSwitch : Item {
        id: sw; property bool checked: false; signal toggled()
        width: 46 * Style.uiScaleRatio; height: 24 * Style.uiScaleRatio
        Rectangle {
            anchors.fill: parent; radius: height / 2
            color: sw.checked ? Color.mPrimary : Color.mSurface
            border.color: sw.checked ? Color.mPrimary : Color.mOutline; border.width: 1
            Rectangle {
                width: parent.height - 8; height: width; radius: width / 2
                color: sw.checked ? Color.mOnPrimary : Color.mOnSurfaceVariant
                anchors.verticalCenter: parent.verticalCenter
                x: sw.checked ? (parent.width - width - 4) : 4
                Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
            }
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { sw.checked = !sw.checked; sw.toggled() } }
    }
}
