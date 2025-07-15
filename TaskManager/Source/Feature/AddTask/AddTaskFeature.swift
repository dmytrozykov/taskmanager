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
        case saveButtonTapped
        case setTitle(String)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .none

            case .saveButtonTapped:
                return .none

            case let .setTitle(title):
                state.task.title = title
                return .none
            }
        }
    }
}
