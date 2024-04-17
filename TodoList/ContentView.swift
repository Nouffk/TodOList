//
//  ContentView.swift
//  TodoList
//
//  Created by Nouf Faisal  on 08/10/1445 AH.
//

import SwiftUI
import CoreData

// Enum to define sorting options for tasks
enum Sorting {
    case dueDate, isCompleted, newestTask
}

// MARK: - Task Detail View
// View for displaying task details and handling task completion and favorite toggling
struct TaskDetailView: View {
    @ObservedObject var task: TaskItem

    var body: some View {
        HStack {
            // Button to toggle task completion status
            Button(action: {
                withAnimation {
                    toggleTaskCompletion()
                }
            }) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isDone ? .green : .primary)
            }
            .buttonStyle(.borderless)
            
            // Display task title, details, and due date
            VStack(alignment: .leading) {
                Text(task.title ?? "No title")
                    .strikethrough(task.isDone, color: .secondary)
                Text(task.details ?? "No details")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(task.dueDate?.formatted(.dateTime.day().month().year().hour().minute()) ?? "No Due Date")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Button to toggle task favorite status
            Image(systemName: task.isFavorite ? "heart.fill" : "heart")
                .foregroundColor(.red)
                .onTapGesture {
                    withAnimation {
                        toggleTaskFavorite()
                    }
                }
        }
    }
    
    // Function to toggle task completion status
    private func toggleTaskCompletion() {
        let context = task.managedObjectContext
        task.isDone.toggle()
        saveContext(context)
    }
    
    // Function to toggle task favorite status
    private func toggleTaskFavorite() {
        let context = task.managedObjectContext
        task.isFavorite.toggle()
        saveContext(context)
    }
    
    // Function to save changes to the managed object context
    private func saveContext(_ context: NSManagedObjectContext?) {
        guard let context = context else {
            print("Managed Object Context is nil")
            return
        }

        do {
            try context.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
}

// MARK: - Content View
// Main view for displaying the to-do list
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: TaskItem.entity(),
        sortDescriptors: []
    ) private var tasks: FetchedResults<TaskItem>

    // State variable for sorting option
    @State private var sorting: Sorting = .dueDate
    
    // State variable for showing the add new task view
    @State private var isShowingAddNewTaskView = false
    
    // Computed property to sort tasks based on the selected sorting option
    var sortedTasks: [TaskItem] {
        switch sorting {
            case .dueDate:
                return tasks.sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
            case .isCompleted:
                return tasks.filter { $0.isDone }.sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
            case .newestTask:
                return tasks.sorted { ($0.createdDate ?? Date()) > ($1.createdDate ?? Date()) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Menu to allow the user to choose sorting option
                Menu {
                    Button(action: {
                        sorting = .dueDate
                    }) {
                        Label("Sort by Due Date", systemImage: "calendar")
                    }
                    
                    Button(action: {
                        sorting = .isCompleted
                    }) {
                        Label("Sort by Is Completed", systemImage: "checkmark.circle")
                    }
                    
                    Button(action: {
                        sorting = .newestTask
                    }) {
                        Label("Sort by Newest Task", systemImage: "clock")
                    }
                } label: {
                    Text("Choose Sort Option")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                // List of sorted tasks
                List {
                    ForEach(sortedTasks, id: \.self) { task in
                        // Navigation link to edit task view
                        NavigationLink(destination: EditTaskView(task: task)) {
                            TaskDetailView(task: task)
                        }
                        // Swipe action for deleting task
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    deleteTask(task)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .navigationTitle("To Do List")
                .toolbar {
                    // Toolbar item for adding a new task
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingAddNewTaskView.toggle()
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingAddNewTaskView) {
            // Show add task view when needed
            AddTaskView(isShowingAddNewTaskView: $isShowingAddNewTaskView)
                .environment(\.managedObjectContext, viewContext)
        }
    }
    
    // Function to delete a task
    private func deleteTask(_ task: TaskItem) {
        viewContext.delete(task)
        try? viewContext.save()
    }
    
    // Computed property to get sorting option text
    var sortingOptionText: String {
        switch sorting {
            case .dueDate:
                return "Due Date"
            case .isCompleted:
                return "Is Completed"
            case .newestTask:
                return "Newest Task"
        }
    }
}

// MARK: - Preview
// Preview provider for ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, CoreDataManger.shared.container.viewContext)
    }
}

