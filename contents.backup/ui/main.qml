import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    
    preferredRepresentation: compactRepresentation
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
    
    property var prayerTimes: ({})
    property string nextPrayer: ""
    property string nextPrayerTime: ""
    property int secondsUntilNext: 0
    property bool notificationShown: false
    
    property string apiService: Plasmoid.configuration.apiService || "aladhan"
    property string city: Plasmoid.configuration.city || "London"
    property string country: Plasmoid.configuration.country || "UK"
    property double latitude: Plasmoid.configuration.latitude || 51.5074
    property double longitude: Plasmoid.configuration.longitude || -0.1278
    property int calculationMethod: Plasmoid.configuration.calculationMethod || 2
    property int notificationMinutes: Plasmoid.configuration.notificationMinutes || 15
    
    Timer {
        id: updateTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            updateCountdown()
            checkNotification()
        }
    }
    
    Timer {
        id: fetchTimer
        interval: 60000 // check every 1 minute if need to fetch new times
        running: true
        repeat: true
        onTriggered: fetchPrayerTimes()
    }
    
    Component.onCompleted: {
        fetchPrayerTimes()
    }
    
    function fetchPrayerTimes() {
        if (apiService === "aladhan") {
            fetchFromAladhan()
        } else {
            fetchFromSalahHour()
        }
    }
    
    function fetchFromAladhan() {
        var xhr = new XMLHttpRequest()
        var date = new Date()
        var dateStr = date.getDate() + "-" + (date.getMonth() + 1) + "-" + date.getFullYear()
        
        var url = "http://api.aladhan.com/v1/timingsByCity?city=" + city + 
                  "&country=" + country + "&method=" + calculationMethod
        
        xhr.open("GET", url)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText)
                    if (response.data && response.data.timings) {
                        parsePrayerTimes(response.data.timings)
                    }
                }
            }
        }
        xhr.send()
    }
    
    function fetchFromSalahHour() {
        var xhr = new XMLHttpRequest()
        var date = new Date()
        var dateStr = date.getFullYear() + "-" + 
                      String(date.getMonth() + 1).padStart(2, '0') + "-" + 
                      String(date.getDate()).padStart(2, '0')
        
        var url = "https://api.salahhour.com/v1/prayer-times?lat=" + latitude + 
                  "&lng=" + longitude + "&date=" + dateStr + "&method=" + calculationMethod
        
        xhr.open("GET", url)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText)
                    if (response.timings) {
                        parsePrayerTimes(response.timings)
                    }
                }
            }
        }
        xhr.send()
    }
    
    function parsePrayerTimes(timings) {
        prayerTimes = {
            "Fajr": timings.Fajr,
            "Dhuhr": timings.Dhuhr,
            "Asr": timings.Asr,
            "Maghrib": timings.Maghrib,
            "Isha": timings.Isha
        }
        
        findNextPrayer()
    }
    
    function findNextPrayer() {
        var now = new Date()
        var currentMinutes = now.getHours() * 60 + now.getMinutes()
        
        var prayers = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
        
        for (var i = 0; i < prayers.length; i++) {
            var prayer = prayers[i]
            var time = prayerTimes[prayer]
            if (!time) continue
            
            var parts = time.split(":")
            var prayerMinutes = parseInt(parts[0]) * 60 + parseInt(parts[1])
            
            if (prayerMinutes > currentMinutes) {
                nextPrayer = prayer
                nextPrayerTime = time
                updateCountdown()
                return
            }
        }
        
        // if no prayers left today, fetch tomorrow times
        nextPrayer = "Fajr (Tomorrow)"
        nextPrayerTime = prayerTimes.Fajr || "00:00"
        
        var tomorrow = new Date()
        tomorrow.setDate(tomorrow.getDate() + 1)
        fetchPrayerTimes()
    }
    
    function updateCountdown() {
        if (!nextPrayerTime) return
        
        var now = new Date()
        var parts = nextPrayerTime.split(":")
        var prayerTime = new Date()
        prayerTime.setHours(parseInt(parts[0]))
        prayerTime.setMinutes(parseInt(parts[1]))
        prayerTime.setSeconds(0)
        
        if (nextPrayer.includes("Tomorrow")) {
            prayerTime.setDate(prayerTime.getDate() + 1)
        }
        
        var diff = Math.floor((prayerTime - now) / 1000)
        
        if (diff <= 0) {
            findNextPrayer()
            notificationShown = false
        } else {
            secondsUntilNext = diff
        }
    }
    
    function checkNotification() {
        var minutesUntil = Math.floor(secondsUntilNext / 60)
        
        if (minutesUntil <= notificationMinutes && minutesUntil > 0 && !notificationShown) {
            notificationShown = true
            // in a reel implementation, trigger kde notifcation
            console.log("Prayer time approaching: " + nextPrayer + " in " + minutesUntil + " minutes")
        }
    }
    
    function formatCountdown(seconds) {
        var hours = Math.floor(seconds / 3600)
        var minutes = Math.floor((seconds % 3600) / 60)
        var secs = seconds % 60
        
        if (hours > 0) {
            return hours + "h " + minutes + "m"
        } else {
            return minutes + "m " + secs + "s"
        }
    }
}