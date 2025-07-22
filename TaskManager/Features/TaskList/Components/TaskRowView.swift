import SwiftUI

struct TaskRowView: View {
    let task: TaskEntry
    let onToggle: () -> Void

    var body: some View {
        HStack {
            ToggleButtonView(isCompleted: task.isCompleted, action: onToggle)

            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .secondary : .primary)

            Spacer()
        }
        .contentShape(.rect)
        .onTapGesture {
            onToggle()
        }
    }
}

#Preview {
    TaskRowView(
        task: TaskEntry(
            id: UUID(),
            title: "Test task",
            isCompleted: false,
        ),
        onToggle: {},
    )
}
