import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasmoid 2.0

Item {
    id: compact
    
    Layout.minimumWidth: label.implicitWidth + 20
    Layout.minimumHeight: label.implicitHeight + 10
    
    property bool showWarning: root.secondsUntilNext <= (root.notificationMinutes * 60)
    
    MouseArea {
        anchors.fill: parent
        onClicked: plasmoid.expanded = !plasmoid.expanded
    }
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 2
        
        PlasmaComponents3.Label {
            id: label
            text: root.nextPrayer
            font.pixelSize: 11
            font.bold: compact.showWarning
            color: compact.showWarning ? "#ff6b6b" : "white"
            Layout.alignment: Qt.AlignHCenter
        }
        
        PlasmaComponents3.Label {
            text: root.formatCountdown(root.secondsUntilNext)
            font.pixelSize: 9
            color: compact.showWarning ? "#ff6b6b" : "lightgray"
            Layout.alignment: Qt.AlignHCenter
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: compact.showWarning ? "#ff6b6b" : "transparent"
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
