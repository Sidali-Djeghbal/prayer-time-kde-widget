import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: fullRep
    Layout.minimumWidth: Kirigami.Units.gridUnit * 18
    Layout.minimumHeight: Kirigami.Units.gridUnit * 22
    spacing: Kirigami.Units.smallSpacing
    
    RowLayout {
        Layout.fillWidth: true
        Layout.margins: Kirigami.Units.smallSpacing
        
        PlasmaExtras.Heading {
            level: 3
            text: root.useArabic ? "مواقيت الصلاة" : "Prayer Times"
            font.family: root.useArabic ? "Noto Sans Arabic" : Kirigami.Theme.defaultFont.family
            Layout.fillWidth: true
        }
        
        PlasmaComponents3.ToolButton {
            icon.name: "preferences-desktop-locale"
            text: root.useArabic ? "EN" : "عربي"
            display: PlasmaComponents3.AbstractButton.TextBesideIcon
            onClicked: {
                root.useArabic = !root.useArabic
                Plasmoid.configuration.useArabic = root.useArabic
            }
            PlasmaComponents3.ToolTip {
                text: root.useArabic ? "Switch to English" : "التبديل إلى العربية"
            }
        }
    }
    
    Kirigami.Separator {
        Layout.fillWidth: true
    }
    
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.smallSpacing
        Layout.rightMargin: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing
        
        Kirigami.Icon {
            source: "find-location"
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
        }
        
        PlasmaComponents3.Label {
            text: {
                if (!root.city && root.latitude === 0) {
                    return root.useArabic ? "لم يتم تحديد الموقع" : "Location not set"
                }
                return root.city ? (root.city + ", " + root.country) : 
                      (root.latitude.toFixed(4) + ", " + root.longitude.toFixed(4))
            }
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: (!root.city && root.latitude === 0) ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.disabledTextColor
            Layout.fillWidth: true
        }
        
        PlasmaComponents3.ToolButton {
            icon.name: "find-location-symbolic"
            visible: !root.city && root.latitude === 0
            onClicked: {
                root.fetchLocation()
            }
            PlasmaComponents3.ToolTip {
                text: root.useArabic ? "اكتشاف موقعي" : "Detect My Location"
            }
        }
    }
    
    Kirigami.Separator {
        Layout.fillWidth: true
    }
    
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing
        
        Repeater {
            model: ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
            
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
                
                Rectangle {
                    width: 4
                    height: parent.height - 4
                    color: modelData === root.nextPrayer ? Kirigami.Theme.positiveTextColor : "transparent"
                    radius: 2
                }
                
                PlasmaComponents3.Label {
                    text: root.getPrayerName(modelData)
                    font.bold: modelData === root.nextPrayer
                    font.family: root.useArabic ? "Noto Sans Arabic" : Kirigami.Theme.defaultFont.family
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                }
                
                Item { Layout.fillWidth: true }
                
                PlasmaComponents3.Label {
                    text: root.prayerTimes[modelData] || "--:--"
                    font.bold: modelData === root.nextPrayer
                    font.family: "monospace"
                }
            }
        }
    }
    
    Kirigami.Separator {
        Layout.fillWidth: true
    }
    
    ColumnLayout {
        Layout.fillWidth: true
        Layout.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing
        
        PlasmaComponents3.Label {
            text: (root.useArabic ? "القادمة: " : "Next: ") + root.getPrayerName(root.nextPrayer)
            font.bold: true
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
            font.family: root.useArabic ? "Noto Sans Arabic" : Kirigami.Theme.defaultFont.family
        }
        
        PlasmaComponents3.Label {
            text: (root.useArabic ? "الوقت: " : "Time: ") + root.nextPrayerTime
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
        }
        
        PlasmaComponents3.Label {
            text: (root.useArabic ? "بعد: " : "In: ") + root.formatCountdown(root.secondsUntilNext)
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
            color: root.secondsUntilNext <= (root.notificationMinutes * 60) ? 
                   Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
        }
    }
    
    Item { Layout.fillHeight: true }
    
    RowLayout {
        Layout.fillWidth: true
        Layout.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing
        
        PlasmaComponents3.Button {
            text: root.useArabic ? "تحديث" : "Refresh"
            icon.name: "view-refresh"
            Layout.fillWidth: true
            onClicked: {
                root.fetchPrayerTimes()
            }
            PlasmaComponents3.ToolTip {
                text: root.useArabic ? "تحديث مواقيت الصلاة" : "Refresh prayer times"
            }
        }
        
        PlasmaComponents3.Button {
            text: root.useArabic ? "الإعدادات" : "Settings"
            icon.name: "configure"
            Layout.fillWidth: true
            onClicked: {
                root.expanded = false
                Plasmoid.internalAction("configure").trigger()
            }
        }
    }
}