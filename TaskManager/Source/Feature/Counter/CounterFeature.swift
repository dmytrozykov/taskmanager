import ComposableArchitecture
import Foundation

@Reducer
struct CounterFeature {
    @ObservableState
    struct State: Equatable {
        var count = 0
        var isTimerRunning = false
    }

    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
        case timerTick
        case toggleTimerButtonTapped
    }

    enum CancelID {
        case timer
    }

    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                return .none

            case .incrementButtonTapped:
                state.count += 1
                return .none

            case .timerTick:
                state.count += 1
                return .none

            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    return .run { send in
                        for await _ in clock.timer(interval: .seconds(1)) {
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    return .cancel(id: CancelID.timer)
                }
            }
        }
    }
}
