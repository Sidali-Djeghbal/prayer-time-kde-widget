import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

ColumnLayout {
    Layout.minimumWidth: Kirigami.Units.gridUnit * 15
    Layout.minimumHeight: Kirigami.Units.gridUnit * 18
    spacing: Kirigami.Units.smallSpacing
    
    PlasmaExtras.Heading {
        level: 3
        text: "Prayer Times"
        Layout.alignment: Qt.AlignHCenter
    }
    
    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Kirigami.Theme.textColor
        opacity: 0.3
    }
    
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing
        
        Repeater {
            model: ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
            
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                
                Rectangle {
                    width: 4
                    height: parent.height
                    color: modelData === root.nextPrayer ? Kirigami.Theme.positiveTextColor : "transparent"
                }
                
                PlasmaComponents3.Label {
                    text: modelData
                    font.bold: modelData === root.nextPrayer
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                }
                
                PlasmaComponents3.Label {
                    text: root.prayerTimes[modelData] || "--:--"
                    font.bold: modelData === root.nextPrayer
                    Layout.alignment: Qt.AlignRight
                }
                
                Item { Layout.fillWidth: true }
            }
        }
    }
    
    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Kirigami.Theme.textColor
        opacity: 0.3
    }
    
    ColumnLayout {
        Layout.fillWidth: true
        Layout.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing
        
        PlasmaComponents3.Label {
            text: "Next: " + root.nextPrayer
            font.bold: true
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.2
        }
        
        PlasmaComponents3.Label {
            text: "Time: " + root.nextPrayerTime
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
        }
        
        PlasmaComponents3.Label {
            text: "In: " + root.formatCountdown(root.secondsUntilNext)
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
            color: root.secondsUntilNext <= (root.notificationMinutes * 60) ? "#ff6b6b" : Kirigami.Theme.textColor
        }
    }
    
    Item { Layout.fillHeight: true }
    
    PlasmaComponents3.Button {
        text: "Configure"
        Layout.alignment: Qt.AlignHCenter
        onClicked: root.action("configure").trigger()
    }
}
