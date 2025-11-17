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
        
        QQC2.CheckBox {
            id: arabicCheckBox
            Kirigami.FormData.label: "Language:"
            text: "Use Arabic (استخدم العربية)"
        }
        
        Item {
            Kirigami.FormData.isSection: true
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
        }
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Location"
        }
        
        RowLayout {
            Kirigami.FormData.label: "Auto-detect:"
            
            QQC2.Button {
                text: "Get My Location"
                icon.name: "find-location"
                onClicked: {
                    detectLocation()
                }
            }
            
            QQC2.Label {
                id: locationStatus
                text: ""
                color: Kirigami.Theme.positiveTextColor
            }
        }
        
        QQC2.TextField {
            id: cityField
            Kirigami.FormData.label: "City:"
            placeholderText: "e.g., London, Makkah, Cairo"
        }
        
        QQC2.TextField {
            id: countryField
            Kirigami.FormData.label: "Country:"
            placeholderText: "e.g., UK, Saudi Arabia"
        }
        
        QQC2.SpinBox {
            id: latField
            Kirigami.FormData.label: "Latitude:"
            from: -9000
            to: 9000
            stepSize: 1
            
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
        }
        
        QQC2.SpinBox {
            id: lonField
            Kirigami.FormData.label: "Longitude:"
            from: -18000
            to: 18000
            stepSize: 1
            
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
        }
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Prayer Calculation"
        }
        
        QQC2.ComboBox {
            id: methodCombo
            Kirigami.FormData.label: "Calculation Method:"
            model: [
                "Shia Ithna-Ansari",
                "University of Islamic Sciences, Karachi",
                "Islamic Society of North America (ISNA)",
                "Muslim World League",
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
        }
        
        QQC2.SpinBox {
            id: notificationSpinBox
            Kirigami.FormData.label: "Warning (minutes before):"
            from: 1
            to: 60
            value: 15
        }
    }
    
    function detectLocation() {
        locationStatus.text = "Detecting..."
        locationStatus.color = Kirigami.Theme.neutralTextColor
        
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://ipapi.co/json/")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText)
                    if (response.latitude && response.longitude) {
                        latField.value = response.latitude * 10000
                        lonField.value = response.longitude * 10000
                        cityField.text = response.city || ""
                        countryField.text = response.country_name || ""
                        locationStatus.text = "✓ Location detected"
                        locationStatus.color = Kirigami.Theme.positiveTextColor
                    }
                } else {
                    locationStatus.text = "✗ Failed to detect"
                    locationStatus.color = Kirigami.Theme.negativeTextColor
                }
            }
        }
        xhr.send()
    }
}