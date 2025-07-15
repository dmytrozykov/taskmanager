import Foundation

struct TaskEntry: Identifiable, Equatable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
}
