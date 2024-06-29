import SwiftUI

struct EventDisclosureView: View {
    @Binding var event: Event
    @Binding var expandedSections: Set<UUID>
    @ObservedObject var viewModel = NewEventViewModel()

    private var isExpanded: Binding<Bool> {
        Binding<Bool>(
            get: { expandedSections.contains(event.id) },
            set: { newValue in
                if newValue {
                    expandedSections.insert(event.id)
                } else {
                    expandedSections.remove(event.id)
                }
            }
        )
    }

    var body: some View {
        DisclosureGroup(isExpanded: isExpanded) {
            TextField("Event Title", text: $event.title)
                .onChange(of: event.title) {
                    viewModel.handleEventChange()
                }
            TextField("Event Description", text: $event.description)
                .onChange(of: event.description) {
                    viewModel.handleEventChange()
                }
            TextField("Event URL", text: $event.url)
                .onChange(of: event.url) {
                    viewModel.handleEventChange()
                }
            DatePicker(
                "Start Date",
                selection: $event.startDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .onChange(of: event.startDate) {
                viewModel.handleEventChange()
            }
            DatePicker(
                "End Date",
                selection: $event.endDate,
                in: event.startDate...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .onChange(of: event.endDate) {
                viewModel.handleEventChange()
            }
            Picker("Recurrence", selection: $event.recurrenceRule) {
                ForEach(RecurrenceOption.allCases, id: \.self) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            .onChange(of: event.recurrenceRule) {
                viewModel.handleEventChange()
            }
        } label: {
            Text(event.title.isEmpty ? "Event" : event.title)
        }
    }
}
