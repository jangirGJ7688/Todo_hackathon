# Todo_hackathon

This project was built as part of a take-home assignment for an iOS
role.

The core constraint of the assignment was intentionally simple:

> The app only cares about today.

There are no future tasks, no backlog, and no overdue items.\
Every new day starts with a clean slate.

I treated this constraint seriously and allowed it to guide both the
product decisions and the technical architecture.

------------------------------------------------------------------------

## My Approach

Instead of building a generic todo app and then restricting it, I
designed the system around the "today-only" rule from the start.

Key decisions:

-   Tasks are strictly bound to the current day
-   At the start of a new day, storage is physically cleared
-   No filtering hacks --- the reset is enforced at the persistence
    layer
-   Expiration logic is handled deterministically while the app is
    active

------------------------------------------------------------------------

## Features Implemented

-   Add tasks for the current day
-   Optional same-day expiration time
-   Mark tasks as complete
-   Automatic expiration state update when time passes (while app is
    active)
-   Smooth completion animations
-   Modern SwiftUI interface
-   Hard reset at midnight (even if app stays open)

The app is fully offline and makes no network calls.

------------------------------------------------------------------------

## Architecture

I implemented the app using MVVM with a repository abstraction.

Structure:

Todo_hackathon\
→ TaskListView (View)\
→ TaskListViewModel (Business Logic)\
→ TaskProtocol (Protocol)\
→ TaskManager (JSON-based persistence)

Why this structure:

-   Clear separation of concerns
-   Business rules live in the ViewModel
-   Persistence is abstracted behind a protocol
-   Easy to test and extend
-   No business logic inside the View

------------------------------------------------------------------------

## Persistence Strategy

Instead of using CoreData or SwiftData, I chose simple JSON file storage
via FileManager.

Reasoning:

-   Single lightweight entity
-   Strict daily lifecycle
-   No complex relationships
-   Fully offline requirement
-   Avoid unnecessary framework overhead

All tasks are stored locally in:

Documents/today_tasks.json

A stored reset date ensures that when the day changes, the file is wiped
and a clean slate is guaranteed.

------------------------------------------------------------------------

## Expiration Handling

When a task has an expiration time:

-   The ViewModel calculates the next upcoming expiration
-   A one-shot Timer is scheduled
-   When triggered:
    -   The repository updates expired tasks
    -   The UI refreshes

No polling loops and no misuse of background APIs.

------------------------------------------------------------------------

## What This Assignment Demonstrates

-   Clean MVVM architecture
-   Thoughtful handling of time-based state
-   Enforcing product constraints at the data layer
-   Avoiding overengineering
-   Clear separation between UI and business logic
-   Practical persistence decisions

------------------------------------------------------------------------

## Requirements

-   iOS 16+
-   Swift 5.7+
-   Xcode 14+

------------------------------------------------------------------------

## Notes

I intentionally focused on correctness, architecture clarity, and
respecting the product constraint rather than adding unnecessary
features.

The result is a small but deliberate implementation that reflects how I
approach structure, trade-offs, and maintainability in production apps.
