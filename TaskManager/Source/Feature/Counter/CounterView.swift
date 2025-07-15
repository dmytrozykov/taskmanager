import ComposableArchitecture
import SwiftUI

struct CounterView: View {
    let store: StoreOf<CounterFeature>

    var body: some View {
        VStack {
            counterView
            counterButtons
            toggleTimerButton
        }
        .font(.largeTitle)
    }

    private var counterView: some View {
        Text("\(store.count)")
            .padding()
    }

    private var counterButtons: some View {
        HStack {
            Button("-") {
                store.send(.decrementButtonTapped)
            }
            .buttonStyle(.bordered)
            .padding()

            Button("+") {
                store.send(.incrementButtonTapped)
            }
            .buttonStyle(.bordered)
            .padding()
        }
    }

    private var toggleTimerButton: some View {
        Button(store.isTimerRunning ? "Stop Timer" : "Start Timer") {
            store.send(.toggleTimerButtonTapped)
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .tint(store.isTimerRunning ? .red : .accentColor)
    }
}

#Preview {
    CounterView(
        store: Store(initialState: CounterFeature.State()) {
            CounterFeature()
        },
    )
}
