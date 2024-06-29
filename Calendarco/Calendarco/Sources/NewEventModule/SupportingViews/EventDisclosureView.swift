import SwiftUI

struct EventDisclosureView: View {
    @EnvironmentObject private var mainViewModel: MainViewModel
    @ObservedObject var viewModel = NewEventViewModel()
    @Binding var event: Event
    @Binding var expandedSections: Set<UUID>

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
                    viewModel.handleEventChange(mainViewModel: mainViewModel)
                }
            TextField("Event Description", text: $event.eventDescription)
                .onChange(of: event.eventDescription) {
                    viewModel.handleEventChange(mainViewModel: mainViewModel)
                }
            TextField("Event URL", text: $event.url)
                .onChange(of: event.url) {
                    viewModel.handleEventChange(mainViewModel: mainViewModel)
                }
            DatePicker(
                "Start Date",
                selection: $event.startDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .onChange(of: event.startDate) {
                viewModel.handleEventChange(mainViewModel: mainViewModel)
            }
            DatePicker(
                "End Date",
                selection: $event.endDate,
                in: event.startDate...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .onChange(of: event.endDate) {
                viewModel.handleEventChange(mainViewModel: mainViewModel)
            }
            Picker("Recurrence", selection: $event.recurrenceRule) {
                ForEach(RecurrenceOption.allCases.map(\.rawValue), id: \.self) {
                    Text($0)
                        .tag($0)
                }
            }
            .onChange(of: event.recurrenceRule) {
                viewModel.handleEventChange(mainViewModel: mainViewModel)
            }
        } label: {
            Text(event.title.isEmpty ? "Event" : event.title)
        }
    }
}
