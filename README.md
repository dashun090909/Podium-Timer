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

- Xcode with the SwiftUI feature enabled.
- An iOS or iPadOS target which can run this project.
- Swift tool chain provided by Xcode.

## How to Build & Run This Project:

1. Start Xcode and open the PodiumTimer project.
2. In the upper right corner select the "Podium Timer" scheme.
3. Choose either an iPhone simulator or connect a physical iPhone/iPad to test on real hardware.
4. Click "Run" or press cmd + R.

## Additional Development Information:

- All of the flow of the application is controlled via Podium_TimerApp. Users navigate to DebateView after selecting an EventView (the main view).
- Preferences are saved to local storage using @AppStorage.
- TimerCode manages the clock logic, even when the app is closed.
- All preset events along with their associated event data (times, names, speech type, prep time) are hardcoded into AppState.
