# NepaliDate (macOS)

A lightweight, elegant Nepali Calendar (Bikram Sambat) application for the macOS menu bar.

## Features
- **Real-time Calendar**: View current Nepali date and month directly from the menu bar.
- **Date Converter**: Convert dates between English (AD) and Nepali (BS) seamlessly.
- **Smart Lifecycle**: Automatically resets to today's date when opened.
- **Seamless UX**: Closes automatically when the mouse leaves the calendar view.
- **Stable & Robust**: Handles system time/timezone changes without crashing or losing accuracy by using a fixed Gregorian reference.

## Project Structure

### [AppDelegate.swift](file:///Users/shishirpokhrel/Desktop/NepaliDate/NepaliDate/AppDelegate.swift)
The heart of the application lifecycle.
- Initializes the `NSStatusItem` in the macOS menu bar.
- Manages the `NSPopover` used to display the `CalendarView`.
- Observes system notifications like `.NSCalendarDayChanged`, `NSSystemClockDidChange`, and `NSSystemTimeZoneDidChange` to ensure the app stays in sync with the real world.
- Implements the "Reset to Today" logic and handles the status bar button clicks.

### [NepaliDateConverter.swift](file:///Users/shishirpokhrel/Desktop/NepaliDate/NepaliDate/NepaliDateConverter.swift)
The core logic engine for date calculations.
- **Lookup Table**: Contains a hardcoded dataset of days in each month for Nepali years 2000 BS to 2090 BS.
- **Epoch Calibration**: Calibrated to 1 Baisakh 2000 BS (equal to April 14, 1943 AD).
- **Core Algorithms**:
    - `toNepaliDate(from: Date)`: Calculates the number of days passed since the epoch and iterates through the lookup table to find the corresponding BS date.
    - `toEnglishDate(year:month:day:)`: The inverse calculation, adding days to the English epoch to find the AD date.
- **Shared Helpers**: Contains constants for month names and a utility to convert English digits to Devanagari.

### [CalendarView.swift](file:///Users/shishirpokhrel/Desktop/NepaliDate/NepaliDate/CalendarView.swift)
The main SwiftUI view for the calendar picker.
- Renders a grid of days for the selected Nepali month.
- Highlights "Today" based on the system date.
- Shows English date equivalents for each day.
- Implements the `.onHover` logic to close the popover when the cursor leaves.

### [ConverterView.swift](file:///Users/shishirpokhrel/Desktop/NepaliDate/NepaliDate/ConverterView.swift)
A utility window for manual date conversions.
- Allows users to input AD dates to get BS equivalents and vice-versa.
- Uses the same `NepaliDateConverter` engine for consistency.

## How it was built
1. **Foundation**: Built using **SwiftUI** for modern, declarative UI and **AppKit** (`NSStatusBar`, `NSStatusItem`) to integrate deeply with macOS.
2. **Date Logic**: Since Bikram Sambat is not a standard calendar in Foundation, we implemented a custom conversion engine based on historical month lengths.
3. **Stability**: Special care was taken to use a fixed `Calendar(identifier: .gregorian)` for all internal calculations. This ensures that even if a user changes their system calendar to something else (like Buddhist), the conversion math remains correct.
4. **Threading**: UI updates triggered by system notifications are explicitly dispatched to the **Main Thread** to ensure a crash-free experience.

## Building the Project
Run the provided `./build_pkg.sh` script to clean, build, sign (ad-hoc), and package the application into `NepaliDate.pkg`.
