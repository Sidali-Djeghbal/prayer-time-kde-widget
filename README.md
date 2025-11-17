# Islamic Prayer Times - KDE Plasma 6 Widget

<div align="center">

![Prayer Times Widget](https://img.shields.io/badge/KDE-Plasma%206-blue)
![Version](https://img.shields.io/badge/version-1.0-green)
![License](https://img.shields.io/badge/license-GPL-orange)

**A beautiful and accurate Islamic prayer times widget for KDE Plasma 6**

[Features](#features) • [Installation](#installation) • [Configuration](#configuration) • [Screenshots](#screenshots) • [FAQ](#faq)

</div>

---

## 🕌 Features

- **Auto Geolocation** - Automatically detects your location on first use
- **Precise Prayer Times** - Uses latitude/longitude for accurate calculations
- **Notifications** - Visual alerts before prayer time (configurable)
- **Dual API Support** - Al-Adhan and Salah Hour APIs
- **Live Countdown** - Real-time countdown to next prayer
- **13 Calculation Methods** - Support for various Islamic schools
- **Arabic Language** - Full Arabic language support (مواقيت الصلاة)
- **Auto Update** - Automatically fetches next day's times after Isha

### Prayer Times Displayed
- Fajr (الفجر)
- Dhuhr (الظهر)
- Asr (العصر)
- Maghrib (المغرب)
- Isha (العشاء)

---

## Installation

### Prerequisites

- KDE Plasma 6 (Fedora 39+, Kubuntu 24.04+, or any KDE Plasma 6 distribution)
- Internet connection (for fetching prayer times)

### Method 1: Manual Installation (Recommended)

1. **Download or clone the widget:**
   ```bash
   git clone https://github.com/yourusername/prayer-times-kde-widget.git
   cd prayer-times-kde-widget
   ```

   Or download and extract the ZIP file.

2. **Verify the directory structure:**
   ```bash
   ls -R
   ```
   
   You should see:
   ```
   .
   ├── metadata.json
   ├── README.md
   └── contents/
       ├── config/
       │   ├── config.qml
       │   └── main.xml
       └── ui/
           ├── main.qml
           ├── CompactRepresentation.qml
           ├── FullRepresentation.qml
           └── configGeneral.qml
   ```

3. **Install the widget:**
   ```bash
   kpackagetool6 --type Plasma/Applet --install .
   ```

4. **Restart Plasma Shell:**
   ```bash
   killall plasmashell && kstart plasmashell &
   ```
   
   Or simply log out and log back in.

5. **Add the widget to your panel:**
   - Right-click on your panel
   - Click **"Enter Edit Mode"** or **"Add Widgets..."**
   - Search for **"Prayer Times"**
   - Drag it to your panel

### Method 2: Update Existing Installation

If you already have the widget installed and want to update:

```bash
cd prayer-times-kde-widget

# Remove old version
kpackagetool6 --type Plasma/Applet --remove org.kde.plasma.prayertimes

# Install new version
kpackagetool6 --type Plasma/Applet --install .

# Restart Plasma
killall plasmashell && kstart plasmashell &
```

---

## Configuration

### First Time Setup

1. **Click the widget** in your panel to open the popup
2. Click the **"Settings"** button
3. The widget will attempt to auto-detect your location

### Manual Configuration

If auto-detection doesn't work or you want to set a specific location:

#### Location Settings

1. **Auto-detect Location:**
   - Click **"Get My Location"** button
   - Wait for detection to complete
   - Location will be automatically saved

2. **Manual Entry:**
   - **City:** Enter your city name (e.g., London, Makkah, Cairo)
   - **Country:** Enter your country (e.g., UK, Saudi Arabia, Egypt)
   - **Latitude/Longitude:** Fine-tune coordinates for precision

#### API Settings

- **API Service:**
  - **Al-Adhan** (Recommended) - More reliable and widely used
  - **Salah Hour** - Alternative API

#### Calculation Method

Choose the calculation method that matches your region or preference:

| Method | Suitable For |
|--------|-------------|
| Muslim World League | Europe, Americas, parts of Africa |
| ISNA | North America |
| Umm Al-Qura | Saudi Arabia |
| Egyptian General Authority | Egypt, Sudan |
| Karachi | Pakistan, Bangladesh |
| Tehran | Iran |
| And 8 more methods... |

#### Notification Settings

- **Warning Minutes:** Set how many minutes before prayer time you want to be notified (1-60 minutes)
- The widget will show visual alerts (red pulsing border) when approaching prayer time

#### Language

- **Use Arabic:** Enable to display prayer names and labels in Arabic
  - English: Fajr, Dhuhr, Asr, Maghrib, Isha
  - Arabic: الفجر، الظهر، العصر، المغرب، العشاء

---

## Screenshots

![Panel View](screenshots/1.png)
![Panel View](screenshots/1.png)
![Popup View](screenshots/3.png)

---

## Troubleshooting

### Widget Not Appearing in Add Widgets List

1. **Check installation:**
   ```bash
   kpackagetool6 --type Plasma/Applet --list | grep prayer
   ```
   You should see: `org.kde.plasma.prayertimes`

2. **Check for errors:**
   ```bash
   journalctl --user -xe | grep prayer
   ```

3. **Reinstall:**
   ```bash
   kpackagetool6 --type Plasma/Applet --remove org.kde.plasma.prayertimes
   kpackagetool6 --type Plasma/Applet --install /path/to/prayer-times-kde-widget
   ```

4. **Clear cache and restart:**
   ```bash
   rm -rf ~/.cache/plasma*
   killall plasmashell && kstart plasmashell &
   ```

### Widget Says "Incompatible with Plasma 6"

Make sure your `metadata.json` contains:
```json
"X-Plasma-API-Minimum-Version": "6.0"
```

### Prayer Times Not Updating

1. **Check internet connection**
2. **Verify location settings** - Ensure latitude/longitude are not 0
3. **Try different API** - Switch between Al-Adhan and Salah Hour
4. **Check logs:**
   ```bash
   journalctl --user -f | grep prayer
   ```

### Location Auto-Detection Fails

If the "Get My Location" button doesn't work:
1. Check your internet connection
2. The service uses ipapi.co - ensure it's not blocked
3. Manually enter your coordinates from [latlong.net](https://www.latlong.net/)

### Configure Button Not Working

This was fixed in version 1.0. If you're using an older version:
```bash
kpackagetool6 --type Plasma/Applet --upgrade /path/to/prayer-times-kde-widget
```

---

## API Information

### Al-Adhan API
- **URL:** https://aladhan.com/
- **Free:** Yes
- **Rate Limit:** Generous
- **Coverage:** Worldwide
- **Accuracy:** High (uses coordinates)

### Salah Hour API
- **URL:** https://salahhour.com/
- **Free:** Yes
- **Rate Limit:** Moderate
- **Coverage:** Worldwide
- **Accuracy:** High (uses coordinates)

Both APIs are free and don't require API keys.

---

## Calculation Methods

The widget supports 14 different calculation methods:

1. **Shia Ithna-Ansari** - Shia calculation
2. **University of Islamic Sciences, Karachi** - Used in Pakistan, Bangladesh
3. **Islamic Society of North America (ISNA)** - Used in North America
4. **Muslim World League** - Used in Europe, Far East, parts of America
5. **Umm Al-Qura University, Makkah** - Used in Saudi Arabia
6. **Egyptian General Authority of Survey** - Used in Egypt, Sudan
7. **Institute of Geophysics, University of Tehran** - Used in Iran
8. **Gulf Region** - Used in Gulf countries
9. **Kuwait** - Used in Kuwait
10. **Qatar** - Used in Qatar
11. **Majlis Ugama Islam Singapura** - Used in Singapore
12. **Union Organization Islamic de France** - Used in France
13. **Diyanet İşleri Başkanlığı** - Used in Turkey
14. **Spiritual Administration of Muslims of Russia** - Used in Russia

---

## FAQ

### Q: Does this widget work offline?
**A:** No, it requires internet connection to fetch prayer times. However, once fetched, times are cached for the day.

### Q: How accurate are the prayer times?
**A:** Very accurate when using precise latitude/longitude coordinates. The widget uses your exact location for calculations.

### Q: Can I use this in countries with unusual timezones?
**A:** Yes! The widget automatically handles all timezones by using your system time and coordinates.

### Q: Does it support Sunnah/Nafl prayers?
**A:** Currently, only the 5 mandatory prayers are shown. Future versions may include optional prayers.

### Q: Can I customize the notification sound?
**A:** The current version shows visual notifications. System notification integration with sound will be added in future updates.

### Q: What happens at midnight?
**A:** The widget automatically fetches the next day's prayer times after Isha prayer.

### Q: Can I use this on Wayland?
**A:** Yes! The widget is fully compatible with both X11 and Wayland.

---

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

### Development Setup

1. Clone the repository
2. Make your changes
3. Test locally:
   ```bash
   kpackagetool6 --type Plasma/Applet --upgrade .
   killall plasmashell && kstart plasmashell &
   ```

### Areas for Contribution

- [ ] Additional language support (Urdu, Turkish, Malay, etc.)
- [ ] System notification integration
- [ ] Adhan sound playback
- [ ] Islamic calendar integration
- [ ] Widget themes/customization

---

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.

---

## Authors

**Sidali DJEGHBAL**
**Void Shell 777**

---

## Acknowledgments

- Al-Adhan API for providing free prayer times
- Salah Hour API for alternative data source
- KDE Community for the amazing Plasma desktop
- ipapi.co for geolocation services

---

## Changelog

### Version 1.0 (2024-11-17)

#### Features
-  Auto geolocation
-  Precise prayer times using coordinates
-  Arabic language support
-  14 calculation methods
-  Visual notifications
-  Dual API support
-  Live countdown
-  Auto daily updates

---

## Support

If you encounter any issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Check existing [GitHub Issues](https://github.com/Sidali-Djeghbal/prayer-times-kde-widget/issues)
3. Create a new issue with:
   - Your KDE Plasma version
   - Your distribution
   - Error logs (from `journalctl`)
   - Steps to reproduce

---

<div align="center">

**Made with ❤️ for the Muslim community**

</div>