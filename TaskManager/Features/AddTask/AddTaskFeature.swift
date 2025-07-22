import ComposableArchitecture
import Foundation

@Reducer
struct AddTaskFeature {
    @ObservableState
    struct State: Equatable {
        var task: TaskEntry
    }

    enum Action {
        case cancelButtonTapped
        case delegate(Delegate)
        case saveButtonTapped
        case setTitle(String)
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .run { _ in await dismiss() }

            case .delegate:
                return .none

            case .saveButtonTapped:
                return .run { [task = state.task] send in
                    await send(.delegate(.saveTask(task)))
                    await dismiss()
                }

            case let .setTitle(title):
                state.task.title = title
                return .none
            }
        }
    }
}

extension AddTaskFeature.Action {
    @CasePathable
    enum Delegate: Equatable {
        case saveTask(TaskEntry)
    }
}
