import ComposableArchitecture
import Foundation
import Testing

@testable import TaskManager

@MainActor
struct TaskListFeatureTests {
    // MARK: - Test Helpers

    private func makeTestStore(initialState: TaskListFeature.State = .init()) -> TestStoreOf<TaskListFeature> {
        TestStore(initialState: initialState) {
            TaskListFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
    }

    private func addTask(
        to store: TestStoreOf<TaskListFeature>,
        title: String,
        expectedID: UUID,
    ) async {
        await store.send(.addButtonTapped) {
            $0.destination = .addTask(
                AddTaskFeature.State(
                    task: TaskEntry(id: expectedID, title: "", isCompleted: false),
                ),
            )
        }

        await store.send(\.destination.addTask.setTitle, title) {
            $0.destination?.modify(\.addTask) { $0.task.title = title }
        }

        await store.send(\.destination.addTask.saveButtonTapped)

        await store.receive(
            \.destination.addTask.delegate.saveTask,
            TaskEntry(id: expectedID, title: title, isCompleted: false),
        ) {
            $0.tasks.append(
                TaskEntry(id: expectedID, title: title, isCompleted: false),
            )
        }

        await store.receive(\.destination.dismiss) {
            $0.destination = nil
        }
    }

    private func createTask(id: UUID, title: String, isCompleted: Bool = false) -> TaskEntry {
        TaskEntry(id: id, title: title, isCompleted: isCompleted)
    }

    // MARK: Tests

    @Test
    func addTaskFlow() async {
        let store = makeTestStore()
        let expectedTask = createTask(id: UUID(0), title: "Test")

        await addTask(to: store, title: "Test", expectedID: UUID(0))

        store.assert {
            $0.tasks = [expectedTask]
            $0.destination = nil
        }
    }

    @Test
    func toggleSingleTaskCompletion() async {
        let store = makeTestStore()
        let taskID = UUID(0)

        await addTask(to: store, title: "Test Task", expectedID: taskID)

        await store.send(\.toggleTaskCompletion, taskID) {
            $0.tasks[id: taskID]?.isCompleted = true
        }

        await store.send(\.toggleTaskCompletion, taskID) {
            $0.tasks[id: taskID]?.isCompleted = false
        }

        store.assert {
            $0.tasks = [createTask(id: taskID, title: "Test Task", isCompleted: false)]
        }
    }

    @Test
    func toggleMultipleTasksCompletion() async {
        let store = makeTestStore()

        let firstTaskID = UUID(0)
        let secondTaskID = UUID(1)

        await addTask(to: store, title: "First Task", expectedID: firstTaskID)
        await addTask(to: store, title: "Second Task", expectedID: secondTaskID)

        await store.send(\.toggleTaskCompletion, secondTaskID) {
            $0.tasks[id: firstTaskID]?.isCompleted = false
            $0.tasks[id: secondTaskID]?.isCompleted = true
        }

        store.assert {
            $0.tasks = [
                createTask(id: firstTaskID, title: "First Task", isCompleted: false),
                createTask(id: secondTaskID, title: "Second Task", isCompleted: true),
            ]
        }
    }

    @Test
    func addMultipleTasksFlow() async {
        let store = makeTestStore()

        await addTask(to: store, title: "First Task", expectedID: UUID(0))
        await addTask(to: store, title: "Second Task", expectedID: UUID(1))
        await addTask(to: store, title: "Third Task", expectedID: UUID(2))

        store.assert {
            $0.tasks = [
                createTask(id: UUID(0), title: "First Task"),
                createTask(id: UUID(1), title: "Second Task"),
                createTask(id: UUID(2), title: "Third Task"),
            ]
            $0.destination = nil
        }
    }

    @Test
    func deleteTask() async throws {
        let store = makeTestStore(
            initialState: TaskListFeature.State(
                tasks: [
                    createTask(id: UUID(0), title: "First Task"),
                    createTask(id: UUID(1), title: "Second Task"),
                    createTask(id: UUID(2), title: "Third Task"),
                ],
            ),
        )

        await store.send(.deleteButtonTapped(id: UUID(1))) {
            $0.destination = .alert(.deleteConfirmation(id: UUID(1), title: "Second Task"))
        }
        await store.send(\.destination.alert.confirmDeletion, UUID(1)) {
            $0.tasks = [
                createTask(id: UUID(0), title: "First Task"),
                createTask(id: UUID(2), title: "Third Task"),
            ]
            $0.destination = nil
        }
    }
}
