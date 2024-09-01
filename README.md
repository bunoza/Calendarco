# Calendarco

Calendarco is a cloud-synced event management app developed with Swift and SwiftUI. It enables users to effortlessly create, manage, and organize events, ensuring their data is securely stored and synchronized across devices via Firebase. With an intuitive interface and powerful features, Calendarco helps users stay on top of their schedules with ease.

## Key Features

### Event Creation and Management
- Users can easily create, edit, and manage events using modules like `NewEventModule`. The app supports event customization with features like time, recurrence, and detailed descriptions, using models such as `Event.swift` and `EventEntity.swift`.
- Recurrence options allow users to set regular schedules for events.

### Data Persistence and Synchronization
- Integrated with Firebase (`FirebaseManager.swift`) for secure cloud storage and real-time synchronization, allowing access to events across multiple devices.
- Handles events as documents (`CalendarEventDocument.swift`), supporting import/export functionality.

### User Interface
- Built with SwiftUI for a modern, declarative UI experience. The main dashboard (`MainView.swift`) provides an overview of events.
- Additional UI features include event detail views (`EventDisclosureView.swift`) and QR code sharing (`QRCodeView.swift`).

### Event History
- Users can track and view past events with `EventsHistoryView.swift`, useful for reviewing and referencing previous activities.

### App Architecture
- Adheres to the MVVM (Model-View-ViewModel) architecture, ensuring a modular, maintainable, and testable codebase.



### Privacy Policy for Calendarco**

**Effective Date:** September 1st, 2024.

**1. Introduction**

Welcome to Calendarco. We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application, Calendarco. Please read this policy carefully to understand our views and practices regarding your personal data and how we will treat it.

**2. Information We Collect**

We may collect and process the following information:

- **Personal Data:** When you create events, we collect data such as event titles, descriptions, dates, and recurrence rules. This data is stored on our secure servers for a limited time.
- **Usage Data:** We may collect information about how you access and use the app, such as the features you use and the actions you take.
- **Device Data:** We may collect information about your device, such as your IP address, device type, operating system, and app version.

**3. How We Use Your Information**

We use the information we collect in the following ways:

- To provide and maintain our service, including sharing events via .ics files and QR codes.
- To improve, personalize, and expand our app's features and functionality.
- To analyze usage to improve our app and develop new features.

**4. Data Storage and Retention**

- **Event Data Storage:** Events you create are stored on our secure servers. These events are retained for 7 days and are then automatically deleted. This retention policy helps us ensure that your data is only kept for as long as necessary to provide our services.
- **Usage Data Retention:** We may retain anonymized usage data for analysis and improvement of our services without time limitations.

**5. Sharing Your Information**

We do not share your personal data with third parties, except in the following cases:

- **With your consent:** We may share your data with third parties if you have provided explicit consent.
- **Legal obligations:** If required by law or in response to legal processes, we may disclose your data to the appropriate authorities.

**6. Data Security**

We implement appropriate technical and organizational measures to protect your personal data. However, no method of transmission over the Internet or method of electronic storage is 100% secure, and we cannot guarantee absolute security.

**7. Your Data Rights**

Depending on your location, you may have the following rights regarding your personal data:

- The right to access your data.
- The right to correct or update your data.
- The right to delete your data.
- The right to object to or restrict the processing of your data.
- The right to data portability.

To exercise these rights, please contact us at devbunoza@gmail.com.

**8. Third-Party Links**

Our app may contain links to third-party websites or services. We are not responsible for the privacy practices or content of these third parties.

**9. Changes to This Privacy Policy**

We may update this Privacy Policy from time to time. Any changes will be posted within the app and the updated policy will be effective immediately upon posting.

**10. Contact Us**

If you have any questions about this Privacy Policy, please contact us at:

Calendarco
devbunoza@gmail.com
