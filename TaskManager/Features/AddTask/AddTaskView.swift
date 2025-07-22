import ComposableArchitecture
import SwiftUI

struct AddTaskView: View {
    @Bindable var store: StoreOf<AddTaskFeature>

    var body: some View {
        Form {
            TextField("Title", text: $store.task.title.sending(\.setTitle))
            Button("Save") {
                store.send(.saveButtonTapped)
            }
        }
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem {
            Button("Cancel") {
                store.send(.cancelButtonTapped)
            }
        }
    }
}

#Preview {
    AddTaskView(
        store: Store(
            initialState: AddTaskFeature.State(
                task: TaskEntry(
                    id: UUID(),
                    title: "Go for a walk",
                    isCompleted: false,
                ),
            ),
        ) {
            AddTaskFeature()
        },
    )
}
