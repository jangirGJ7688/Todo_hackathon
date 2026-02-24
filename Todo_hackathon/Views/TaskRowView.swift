//
//  TaskRowView.swift
//  Todo_hackathon
//
//  Created by Ganpat Jangir on 23/02/26.
//

import SwiftUI

struct TaskRowView: View {
    
    let task: Task
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .strokeBorder(Color.white.opacity(0.4), lineWidth: 2)
                    .frame(width: 26, height: 26)
                
                if task.isCompleted {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 26, height: 26)
                        .scaleEffect(1.2)
                        .animation(.spring(), value: task.isCompleted)
                }
            }
            .onTapGesture {
                onToggle()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .foregroundColor(.white)
                    .strikethrough(task.isCompleted)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(task.isExpired ? .red : .white)
                    .opacity(task.isExpired ? 0.6 : 1)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.25), radius: 10)
        .scaleEffect(task.isCompleted ? 0.97 : 1.0)
        .opacity(task.isCompleted ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
    }
    
    private var isExpired: Bool {
        if let expiresAt = task.expiresAt {
            return expiresAt < Date() && !task.isCompleted
        }
        return false
    }
}
