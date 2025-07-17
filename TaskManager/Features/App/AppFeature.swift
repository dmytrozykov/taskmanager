import ComposableArchitecture

@Reducer
struct AppFeature {
    struct State: Equatable {
        var taskList = TaskListFeature.State()
    }

    enum Action {
        case taskList(TaskListFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.taskList, action: \.taskList) {
            TaskListFeature()
        }
    }
}
