import ComposableArchitecture
import Foundation

@Reducer
struct TaskListFeature {
    @ObservableState
    struct State: Equatable {
        var tasks: IdentifiedArrayOf<TaskEntry> = []
    }

    enum Action {
        case addButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .addButtonTapped:
                .none
            }
        }
    }
}
