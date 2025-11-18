import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.notification

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
    property bool locationFetched: false
    
    property string apiService: Plasmoid.configuration.apiService || "aladhan"
    property string city: Plasmoid.configuration.city || ""
    property string country: Plasmoid.configuration.country || ""
    property double latitude: Plasmoid.configuration.latitude || 0
    property double longitude: Plasmoid.configuration.longitude || 0
    property int calculationMethod: Plasmoid.configuration.calculationMethod || 3
    property int notificationMinutes: Plasmoid.configuration.notificationMinutes || 15
    property bool useArabic: Plasmoid.configuration.useArabic || false
    property string timeZoneId: getLocalTimeZone()
    readonly property var calculationMethodIds: [
        0,  // Shia Ithna-Ansari
        1,  // University of Islamic Sciences, Karachi
        2,  // Islamic Society of North America (ISNA)
        3,  // Muslim World League (MWL)
        4,  // Umm Al-Qura University, Makkah
        5,  // Egyptian General Authority of Survey
        7,  // Institute of Geophysics, University of Tehran
        8,  // Gulf Region
        9,  // Kuwait
        10, // Qatar
        11, // Majlis Ugama Islam Singapura
        12, // Union Organization Islamic de France
        13, // Diyanet İşleri Başkanlığı, Turkey
        14  // Spiritual Administration of Muslims of Russia
    ]
    
    property var arabicPrayerNames: {
        "Fajr": "الفجر",
        "Dhuhr": "الظهر",
        "Asr": "العصر",
        "Maghrib": "المغرب",
        "Isha": "العشاء"
    }
    
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
        interval: 3600000 
        running: true
        repeat: true
        onTriggered: checkAndFetchPrayerTimes()
    }
    
    Component.onCompleted: {
        ensureValidCoordinates()
        // only fetch location if not set, otherwise just fetch prayer times
        if (latitude === 0 && longitude === 0 && !locationFetched) {
            console.log("Location not set, skipping auto-fetch")
            // Don't auto-fetch on startup to avoid 403 errors
            // User must manually click "Detect My Location"
        } else {
            fetchPrayerTimes()
        }
    }
    
    function fetchLocation() {
        console.log("Attempting to fetch location...")
        
        // try ipapi.co first
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://ipapi.co/json/")
        xhr.timeout = 5000
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.latitude && response.longitude) {
                            latitude = response.latitude
                            longitude = response.longitude
                            city = response.city || ""
                            country = response.country_name || ""
                            
                            // save to config
                            Plasmoid.configuration.latitude = latitude
                            Plasmoid.configuration.longitude = longitude
                            Plasmoid.configuration.city = city
                            Plasmoid.configuration.country = country
                            
                            locationFetched = true
                            console.log("Location detected: " + city + ", " + country)
                            fetchPrayerTimes()
                        }
                    } catch (e) {
                        console.log("Error parsing location response: " + e)
                        tryAlternativeLocationService()
                    }
                } else if (xhr.status === 403 || xhr.status === 429) {
                    console.log("Rate limited, trying alternative service")
                    tryAlternativeLocationService()
                } else {
                    console.log("Location fetch failed with status: " + xhr.status)
                    tryAlternativeLocationService()
                }
            }
        }
        
        xhr.ontimeout = function() {
            console.log("Location fetch timed out")
            tryAlternativeLocationService()
        }
        
        xhr.onerror = function() {
            console.log("Network error during location fetch")
            tryAlternativeLocationService()
        }
        
        xhr.send()
    }
    
    function tryAlternativeLocationService() {
        console.log("Trying alternative location service...")
        
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://ipwhois.app/json/")
        xhr.timeout = 5000
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.latitude && response.longitude) {
                            latitude = parseFloat(response.latitude)
                            longitude = parseFloat(response.longitude)
                            city = response.city || ""
                            country = response.country || ""
                            
                            // Save to config
                            Plasmoid.configuration.latitude = latitude
                            Plasmoid.configuration.longitude = longitude
                            Plasmoid.configuration.city = city
                            Plasmoid.configuration.country = country
                            
                            locationFetched = true
                            console.log("Location detected via alternative service: " + city + ", " + country)
                            fetchPrayerTimes()
                        }
                    } catch (e) {
                        console.log("Error parsing alternative location response: " + e)
                    }
                } else {
                    console.log("Alternative location service also failed with status: " + xhr.status)
                }
            }
        }
        
        xhr.send()
    }
    
    function checkAndFetchPrayerTimes() {
        var now = new Date()
        var lastFetchDate = new Date(Plasmoid.configuration.lastFetchDate || 0)
        
        // fetching if its a new day
        if (now.getDate() !== lastFetchDate.getDate() || 
            now.getMonth() !== lastFetchDate.getMonth() ||
            now.getFullYear() !== lastFetchDate.getFullYear()) {
            fetchPrayerTimes()
        }
    }
    
    function fetchPrayerTimes() {
        ensureValidCoordinates()
        if (latitude === 0 && longitude === 0) {
            console.log("Location not set, cannot fetch prayer times")
            return
        }
        
        console.log("Fetching prayer times for lat: " + latitude + ", lon: " + longitude)
        
        if (apiService === "aladhan") {
            fetchFromAladhan()
        } else {
            fetchFromSalahHour()
        }
        
        // save fetch date
        Plasmoid.configuration.lastFetchDate = new Date().toString()
    }

    function ensureValidCoordinates() {
        var normalizedLat = normalizeCoordinate(latitude, 90)
        var normalizedLon = normalizeCoordinate(longitude, 180)

        if (normalizedLat !== latitude) {
            latitude = normalizedLat
            Plasmoid.configuration.latitude = normalizedLat
            console.log("Normalized latitude from stored value")
        }

        if (normalizedLon !== longitude) {
            longitude = normalizedLon
            Plasmoid.configuration.longitude = normalizedLon
            console.log("Normalized longitude from stored value")
        }
    }

    function normalizeCoordinate(value, maxAbs) {
        if (!value || !isFinite(value)) {
            return 0
        }

        var absVal = Math.abs(value)
        if (absVal <= maxAbs) {
            return value
        }

        // Older versions stored coordinates scaled by 10000 via SpinBoxes.
        var scaledValue = value / 10000
        absVal = Math.abs(scaledValue)
        if (absVal <= maxAbs) {
            return scaledValue
        }

        // Clamp anything else to the valid range
        return value > 0 ? maxAbs : -maxAbs
    }

    function getLocalTimeZone() {
        var locale = Qt.locale()
        if (locale && locale.timeZoneId && locale.timeZoneId.length > 0) {
            return locale.timeZoneId
        }

        // Fallback to Qt formatted timezone text (e.g. GMT+02:00)
        var tzText = Qt.formatDateTime(new Date(), "t")
        if (tzText && tzText.length > 0) {
            return tzText
        }

        // Last resort: derive from numeric offset
        var offsetMinutes = new Date().getTimezoneOffset()
        var sign = offsetMinutes <= 0 ? "+" : "-"
        var absMinutes = Math.abs(offsetMinutes)
        var hours = Math.floor(absMinutes / 60)
        var minutes = absMinutes % 60
        return "UTC" + sign + String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0')
    }

    function getApiCalculationMethod() {
        var idx = calculationMethod
        if (idx < 0 || idx >= calculationMethodIds.length) {
            idx = 3
        }
        return calculationMethodIds[idx] || 3
    }
    
    function fetchFromAladhan() {
        var xhr = new XMLHttpRequest()
        var date = new Date()
        var timestamp = Math.floor(date.getTime() / 1000)
        
        // using coordinates for more precise times
        var url = "https://api.aladhan.com/v1/timings/" + timestamp + 
                  "?latitude=" + latitude + 
                  "&longitude=" + longitude + 
                  "&method=" + getApiCalculationMethod()

        if (timeZoneId) {
            url += "&timezonestring=" + encodeURIComponent(timeZoneId)
        }
        
        console.log("Fetching from Al-Adhan: " + url)
        
        xhr.open("GET", url)
        xhr.timeout = 10000
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        console.log("Al-Adhan response received")
                        if (response.data && response.data.timings) {
                            console.log("Prayer times found: " + JSON.stringify(response.data.timings))
                            parsePrayerTimes(response.data.timings)
                        } else {
                            console.log("Invalid response structure")
                        }
                    } catch (e) {
                        console.log("Error parsing Al-Adhan response: " + e)
                    }
                } else {
                    console.log("Failed to fetch prayer times from Al-Adhan, status: " + xhr.status)
                }
            }
        }
        
        xhr.ontimeout = function() {
            console.log("Al-Adhan request timed out")
        }
        
        xhr.onerror = function() {
            console.log("Network error fetching from Al-Adhan")
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
                  "&lng=" + longitude + 
                  "&date=" + dateStr + 
                  "&method=" + getApiCalculationMethod()

        if (timeZoneId) {
            url += "&timezone=" + encodeURIComponent(timeZoneId)
        }
        
        xhr.open("GET", url)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText)
                    if (response.timings) {
                        parsePrayerTimes(response.timings)
                    }
                } else {
                    console.log("Failed to fetch prayer times from Salah Hour")
                }
            }
        }
        xhr.send()
    }
    
    function parsePrayerTimes(timings) {
        console.log("Parsing prayer times...")
        
        // extract time only (remove timezone and other info)
        prayerTimes = {
            "Fajr": extractTime(timings.Fajr),
            "Dhuhr": extractTime(timings.Dhuhr),
            "Asr": extractTime(timings.Asr),
            "Maghrib": extractTime(timings.Maghrib),
            "Isha": extractTime(timings.Isha)
        }
        
        console.log("Parsed prayer times: " + JSON.stringify(prayerTimes))
        
        findNextPrayer()
    }
    
    function extractTime(timeString) {
        // extract HH:MM from formats like "04:45 (EST)" or "04:45"
        if (!timeString) {
            console.log("Empty time string received")
            return "00:00"
        }
        
        // try to match HH:MM pattern
        var match = timeString.match(/(\d{1,2}:\d{2})/)
        var result = match ? match[1] : timeString.substring(0, 5)
        console.log("Extracted time from '" + timeString + "' -> '" + result + "'")
        return result
    }
    
    function findNextPrayer() {
        console.log("Finding next prayer...")
        
        var now = new Date()
        var currentMinutes = now.getHours() * 60 + now.getMinutes()
        
        console.log("Current time: " + now.getHours() + ":" + now.getMinutes() + " (" + currentMinutes + " minutes)")
        
        var prayers = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
        
        for (var i = 0; i < prayers.length; i++) {
            var prayer = prayers[i]
            var time = prayerTimes[prayer]
            if (!time) {
                console.log("No time for " + prayer)
                continue
            }
            
            var parts = time.split(":")
            var prayerMinutes = parseInt(parts[0]) * 60 + parseInt(parts[1])
            
            console.log(prayer + " at " + time + " (" + prayerMinutes + " minutes)")
            
            if (prayerMinutes > currentMinutes) {
                nextPrayer = prayer
                nextPrayerTime = time
                console.log("Next prayer is: " + nextPrayer + " at " + nextPrayerTime)
                updateCountdown()
                return
            }
        }
        
        // if no prayers left today, next is Fajr tomorrow
        nextPrayer = "Fajr"
        nextPrayerTime = prayerTimes.Fajr || "00:00"
        console.log("All prayers passed, next is Fajr tomorrow at " + nextPrayerTime)
        updateCountdown()
    }
    
    function updateCountdown() {
        if (!nextPrayerTime) return
        
        var now = new Date()
        var parts = nextPrayerTime.split(":")
        var prayerTime = new Date()
        prayerTime.setHours(parseInt(parts[0]))
        prayerTime.setMinutes(parseInt(parts[1]))
        prayerTime.setSeconds(0)
        prayerTime.setMilliseconds(0)
        
        // check if prayer is tomorrow
        if (prayerTime <= now) {
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
            showNotification(nextPrayer, minutesUntil)
        }
        
        if (minutesUntil === 0) {
            notificationShown = false
        }
    }
    
    function showNotification(prayer, minutes) {
        var prayerName = useArabic ? arabicPrayerNames[prayer] : prayer
        var message = useArabic ? 
            "حان وقت صلاة " + prayerName + " بعد " + minutes + " دقيقة" :
            prayer + " prayer in " + minutes + " minute" + (minutes > 1 ? "s" : "")
        
        console.log("Prayer notification: " + message)
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
    
    function getPrayerName(prayer) {
        return useArabic ? arabicPrayerNames[prayer] : prayer
    }
}