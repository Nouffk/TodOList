//
//  EidtTaskView.swift
//  TodoList
//
//  Created by Nouf Faisal  on 08/10/1445 AH.
//

import SwiftUI

// Define the view for editing an existing task
struct EditTaskView: View {
    @ObservedObject var task: TaskItem // Observed object for the task to be edited
    @Environment(\.managedObjectContext) var viewContext // Managed object context for saving changes
    @Environment(\.dismiss) var dismiss // Dismiss the view
    // State variables for holding task information
    @State private var taskTitle: String = ""
    @State private var taskDetails: String = ""
    @State private var dueDate: Date = Date()
    @State private var isDueDateEnabled: Bool = false
    @State private var showingErrorAlert: Bool = false

    // The body of the view, which represents the user interface
    var body: some View {
        NavigationStack {
            Form {
                // Section for task information with header and footer text
                Section(header: Text("TASK INFO"),
                        footer: Text("Every note you make is a step towards accomplishing your goals.")) {
                    // TextField for task title and details input
                    TextField("Task Title (e.g., 'Grocery Shopping')", text: $taskTitle)
                    TextField("Task Details (e.g., 'List of groceries to buy')", text: $taskDetails)
                }

                // Toggle for enabling or disabling the due date selection with animation
                Toggle("Schedule Date", isOn: $isDueDateEnabled.animation())

                // If due date selection is enabled, show a date picker
                if isDueDateEnabled {
                    DatePicker("Due Date", selection: $dueDate, in: Date()..., displayedComponents: .date)
                }

                // Button for updating the task and error alert
                Button("Update Task") {
                    if taskTitle.isEmpty || taskDetails.isEmpty {
                        showingErrorAlert = true
                    } else {
                        // Update the task properties with the input values and save changes
                        task.title = taskTitle
                        task.details = taskDetails
                        task.dueDate = isDueDateEnabled ? dueDate : nil
                        
                        do {
                            try viewContext.save()
                            dismiss()
                        } catch {
                            print("Error saving context: \(error)")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .alert("Please enter both a title and details for the task.", isPresented: $showingErrorAlert) {
                    Button("OK", role: .cancel) { }
                }
            }
            // Set navigation title and initialize state variables
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                taskTitle = task.title ?? ""
                taskDetails = task.details ?? ""
                if let taskDueDate = task.dueDate {
                    dueDate = taskDueDate
                    isDueDateEnabled = true
                }
            }
        }
    }
}
