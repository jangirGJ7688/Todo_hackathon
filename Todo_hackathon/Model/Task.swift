//
//  Task.swift
//  Todo_hackathon
//
//  Created by Ganpat Jangir on 23/02/26.
//

import Foundation

struct Task: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var isExpired: Bool
    var createdAt: Date
    var expiresAt: Date?
    
    init(title: String, expiresAt: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.isExpired = false
        self.createdAt = Date()
        self.expiresAt = expiresAt
    }
}
