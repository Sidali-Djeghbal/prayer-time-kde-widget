import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: generalPage
    
    property alias cfg_apiService: apiServiceCombo.currentValue
    property alias cfg_city: cityField.text
    property alias cfg_country: countryField.text
    property alias cfg_latitude: latField.value
    property alias cfg_longitude: lonField.value
    property alias cfg_calculationMethod: methodCombo.currentIndex
    property alias cfg_notificationMinutes: notificationSpinBox.value
    property alias cfg_useArabic: arabicCheckBox.checked
    
    Kirigami.FormLayout {
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Display"
        }
        
        QQC2.CheckBox {
            id: arabicCheckBox
            Kirigami.FormData.label: "Language:"
            text: "Use Arabic (استخدم العربية)"
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Display prayer names and interface in Arabic"
        }
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Location"
        }
        
        RowLayout {
            Kirigami.FormData.label: "Quick Setup:"
            spacing: Kirigami.Units.smallSpacing
            
            QQC2.Button {
                text: "Detect My Location"
                icon.name: "find-location"
                highlighted: true
                onClicked: {
                    detectLocation()
                }
            }
            
            QQC2.Label {
                id: locationStatus
                text: ""
                Layout.fillWidth: true
            }
        }
        
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Manual Location Entry"
        }
        
        QQC2.TextField {
            id: cityField
            Kirigami.FormData.label: "City:"
            placeholderText: "e.g., London, Makkah, Cairo"
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Your city name (optional if using coordinates)"
        }
        
        QQC2.TextField {
            id: countryField
            Kirigami.FormData.label: "Country:"
            placeholderText: "e.g., UK, Saudi Arabia"
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Your country name (optional if using coordinates)"
        }
        
        RowLayout {
            Kirigami.FormData.label: "Coordinates:"
            spacing: Kirigami.Units.smallSpacing
            
            QQC2.Label {
                text: "Latitude:"
            }
            
            QQC2.SpinBox {
                id: latField
                from: -9000
                to: 9000
                stepSize: 1
                editable: true
                Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                
                property int decimals: 4
                property real realValue: value / 10000
                
                validator: DoubleValidator {
                    bottom: Math.min(latField.from, latField.to)
                    top:  Math.max(latField.from, latField.to)
                }
                
                textFromValue: function(value, locale) {
                    return Number(value / 10000).toLocaleString(locale, 'f', latField.decimals)
                }
                
                valueFromText: function(text, locale) {
                    return Number.fromLocaleString(locale, text) * 10000
                }
                
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: "Your latitude (-90 to 90)"
            }
            
            QQC2.Label {
                text: "Longitude:"
                Layout.leftMargin: Kirigami.Units.largeSpacing
            }
            
            QQC2.SpinBox {
                id: lonField
                from: -18000
                to: 18000
                stepSize: 1
                editable: true
                Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                
                property int decimals: 4
                property real realValue: value / 10000
                
                validator: DoubleValidator {
                    bottom: Math.min(lonField.from, lonField.to)
                    top:  Math.max(lonField.from, lonField.to)
                }
                
                textFromValue: function(value, locale) {
                    return Number(value / 10000).toLocaleString(locale, 'f', lonField.decimals)
                }
                
                valueFromText: function(text, locale) {
                    return Number.fromLocaleString(locale, text) * 10000
                }
                
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: "Your longitude (-180 to 180)"
            }
        }
        
        QQC2.Label {
            text: "Tip: Use the 'Detect My Location' button above for automatic setup"
            font.italic: true
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            opacity: 0.7
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Prayer Times Settings"
        }
        
        QQC2.ComboBox {
            id: apiServiceCombo
            Kirigami.FormData.label: "API Service:"
            model: [
                { text: "Al-Adhan (Recommended)", value: "aladhan" },
                { text: "Salah Hour", value: "salahhour" }
            ]
            textRole: "text"
            valueRole: "value"
            Component.onCompleted: {
                currentIndex = cfg_apiService === "aladhan" ? 0 : 1
            }
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Al-Adhan is recommended for better reliability"
        }
        
        QQC2.ComboBox {
            id: methodCombo
            Kirigami.FormData.label: "Calculation Method:"
            model: [
                "Shia Ithna-Ansari",
                "University of Islamic Sciences, Karachi",
                "Islamic Society of North America (ISNA)",
                "Muslim World League (MWL)",
                "Umm Al-Qura University, Makkah",
                "Egyptian General Authority of Survey",
                "Institute of Geophysics, University of Tehran",
                "Gulf Region",
                "Kuwait",
                "Qatar",
                "Majlis Ugama Islam Singapura",
                "Union Organization Islamic de France",
                "Diyanet İşleri Başkanlığı, Turkey",
                "Spiritual Administration of Muslims of Russia"
            ]
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Choose the calculation method used in your region"
        }
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Notifications"
        }
        
        QQC2.SpinBox {
            id: notificationSpinBox
            Kirigami.FormData.label: "Alert before prayer:"
            from: 1
            to: 60
            value: 15
            editable: true
            
            textFromValue: function(value) {
                return value + (value === 1 ? " minute" : " minutes")
            }
            
            valueFromText: function(text) {
                return parseInt(text)
            }
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Visual alert will show this many minutes before prayer time"
        }
    }
    
    function detectLocation() {
        locationStatus.text = " Detecting location..."
        locationStatus.color = Kirigami.Theme.neutralTextColor
        
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://ipapi.co/json/")
        xhr.timeout = 10000
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.latitude && response.longitude) {
                            latField.value = Math.round(response.latitude * 10000)
                            lonField.value = Math.round(response.longitude * 10000)
                            cityField.text = response.city || ""
                            countryField.text = response.country_name || ""
                            locationStatus.text = "✓ Location detected: " + response.city + ", " + response.country_name
                            locationStatus.color = Kirigami.Theme.positiveTextColor
                        } else {
                            locationStatus.text = "✗ Invalid response from location service"
                            locationStatus.color = Kirigami.Theme.negativeTextColor
                        }
                    } catch (e) {
                        locationStatus.text = "✗ Error parsing location data"
                        locationStatus.color = Kirigami.Theme.negativeTextColor
                    }
                } else {
                    locationStatus.text = "✗ Failed to detect location (Error: " + xhr.status + ")"
                    locationStatus.color = Kirigami.Theme.negativeTextColor
                }
            }
        }
        
        xhr.ontimeout = function() {
            locationStatus.text = "✗ Location detection timed out"
            locationStatus.color = Kirigami.Theme.negativeTextColor
        }
        
        xhr.onerror = function() {
            locationStatus.text = "✗ Network error - check your internet connection"
            locationStatus.color = Kirigami.Theme.negativeTextColor
        }
        
        xhr.send()
    }
}