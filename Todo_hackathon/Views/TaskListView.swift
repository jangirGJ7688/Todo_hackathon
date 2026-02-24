//
//  TaskListView.swift
//  Todo_hackathon
//
//  Created by Ganpat Jangir on 23/02/26.
//

import SwiftUI

struct TaskListView: View {
    
    @StateObject private var viewModel: TaskListViewModel
    @FocusState private var isFocused: Bool
    
    init(viewModel: TaskListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.9),
                    Color.blue.opacity(0.7),
                    Color.black.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                headerView
                
                taskInputCard
                
                if viewModel.tasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
                
                Spacer()
            }
            .padding(20)
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.willEnterForegroundNotification
        )) { _ in
            viewModel.loadTasks()
        }
        .alert("Task Required",
               isPresented: $viewModel.showEmptyTaskAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter a task before adding.")
        }
    }
}

extension TaskListView {
    
    var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text("Today")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
            
            Text(progressText)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var progressText: String {
        let completed = viewModel.tasks.filter { $0.isCompleted }.count
        let total = viewModel.tasks.count
        return total == 0 ? "Fresh start." : "\(completed) of \(total) completed"
    }
}

extension TaskListView {
    
    var taskInputCard: some View {
        VStack(spacing: 12) {
            
            TextField("What matters today?", text: $viewModel.newTaskTitle)
                .focused($isFocused)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(14)
            
            DatePicker(
                "Expires",
                selection: Binding(
                    get: { viewModel.selectedExpiration ?? Date() },
                    set: { viewModel.selectedExpiration = $0 }
                ),
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .foregroundColor(.white)
            
            Button {
                withAnimation {
                    viewModel.addTask()
                }
                isFocused = false
            } label: {
                Text("Add Task")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(14)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.4), radius: 20)
    }
}

extension TaskListView {
    
    var taskList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.tasks) { task in
                    TaskRowView(task: task) {
                        viewModel.toggleTask(task)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .padding(.horizontal, -20)
    }
}

extension TaskListView {
    
    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text("A Fresh Start")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text("What matters today?")
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 60)
    }
}
