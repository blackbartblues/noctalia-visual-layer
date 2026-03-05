import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.settings 1.0 as LabSettings
import Quickshell
import Quickshell.Io
import qs.Widgets
import qs.Commons

NScrollView {
    id: shaderRoot

    property var pluginApi: null
    property var runScript: null
    property string pluginDir: ""

    Layout.fillWidth: true
    Layout.fillHeight: true
    contentHeight: mainLayout.implicitHeight + 50
    clip: true

    // --- PERSISTENCE ---
    LabSettings.Settings {
        id: shaderSettings
        fileName: shaderRoot.pluginDir + "/assets/shaders/store.conf"
        property string activeShaderFile: ""
    }

    // --- SCANNER ---
    Process {
        id: scanner
        command: ["bash", shaderRoot.pluginDir + "/assets/scripts/scan.sh", "shaders"]
        property string outputData: ""
        stdout: SplitParser { onRead: function(data) { scanner.outputData += data; } }
        onExited: (code) => {
            if (code === 0) {
                try {
                    var data = JSON.parse(scanner.outputData);
                    shaderModel.clear();
                    for (var i = 0; i < data.length; i++) { shaderModel.append(data[i]); }
                } catch (e) { Logger.e("NVL", "JSON parse error: " + e); }
            }
        }
    }
    onPluginDirChanged: if (pluginDir !== "") { scanner.outputData = ""; scanner.running = true }
    Component.onCompleted: if (pluginDir !== "") scanner.running = true
    Component.onDestruction: {
        if (scanner.running) scanner.terminate()
    }

    // --- DELEGATE ---
    Component {
        id: shaderDelegate
        NBox {
            id: cardRoot
            Layout.fillWidth: true
            Layout.preferredHeight: 85 * Style.uiScaleRatio
            radius: Style.radiusM

            // Property mapping (Raw + Key)
            property string cTitleKey: model.title || ""
            property string cDescKey: model.desc || ""
            property string cRawTitle: model.rawTitle || ""
            property string cRawDesc: model.rawDesc || ""

            property string cFile: model.file || ""
            property string cTag: model.tag || "USER"
            property color cColor: model.color || "#888888"
            property string cIcon: model.icon || "help"

            property bool isActive: shaderSettings.activeShaderFile === cFile

            color: isActive ? Qt.alpha(cColor, 0.12) : (hoverArea.containsMouse ? Qt.alpha(cColor, 0.05) : "transparent")
            border.width: isActive ? 2 : 1
            border.color: isActive ? cColor : (hoverArea.containsMouse ? Qt.alpha(cColor, 0.4) : Color.mOutline)

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            MouseArea {
                id: hoverArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // 1. Capture current state
                    var wasActive = isActive

                    // 2. Determine intent
                    var scriptArg = wasActive ? "none" : cardRoot.cFile
                    var settingArg = wasActive ? "" : cardRoot.cFile

                    // 3. Run script first
                    if (shaderRoot.runScript) shaderRoot.runScript("shader.sh", scriptArg)

                    // 4. Update UI last
                    shaderSettings.activeShaderFile = settingArg
                }
            }

            RowLayout {
                anchors.fill: parent; anchors.margins: Style.marginM; spacing: Style.marginM
                NIcon {
                    icon: cardRoot.cIcon
                    color: (cardRoot.isActive || hoverArea.containsMouse) ? cardRoot.cColor : Color.mOnSurfaceVariant
                    pointSize: Style.fontSizeL
                }
                ColumnLayout {
                    Layout.fillWidth: true; spacing: Style.marginXXS
                    RowLayout {
                        spacing: Style.marginM
                        NText {
                            text: (cardRoot.cTitleKey ? shaderRoot.pluginApi?.tr(cardRoot.cTitleKey) : null) || cardRoot.cRawTitle
                            font.weight: Font.Bold
                            color: cardRoot.isActive ? Color.mOnSurface : Color.mOnSurfaceVariant
                        }
                        Rectangle {
                            width: tagT.implicitWidth + 10; height: 16; radius: 4; color: Qt.alpha(cardRoot.cColor, 0.15)
                            NText { id: tagT; text: cardRoot.cTag; pointSize: 7; color: cardRoot.cColor; anchors.centerIn: parent; font.weight: Font.Bold }
                        }
                    }
                    NText {
                        text: (cardRoot.cDescKey ? shaderRoot.pluginApi?.tr(cardRoot.cDescKey) : null) || cardRoot.cRawDesc
                        pointSize: Style.fontSizeS; color: Color.mOnSurfaceVariant; elide: Text.ElideRight; Layout.fillWidth: true
                    }
                }
                VisualSwitch {
                    checked: cardRoot.isActive
                    onToggled: hoverArea.clicked(null)
                }
            }
        }
    }

    ListModel { id: shaderModel }

    ColumnLayout {
        id: mainLayout
        width: shaderRoot.availableWidth
        spacing: Style.marginS
        Layout.margins: Style.marginM

        ColumnLayout {
            Layout.fillWidth: true; spacing: Style.marginXS; Layout.margins: Style.marginL
            NText {
                text: shaderRoot.pluginApi?.tr("shaders.header_title") || "Screen Filters"
                font.weight: Font.Bold; pointSize: Style.fontSizeL; color: Color.mPrimary
            }
            NText {
                text: shaderRoot.pluginApi?.tr("shaders.header_subtitle") || "Real-time image post-processing"
                pointSize: Style.fontSizeS; color: Color.mOnSurfaceVariant
            }
        }

        NDivider { Layout.fillWidth: true; opacity: 0.5 }

        Repeater {
            model: shaderModel
            delegate: shaderDelegate
        }
    }

    component VisualSwitch : Item {
        id: sw; property bool checked: false; signal toggled()
        width: 40 * Style.uiScaleRatio; height: 20 * Style.uiScaleRatio
        Rectangle {
            anchors.fill: parent; radius: height / 2
            color: sw.checked ? Color.mPrimary : "transparent"
            border.color: sw.checked ? Color.mPrimary : Color.mOutline; border.width: 1
            Rectangle {
                width: parent.height - 6; height: width; radius: width / 2
                color: sw.checked ? Color.mOnPrimary : Color.mOnSurfaceVariant
                anchors.verticalCenter: parent.verticalCenter
                x: sw.checked ? (parent.width - width - 3) : 3
                Behavior on x { NumberAnimation { duration: 200 } }
            }
        }
    }
}
