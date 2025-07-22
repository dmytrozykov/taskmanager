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
        expectedId: UUID,
    ) async {
        await store.send(.addButtonTapped) {
            $0.destination = .addTask(
                AddTaskFeature.State(
                    task: createTask(id: expectedId, title: ""),
                ),
            )
        }

        await store.send(\.destination.addTask.setTitle, title) {
            $0.destination?.modify(\.addTask) { $0.task.title = title }
        }

        await store.send(\.destination.addTask.saveButtonTapped)

        await store.receive(
            \.destination.addTask.delegate.saveTask,
            createTask(id: expectedId, title: title),
        ) {
            $0.tasks.append(
                createTask(id: expectedId, title: title),
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

        await addTask(to: store, title: "Test", expectedId: UUID(0))

        store.assert {
            $0.tasks = [expectedTask]
            $0.destination = nil
        }
    }

    @Test
    func toggleSingleTaskCompletion() async {
        let store = makeTestStore()
        let taskId = UUID(0)

        await addTask(to: store, title: "Test Task", expectedId: taskId)

        await store.send(\.toggleTaskCompletion, taskId) {
            $0.tasks[id: taskId]?.isCompleted = true
        }

        await store.send(\.toggleTaskCompletion, taskId) {
            $0.tasks[id: taskId]?.isCompleted = false
        }

        store.assert {
            $0.tasks = [createTask(id: taskId, title: "Test Task", isCompleted: false)]
        }
    }

    @Test
    func toggleMultipleTasksCompletion() async {
        let store = makeTestStore()

        let firstTaskId = UUID(0)
        let secondTaskId = UUID(1)

        await addTask(to: store, title: "First Task", expectedId: firstTaskId)
        await addTask(to: store, title: "Second Task", expectedId: secondTaskId)

        await store.send(\.toggleTaskCompletion, secondTaskId) {
            $0.tasks[id: firstTaskId]?.isCompleted = false
            $0.tasks[id: secondTaskId]?.isCompleted = true
        }

        store.assert {
            $0.tasks = [
                createTask(id: firstTaskId, title: "First Task", isCompleted: false),
                createTask(id: secondTaskId, title: "Second Task", isCompleted: true),
            ]
        }
    }

    @Test
    func addMultipleTasksFlow() async {
        let store = makeTestStore()

        await addTask(to: store, title: "First Task", expectedId: UUID(0))
        await addTask(to: store, title: "Second Task", expectedId: UUID(1))
        await addTask(to: store, title: "Third Task", expectedId: UUID(2))

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

        let taskId = UUID(1)

        await store.send(.deleteButtonTapped(id: taskId)) {
            $0.destination = .alert(.deleteConfirmation(id: taskId, title: "Second Task"))
        }
        await store.send(\.destination.alert.confirmDeletion, taskId) {
            $0.tasks = [
                createTask(id: UUID(0), title: "First Task"),
                createTask(id: UUID(2), title: "Third Task"),
            ]
            $0.destination = nil
        }
    }
}
