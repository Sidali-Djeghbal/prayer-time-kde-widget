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
    property alias cfg_latitude: latField.text
    property alias cfg_longitude: lonField.text
    property alias cfg_calculationMethod: methodCombo.currentIndex
    property alias cfg_notificationMinutes: notificationSpinBox.value
    
    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: apiServiceCombo
            Kirigami.FormData.label: "API Service:"
            model: [
                { text: "Al-Adhan", value: "aladhan" },
                { text: "Salah Hour", value: "salahhour" }
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: cfg_apiService === "aladhan" ? 0 : 1
        }
        
        QQC2.TextField {
            id: cityField
            Kirigami.FormData.label: "City:"
            placeholderText: "e.g., London"
        }
        
        QQC2.TextField {
            id: countryField
            Kirigami.FormData.label: "Country:"
            placeholderText: "e.g., UK"
        }
        
        QQC2.TextField {
            id: latField
            Kirigami.FormData.label: "Latitude:"
            placeholderText: "e.g., 51.5074"
        }
        
        QQC2.TextField {
            id: lonField
            Kirigami.FormData.label: "Longitude:"
            placeholderText: "e.g., -0.1278"
        }
        
        QQC2.ComboBox {
            id: methodCombo
            Kirigami.FormData.label: "Calculation Method:"
            model: [
                "Jafari",
                "University of Islamic Sciences, Karachi",
                "Islamic Society of North America",
                "Muslim World League",
                "Umm Al-Qura University, Makkah",
                "Egyptian General Authority of Survey",
                "Institute of Geophysics, University of Tehran",
                "Gulf Region",
                "Kuwait",
                "Qatar",
                "Majlis Ugama Islam Singapura, Singapore",
                "Union Organization Islamic de France",
                "Diyanet İşleri Başkanlığı, Turkey"
            ]
        }
        
        QQC2.SpinBox {
            id: notificationSpinBox
            Kirigami.FormData.label: "Notification (minutes before):"
            from: 1
            to: 60
            value: 15
        }
    }
}