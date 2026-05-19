# Podium Timer

Podium Timer is a SwiftUI debate timer for iPhone and iPad. It provides preset speech sequences for common speech and debate formats, per-speech countdown timers, prep-time tracking, overtime visuals, and configurable display settings.
## Features

- Event presets for Big Questions, Student Congress, Lincoln Douglas, Parliamentary, Policy, Public Forum, and World Schools.
- Swipe-based round navigation with one timer per speech segment.
- Circular countdown display with color-based warning states.
- Overtime mode with optional red screen background.
- AFF and NEG prep-time sheets for events that use prep time.
- Light and dark themes.
- Custom AFF and NEG colors.
- Configurable yellow and red timer warning thresholds.
- Optional dimming of secondary controls while a timer is running.
- Persistent settings through `@AppStorage`.

## Supported Events (Speech and prep regulations are to the best of my ability matched to NSDA and CHSSA rules):
Big Questions, Student Congress, Lincoln Douglas, Parliamentary, Policy, Public Forum, World Schools

Event timing data is defined in `AppState` inside `Podium_TimerApp.swift`.

## How It Works

The app starts on the event selection screen. Choosing an event initializes the event's speech timers and opens the debate timer view.

In the debate view:

- Use **Start** to run the current speech timer.
- Use **Stop** to pause the current timer.
- Use **Reset** to restore the current speech timer to its full duration.
- Swipe between speech stages when the timer is not running.
- Use **End Round** to return to event selection.
- Use the AFF/NEG prep buttons to manage prep time when the selected event supports it.

While a speech timer is running, the app disables the device idle timer so the display stays awake.

## Timer Behavior

`TimerCode` owns each speech countdown. It uses wall-clock elapsed time rather than decrementing only by tick count, which keeps the displayed time accurate across timer updates.

The timer display includes:

- A monospaced analog countdown.
- A circular progress ring.
- Green, yellow, and red progress colors based on configurable thresholds.
- An `OVERTIME` label after time expires.
- Optional red overtime background.

Prep timers are handled by `PrepTimeView`. Prep time can continue below zero, displays the last continuous run duration, and can be reset back to the event baseline.

## Settings

Open settings from the gear button on the event selection screen.

Available settings:

- Theme: Light or Dark.
- Overtime Red: enable or disable the red overtime background.
- Timer Stage Dimming: dim nonessential UI while a timer is active.
- Yellow Threshold: remaining time when the timer moves to warning color.
- Red Threshold: remaining time when the timer moves to danger color.
- Affirmative Color: custom AFF color.
- Negative Color: custom NEG color.
- Prep Time "Last used": show or hide last-used prep duration.
- Reset to Defaults: restore default settings.

## Project Structure

```text
Podium Timer/
├── README.md
├── Podium Timer/
│   ├── App Icon.icon
│   ├── Assets.xcassets
│   ├── DebateView.swift
│   ├── EventsView.swift
│   ├── IfGlassAvailable.swift
│   ├── MainView.swift
│   ├── Podium_TimerApp.swift
│   ├── PrepTimeView.swift
│   ├── SettingsView.swift
│   ├── StageIndicatorView.swift
│   ├── TimerCode.swift
│   └── TimerView.swift
└── Podium TimerUITests/
    ├── Podium TimerTests/
    │   └── Podium_TimerTests.swift
    ├── Podium_TimerUITests.swift
    └── Podium_TimerUITestsLaunchTests.swift
```

## Key Files

- `Podium_TimerApp.swift`: app entry point, shared `AppState`, and event preset definitions.
- `MainView.swift`: switches between event selection and debate timing screens.
- `EventsView.swift`: event list and settings overlay entry point.
- `DebateView.swift`: main round timer interface, speech navigation, prep-time entry, and end-round handling.
- `TimerView.swift`: visual countdown UI for a speech timer.
- `TimerCode.swift`: countdown model and timer logic.
- `PrepTimeView.swift`: AFF/NEG prep-time timer sheet.
- `SettingsView.swift`: persistent user settings.
- `StageIndicatorView.swift`: speech-stage progress indicator.
- `IfGlassAvailable.swift`: compatibility helper for newer glass-style button presentation.

## Requirements

- Xcode with SwiftUI support.
- iOS or iPadOS target capable of running the project.
- Swift toolchain provided by Xcode.

## Build and Run

1. Open the project in Xcode.
2. Select the `Podium Timer` scheme.
3. Choose an iPhone simulator, or a connected device.
4. Press `Cmd+R` to build and run.

## Development Notes

- The app uses SwiftUI views and `ObservableObject` state.
- User preferences are persisted with `@AppStorage`.
- Timer state is intentionally separated into `TimerCode` instances so each speech keeps its own countdown.
- Event presets are currently hard-coded in `AppState`; adding a new event requires adding its times, titles, speech types, and prep-time value.
- `IfGlassAvailable.swift` should be used for glass-style controls where platform support is available.
