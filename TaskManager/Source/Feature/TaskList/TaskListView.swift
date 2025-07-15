import ComposableArchitecture
import SwiftUI

struct TaskListView: View {
    let store: StoreOf<TaskListFeature>

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.tasks) { task in
                    Text(task.title)
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem {
                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    TaskListView(
        store: Store(
            initialState: TaskListFeature.State(
                tasks: [
                    TaskEntry(id: UUID(), title: "Create view", isCompleted: false),
                    TaskEntry(id: UUID(), title: "Create feature", isCompleted: false),
                    TaskEntry(id: UUID(), title: "Create app", isCompleted: false),
                ],
            ),
        ) {
            TaskListFeature()
        },
    )
}
