# Calendarco

Calendarco is a cloud-synced event management app developed with Swift and SwiftUI. It enables users to effortlessly create, manage, and organize events, ensuring their data is securely stored and synchronized across devices via Firebase. With an intuitive interface and powerful features, Calendarco helps users stay on top of their schedules with ease.

## Key Features

### Event Creation and Management
- Users can easily create, edit, and manage events using modules like `NewEventModule`. The app supports event customization with features like time, recurrence, and detailed descriptions, using models such as `Event.swift` and `EventEntity.swift`.
- Recurrence options allow users to set regular schedules for events.

### Data Persistence and Synchronization
- Integrated with Firebase (`FirebaseManager.swift`) for secure cloud storage and real-time synchronization, allowing access to events across multiple devices.
- Handles events as documents (`CalendarEventDocument.swift`), potentially supporting import/export functionality.

### User Interface
- Built with SwiftUI for a modern, declarative UI experience. The main dashboard (`MainView.swift`) provides an overview of events.
- Additional UI features include event detail views (`EventDisclosureView.swift`) and QR code sharing (`QRCodeView.swift`).

### Event History
- Users can track and view past events with `EventsHistoryView.swift`, useful for reviewing and referencing previous activities.

### App Architecture
- Adheres to the MVVM (Model-View-ViewModel) architecture, ensuring a modular, maintainable, and testable codebase.
