import SwiftUI

struct ToggleButtonView: View {
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isCompleted ? .green : .secondary)
        }
    }
}

#Preview {
    @Previewable @State var isCompleted = false
    ToggleButtonView(isCompleted: isCompleted) {
        isCompleted.toggle()
    }
}
