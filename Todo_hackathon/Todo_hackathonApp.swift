import SwiftUI

@main
struct Todo_hackathonApp: App {
    
    private let manager = TaskManager()
    
    var body: some Scene {
        WindowGroup {
            TaskListView(viewModel: TaskListViewModel(manager: manager))
        }
    }
}
