import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: compact
    
    Layout.minimumWidth: column.implicitWidth + Kirigami.Units.smallSpacing * 2
    Layout.minimumHeight: column.implicitHeight + Kirigami.Units.smallSpacing * 2
    
    property bool showWarning: root.secondsUntilNext <= (root.notificationMinutes * 60)
    
    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
    
    ColumnLayout {
        id: column
        anchors.centerIn: parent
        spacing: 2
        
        PlasmaComponents3.Label {
            id: label
            text: root.getPrayerName(root.nextPrayer)
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.9
            font.bold: compact.showWarning
            color: compact.showWarning ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
            Layout.alignment: Qt.AlignHCenter
        }
        
        PlasmaComponents3.Label {
            text: root.formatCountdown(root.secondsUntilNext)
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: compact.showWarning ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.disabledTextColor
            Layout.alignment: Qt.AlignHCenter
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: compact.showWarning ? Kirigami.Theme.negativeTextColor : "transparent"
        border.width: 2
        radius: 4
        visible: compact.showWarning
        
        SequentialAnimation on opacity {
            running: compact.showWarning
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 1000 }
            NumberAnimation { to: 1.0; duration: 1000 }
        }
    }
}
