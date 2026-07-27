<p align="center">
  <img src="Podium Timer/Images/Podium%20Banner.png" alt="Podium Timer Banner" width="400">
</p>

# Podium Timer

The Podium Timer is a SwiftUI-built iOS and iPadOS Speech & Debate timer, designed to help you keep track of speech times, preperation, and glanceable information during competition rounds. Podium Timer is built for visual clarity and customizability, keeping your mind on the flow and off the clock.

## Features

- Full support for most NSDA, TOC and CHSSA debate formats (Policy, Lincoln-Douglas, Public Forum, Student Congress, Parliamentary, etc.)
- Preparation tracking for supported events
- Navigation through speeches within a round via swipe gestures
- A full circle countdown clock with colored warnings
- An overtime indicator and option for red screen background during overtime
- Color options for Affirmative and Negative teams

## Requirements

- Mac computer running Xcode (26.0+) and SwiftUI
- Installed iOS or iPadOS simulator, or physical device that can run the target.

## How to Build & Run This Project:

1. git clone https://github.com/dashun090909/Podium-Timer.git
2. Start Xcode and open the PodiumTimer.xcodeproj file.
3. In the navigation bar select the "Podium Timer" scheme.
4. Choose either an iPhone simulator or connect a physical iPhone/iPad to test on real hardware.
5. Click "Run" or press cmd + R.

## Additional Development Information:

- All of the flow of the application is controlled via Podium_TimerApp. Users navigate to DebateView after selecting an EventView (the main view).
- Preferences are saved to local storage using @AppStorage.
- TimerCode manages the clock logic, even when the app is closed.
- All preset events along with their associated event data (times, names, speech type, prep time) are hardcoded into AppState.

## Screenshots

<p align="center">
  <img src="Podium Timer/Images/Screenshot1.png" width="250">
  <img src="Podium Timer/Images/Screenshot2.png" width="250">
  <img src="Podium Timer/Images/Screenshot3.png" width="250">
  <img src="Podium Timer/Images/Screenshot4.png" width="250">
</p>
