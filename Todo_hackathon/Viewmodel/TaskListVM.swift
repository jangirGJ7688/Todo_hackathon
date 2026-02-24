//
//  TaskListVM.swift
//  Todo_hackathon
//
//  Created by Ganpat Jangir on 23/02/26.
//

import SwiftUI
import Combine

@MainActor
final class TaskListViewModel: ObservableObject {
    
    @Published private(set) var tasks: [Task] = []
    @Published var newTaskTitle = ""
    @Published var selectedExpiration: Date? = nil
    @Published var showEmptyTaskAlert = false
    
    private let manager: TaskProtocol
    private var midnightTimer: Timer?
    private var expirationTimer: Timer?
    
    init(manager: TaskProtocol) {
        self.manager = manager
        loadTasks()
        scheduleMidnightCleanup()
    }
    
    func loadTasks() {
        tasks = manager.fetchTodayTasks()
        scheduleNextExpiration()
    }
    
    func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            showEmptyTaskAlert = true
            return
        }
        
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        
        var validExpiration: Date? = nil
        
        if let expiration = selectedExpiration,
           expiration >= start,
           expiration < end {
            validExpiration = expiration
        }
        
        manager.addTask(title: trimmed, expiresAt: validExpiration)
        
        newTaskTitle = ""
        selectedExpiration = nil
        loadTasks()
    }
    
    func toggleTask(_ task: Task) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            manager.toggleTask(task)
            loadTasks()
        }
        triggerHaptic()
    }
    
    // MARK: - Haptic
    
    private func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - Midnight Reset
    
    private func scheduleMidnightCleanup() {
        midnightTimer?.invalidate()
        
        let now = Date()
        let nextMidnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) ?? now
        
        let interval = nextMidnight.timeIntervalSince(now)
        
        midnightTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: false
        ) { [weak self] _ in
            self?.handleNewDay()
        }
    }
    
    private func scheduleNextExpiration() {
        expirationTimer?.invalidate()
        
        let upcomingExpirations = tasks
            .compactMap { $0.expiresAt }
            .filter { $0 > Date() }
            .sorted()
        
        guard let nextExpiration = upcomingExpirations.first else {
            return
        }
        
        let interval = nextExpiration.timeIntervalSinceNow
        
        expirationTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: false
        ) { [weak self] _ in
            self?.handleExpiration()
        }
    }
    
    private func handleExpiration() {
        manager.markExpiredTasksIfNeeded()
        loadTasks()
        scheduleNextExpiration()
    }
    
    private func handleNewDay() {
        loadTasks()
        scheduleMidnightCleanup()
    }
}
