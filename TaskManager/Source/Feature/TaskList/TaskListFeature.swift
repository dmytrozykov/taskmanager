import ComposableArchitecture
import Foundation

@Reducer
struct TaskListFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var addTask: AddTaskFeature.State?
        var tasks: IdentifiedArrayOf<TaskEntry> = []
    }

    enum Action {
        case addButtonTapped
        case addTask(PresentationAction<AddTaskFeature.Action>)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.addTask = AddTaskFeature.State(
                    task: TaskEntry(id: UUID(), title: "", isCompleted: false),
                )
                return .none

            case let .addTask(.presented(.delegate(.saveTask(task)))):
                state.tasks.append(task)
                return .none

            case .addTask:
                return .none
            }
        }
        .ifLet(\.$addTask, action: \.addTask) {
            AddTaskFeature()
        }
    }
}
