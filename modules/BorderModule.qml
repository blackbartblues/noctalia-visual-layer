import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.settings 1.0 as LabSettings
import Quickshell
import Quickshell.Io
import qs.Widgets
import qs.Commons

NScrollView {
    id: borderRoot

    property var pluginApi: null
    property var runScript: null
    property string pluginDir: ""

    Layout.fillWidth: true
    Layout.fillHeight: true
    contentHeight: mainLayout.implicitHeight + 50
    clip: true

    // --- PERSISTENCE ---
    LabSettings.Settings {
        id: borderSettings
        fileName: borderRoot.pluginDir + "/assets/borders/store.conf"
        property string activeBorderFile: ""
    }
    LabSettings.Settings {
        id: geomSettings
        category: "VisualLayer_Geometry"
        fileName: borderRoot.pluginDir + "/assets/borders/store.conf"
        property int borderSize: 2
    }

    // --- SCANNER ---
    Process {
        id: scanner
        command: ["bash", borderRoot.pluginDir + "/assets/scripts/scan.sh", "borders"]
        property string outputData: ""
        stdout: SplitParser { onRead: function(data) { scanner.outputData += data; } }
        onExited: (code) => {
            if (code === 0) {
                try {
                    var data = JSON.parse(scanner.outputData);
                    borderModel.clear();
                    for (var i = 0; i < data.length; i++) { borderModel.append(data[i]); }
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
        id: borderDelegate
        NBox {
            id: cardRoot
            Layout.fillWidth: true
            Layout.preferredHeight: 85 * Style.uiScaleRatio
            radius: Style.radiusM

            // Property mapping (rawTitle/rawDesc from JSON as fallback)
            property string cTitleKey: model.title || ""
            property string cDescKey: model.desc || ""
            property string cRawTitle: model.rawTitle || ""
            property string cRawDesc: model.rawDesc || ""

            property string cFile: model.file || ""
            property string cIcon: model.icon || "help"
            property color cColor: model.color || "#888888"
            property string cTag: model.tag || "USER"

            property bool isActive: borderSettings.activeBorderFile === cFile

            color: isActive ? Qt.alpha(cColor, 0.12) : (hoverArea.containsMouse ? Qt.alpha(cColor, 0.05) : "transparent")
            border.width: isActive ? 2 : 1
            border.color: isActive ? cColor : (hoverArea.containsMouse ? Qt.alpha(cColor, 0.4) : Color.mOutline)

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            MouseArea {
                id: hoverArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // 1. Capture current state (before it changes)
                    var wasActive = isActive

                    // 2. Determine intent
                    var scriptArg = wasActive ? "none" : cardRoot.cFile
                    var settingArg = wasActive ? "" : cardRoot.cFile

                    // 3. Run script first
                    if (borderRoot.runScript) borderRoot.runScript("border.sh", scriptArg)

                    // 4. Update UI last
                    borderSettings.activeBorderFile = settingArg
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
                            text: (cardRoot.cTitleKey ? borderRoot.pluginApi?.tr(cardRoot.cTitleKey) : null) || cardRoot.cRawTitle
                            font.weight: Font.Bold
                            color: cardRoot.isActive ? Color.mOnSurface : Color.mOnSurfaceVariant
                        }
                        Rectangle {
                            width: tagT.implicitWidth + 10; height: 16; radius: 4; color: Qt.alpha(cardRoot.cColor, 0.15)
                            NText { id: tagT; text: cardRoot.cTag; pointSize: 7; color: cardRoot.cColor; anchors.centerIn: parent; font.weight: Font.Bold }
                        }
                    }
                    NText {
                        text: (cardRoot.cDescKey ? borderRoot.pluginApi?.tr(cardRoot.cDescKey) : null) || cardRoot.cRawDesc
                        pointSize: Style.fontSizeS
                        color: Color.mOnSurfaceVariant
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
                // Visual toggle switch
                Item {
                    width: 40 * Style.uiScaleRatio; height: 20 * Style.uiScaleRatio
                    Rectangle {
                        anchors.fill: parent; radius: height / 2
                        color: cardRoot.isActive ? Color.mPrimary : "transparent"
                        border.color: cardRoot.isActive ? Color.mPrimary : Color.mOutline; border.width: 1
                        Rectangle {
                            width: parent.height - 6; height: width; radius: width / 2
                            color: cardRoot.isActive ? Color.mOnPrimary : Color.mOnSurfaceVariant
                            anchors.verticalCenter: parent.verticalCenter
                            x: cardRoot.isActive ? (parent.width - width - 3) : 3
                            Behavior on x { NumberAnimation { duration: 200 } }
                        }
                    }
                }
            }
        }
    }

    ListModel { id: borderModel }

    ColumnLayout {
        id: mainLayout
        width: borderRoot.availableWidth
        spacing: Style.marginS
        Layout.margins: Style.marginM

        // HEADER
        ColumnLayout {
            Layout.fillWidth: true; spacing: Style.marginXS; Layout.margins: Style.marginL
            NText {
                text: borderRoot.pluginApi?.tr("borders.header_title") || "Visual Styles"
                font.weight: Font.Bold; pointSize: Style.fontSizeL; color: Color.mPrimary
            }
            NText {
                text: borderRoot.pluginApi?.tr("borders.header_subtitle") || "Define your windows' personality"
                pointSize: Style.fontSizeS; color: Color.mOnSurfaceVariant
            }
        }

        NDivider { Layout.fillWidth: true; opacity: 0.5 }

        // BORDER THICKNESS SLIDER
        NBox {
            Layout.fillWidth: true
            implicitHeight: geoCol.implicitHeight + (Style.marginL * 2)
            color: Qt.alpha(Color.mSurface, 0.4)
            radius: Style.radiusM
            border.color: Color.mOutline; border.width: 1

            ColumnLayout {
                id: geoCol
                anchors.fill: parent; anchors.margins: Style.marginL; spacing: Style.marginM
                RowLayout {
                    spacing: Style.marginS
                    NIcon { icon: "maximize"; color: Color.mPrimary; pointSize: Style.fontSizeM }
                    NText {
                        text: borderRoot.pluginApi?.tr("borders.geometry.title") || "Border Thickness"
                        font.weight: Font.Bold; color: Color.mOnSurface
                    }
                    Item { Layout.fillWidth: true }
                    NText { text: thicknessSlider.value + "px"; color: Color.mPrimary; font.weight: Font.Bold }
                }
                NSlider {
                    id: thicknessSlider
                    Layout.fillWidth: true
                    from: 1; to: 5; stepSize: 1
                    value: geomSettings.borderSize
                    onMoved: {
                        geomSettings.borderSize = value
                        if (borderRoot.runScript) borderRoot.runScript("geometry.sh", value.toString())
                    }
                }
            }
        }

        NDivider { Layout.fillWidth: true; Layout.topMargin: Style.marginM; Layout.bottomMargin: Style.marginS; opacity: 0.3 }

        Repeater {
            model: borderModel
            delegate: borderDelegate
        }
    }
}
