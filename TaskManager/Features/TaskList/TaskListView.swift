import ComposableArchitecture
import SwiftUI

struct TaskListView: View {
    @Bindable var store: StoreOf<TaskListFeature>

    var body: some View {
        NavigationStack {
            taskList
                .navigationTitle("Tasks")
                .toolbar { toolbarContent }
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

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem {
            Button {
                store.send(.addButtonTapped)
            } label: {
                Image(systemName: "plus")
            }
        }
    }

    private var taskList: some View {
        List {
            ForEach(store.tasks) { task in
                TaskRowView(task: task) {
                    store.send(.toggleTaskCompletion(id: task.id))
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        store.send(.deleteButtonTapped(id: task.id))
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .tint(.red)
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
