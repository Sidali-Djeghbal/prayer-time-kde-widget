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
    property alias cfg_latitude: latField.realValue
    property alias cfg_longitude: lonField.realValue
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
                from: -900000
                to: 900000
                stepSize: 1
                editable: true
                Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                
                property int decimals: 4
                property int scale: 10000
                property bool internalChange: false
                property real realValue: 0
                
                validator: DoubleValidator {
                    bottom: -90
                    top: 90
                    decimals: latField.decimals
                }
                
                textFromValue: function(value, locale) {
                    var shownValue = value / latField.scale
                    return Number(shownValue).toLocaleString(locale, 'f', latField.decimals)
                }
                
                valueFromText: function(text, locale) {
                    var num = Number.fromLocaleString(locale, text)
                    if (isNaN(num)) {
                        return value
                    }
                    return Math.round(num * latField.scale)
                }
                
                onValueChanged: {
                    if (internalChange)
                        return
                    internalChange = true
                    realValue = value / scale
                    internalChange = false
                }
                
                onRealValueChanged: {
                    if (internalChange)
                        return
                    internalChange = true
                    value = Math.round(realValue * scale)
                    internalChange = false
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
                from: -1800000
                to: 1800000
                stepSize: 1
                editable: true
                Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                
                property int decimals: 4
                property int scale: 10000
                property bool internalChange: false
                property real realValue: 0
                
                validator: DoubleValidator {
                    bottom: -180
                    top: 180
                    decimals: lonField.decimals
                }
                
                textFromValue: function(value, locale) {
                    var shownValue = value / lonField.scale
                    return Number(shownValue).toLocaleString(locale, 'f', lonField.decimals)
                }
                
                valueFromText: function(text, locale) {
                    var num = Number.fromLocaleString(locale, text)
                    if (isNaN(num)) {
                        return value
                    }
                    return Math.round(num * lonField.scale)
                }
                
                onValueChanged: {
                    if (internalChange)
                        return
                    internalChange = true
                    realValue = value / scale
                    internalChange = false
                }
                
                onRealValueChanged: {
                    if (internalChange)
                        return
                    internalChange = true
                    value = Math.round(realValue * scale)
                    internalChange = false
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
        
        // try ipapi.co first
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://ipapi.co/json/")
        xhr.timeout = 10000
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.latitude !== undefined && response.longitude !== undefined) {
                            var lat = Number(response.latitude)
                            var lon = Number(response.longitude)
                            if (!isNaN(lat) && !isNaN(lon)) {
                                latField.realValue = Number(lat.toFixed(4))
                                lonField.realValue = Number(lon.toFixed(4))
                            }
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
                        console.log("Parse error: " + e)
                    }
                } else if (xhr.status === 403 || xhr.status === 429) {
                    // Rate limited, try alternative
                    locationStatus.text = " Trying alternative service..."
                    tryAlternativeLocation()
                } else {
                    locationStatus.text = "✗ Failed to detect location (Error: " + xhr.status + ")"
                    locationStatus.color = Kirigami.Theme.negativeTextColor
                    // Try alternative on any error
                    tryAlternativeLocation()
                }
            }
        }
        
        xhr.ontimeout = function() {
            locationStatus.text = " Request timed out, trying alternative..."
            tryAlternativeLocation()
        }
        
        xhr.onerror = function() {
            locationStatus.text = " Network error, trying alternative service..."
            tryAlternativeLocation()
        }
        
        xhr.send()
    }
    
    function tryAlternativeLocation() {
        var xhr2 = new XMLHttpRequest()
        xhr2.open("GET", "https://ipwhois.app/json/")
        xhr2.timeout = 10000
        
        xhr2.onreadystatechange = function() {
            if (xhr2.readyState === XMLHttpRequest.DONE) {
                if (xhr2.status === 200) {
                    try {
                        var response = JSON.parse(xhr2.responseText)
                        if (response.latitude !== undefined && response.longitude !== undefined) {
                            var lat2 = Number.parseFloat(response.latitude)
                            var lon2 = Number.parseFloat(response.longitude)
                            if (!isNaN(lat2) && !isNaN(lon2)) {
                                latField.realValue = Number(lat2.toFixed(4))
                                lonField.realValue = Number(lon2.toFixed(4))
                            }
                            cityField.text = response.city || ""
                            countryField.text = response.country || ""
                            locationStatus.text = "✓ Location detected: " + response.city + ", " + response.country
                            locationStatus.color = Kirigami.Theme.positiveTextColor
                        } else {
                            locationStatus.text = "✗ Could not detect location automatically. Please enter manually."
                            locationStatus.color = Kirigami.Theme.negativeTextColor
                        }
                    } catch (e) {
                        locationStatus.text = "✗ All location services failed. Please enter location manually."
                        locationStatus.color = Kirigami.Theme.negativeTextColor
                        console.log("Alternative parse error: " + e)
                    }
                } else {
                    locationStatus.text = "✗ Location detection failed. Please enter your location manually."
                    locationStatus.color = Kirigami.Theme.negativeTextColor
                }
            }
        }
        
        xhr2.ontimeout = function() {
            locationStatus.text = "✗ All services timed out. Please enter location manually."
            locationStatus.color = Kirigami.Theme.negativeTextColor
        }
        
        xhr2.onerror = function() {
            locationStatus.text = "✗ Check your internet connection or enter location manually."
            locationStatus.color = Kirigami.Theme.negativeTextColor
        }
        
        xhr2.send()
    }
}