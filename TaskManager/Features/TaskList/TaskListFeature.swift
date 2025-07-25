import ComposableArchitecture
import Foundation

@Reducer
struct TaskListFeature {
    @ObservableState
    struct State: Equatable {
        var tasks: IdentifiedArrayOf<TaskEntry> = []
        @Presents var destination: Destination.State?
    }

    enum Action {
        case addButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case deleteButtonTapped(id: TaskEntry.ID)
        case toggleTaskCompletion(id: TaskEntry.ID)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.destination = .addTask(
                    AddTaskFeature.State(
                        task: TaskEntry(id: uuid(), title: "", isCompleted: false),
                    ),
                )
                return .none

            case let .destination(.presented(.addTask(.delegate(.saveTask(task))))):
                state.tasks.append(task)
                return .none

            case let .destination(.presented(.alert(.confirmDeletion(id: id)))):
                state.tasks.remove(id: id)
                return .none

            case .destination:
                return .none

            case let .deleteButtonTapped(id: id):
                guard let title = state.tasks[id: id]?.title else {
                    return .none
                }
                state.destination = .alert(.deleteConfirmation(id: id, title: title))
                return .none

            case let .toggleTaskCompletion(id: id):
                state.tasks[id: id]?.isCompleted.toggle()
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
    }
}

extension TaskListFeature.Action {
    @CasePathable
    enum Alert: Equatable {
        case confirmDeletion(id: TaskEntry.ID)
    }
}

extension TaskListFeature {
    @Reducer
    enum Destination {
        case addTask(AddTaskFeature)
        case alert(AlertState<TaskListFeature.Action.Alert>)
    }
}

extension TaskListFeature.Destination.State: Equatable {}

extension AlertState where Action == TaskListFeature.Action.Alert {
    static func deleteConfirmation(id: TaskEntry.ID, title: String) -> Self {
        Self {
            TextState("Delete '\(title)'?")
        } actions: {
            ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                TextState("Delete")
            }
        }
    }
}
