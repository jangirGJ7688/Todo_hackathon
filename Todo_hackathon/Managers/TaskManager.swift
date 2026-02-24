//
//  TaskManager.swift
//  Todo_hackathon
//
//  Created by Ganpat Jangir on 23/02/26.
//

import Foundation

protocol TaskProtocol {
    func fetchTodayTasks() -> [Task]
    func addTask(title: String, expiresAt: Date?)
    func toggleTask(_ task: Task)
    func markExpiredTasksIfNeeded()
}

final class TaskManager: TaskProtocol {
    
    private let fileURL: URL
    private let queue = DispatchQueue(label: "TaskManagerQueue")
    private let lastResetKey = "lastResetDate"
    
    init(fileName: String = "today_tasks.json") {
        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        
        fileURL = documents.appendingPathComponent(fileName)
    }
    
    func fetchTodayTasks() -> [Task] {
        queue.sync {
            performDailyResetIfNeeded()
            return loadTasks()
        }
    }
    
    func addTask(title: String, expiresAt: Date?) {
        queue.sync {
            var tasks = loadTasks()
            tasks.append(Task(title: title, expiresAt: expiresAt))
            saveTasks(tasks)
        }
    }
    
    func toggleTask(_ task: Task) {
        queue.sync {
            var tasks = loadTasks()
            
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index].isCompleted.toggle()
                saveTasks(tasks)
            }
        }
    }
    
    private func loadTasks() -> [Task] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Task].self, from: data)
        } catch {
            return []
        }
    }
    
    private func saveTasks(_ tasks: [Task]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(tasks)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Save error:", error)
        }
    }
    
    private func filterToday(_ tasks: [Task]) -> [Task] {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        
        return tasks.filter {
            $0.createdAt >= start && $0.createdAt < end
        }
    }
    
    private func performDailyResetIfNeeded() {
        let todayStart = Calendar.current.startOfDay(for: Date())
        
        let storedDate = UserDefaults.standard.object(forKey: lastResetKey) as? Date
        let storedStart = storedDate.map {
            Calendar.current.startOfDay(for: $0)
        }
        
        if storedStart != todayStart {
            // New day → wipe file
            saveTasks([])
            UserDefaults.standard.set(todayStart, forKey: lastResetKey)
        }
    }
    
    func markExpiredTasksIfNeeded() {
        queue.sync {
            var tasks = loadTasks()
            var updated = false
            
            for index in tasks.indices {
                if let expiresAt = tasks[index].expiresAt,
                   expiresAt <= Date(),
                   !tasks[index].isCompleted,
                   !tasks[index].isExpired {
                    
                    tasks[index].isExpired = true
                    updated = true
                }
            }
            
            if updated {
                saveTasks(tasks)
            }
        }
    }
}
