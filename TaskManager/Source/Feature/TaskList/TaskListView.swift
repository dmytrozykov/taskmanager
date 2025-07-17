import ComposableArchitecture
import SwiftUI

struct TaskListView: View {
    @Bindable var store: StoreOf<TaskListFeature>

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.tasks) { task in
                    Text(task.title)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                store.send(.deleteButtonTapped(id: task.id))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
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
        .sheet(
            item: $store.scope(state: \.destination?.addTask, action: \.destination.addTask),
        ) { addTaskStore in
            NavigationStack {
                AddTaskView(store: addTaskStore)
            }
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
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
