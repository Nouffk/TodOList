//
//  AddTaskView.swift
//  TodoList
//
//  Created by Nouf Faisal  on 08/10/1445 AH.
//


import SwiftUI

// Define the view for adding a new task
struct AddTaskView: View {
    // State variables for holding task information
    @State var taskTitle: String = ""
    @State var taskDetails: String = ""
    @State var dueDate: Date = Date()
    @State var isDueDateEnabled: Bool = false
    @State private var showingErrorAlert = false
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isShowingAddNewTaskView: Bool

    // The body of the view, which represents the user interface
    var body: some View {
        // Create a navigation view
        NavigationView {
            // Create a form for the task information
            Form {
                // Section for task information
                Section(header: Text("TASK INFO"),
                        footer: Text("Every note you make is a step towards accomplishing your goals.")) {
                    // TextField for task title input
                    TextField("Task Title", text: $taskTitle)
                    // TextField for task details input
                    TextField("Task Details", text: $taskDetails)
                }

                // Toggle for enabling or disabling the due date selection
                Toggle("Schedule Date", isOn: $isDueDateEnabled)

                // If due date selection is enabled, show a date picker
                if isDueDateEnabled {
                    DatePicker(
                        "Due Date",
                        selection: $dueDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                }
            }
            // Set the navigation title
            .navigationTitle("Add New Task")
            // Add navigation bar items for cancel and save actions
            .navigationBarItems(leading: Button("Cancel") {
                // Close the view when cancel is clicked
                isShowingAddNewTaskView = false
            }, trailing: Button("Save") {
                // Validate input and save task
                if taskTitle.isEmpty || taskDetails.isEmpty {
                    // Show error alert if title or details are empty
                    showingErrorAlert = true
                } else {
                    // Create a new task item and set its properties
                    let newTask = TaskItem(context: viewContext)
                    newTask.title = taskTitle
                    newTask.details = taskDetails
                    newTask.dueDate = dueDate
                    newTask.isDone = false
                    newTask.isFavorite = false

                    // Save the new task to the context
                    do {
                        try viewContext.save()
                        // Close the view if the task is saved successfully
                        isShowingAddNewTaskView = false
                    } catch {
                        // Print an error message if saving fails
                        print("Error saving context: \(error)")
                    }
                }
            })
            // Alert for input errors
            .alert(isPresented: $showingErrorAlert) {
                Alert(title: Text("Error"), message: Text("Please enter both a title and details for the task."), dismissButton: .default(Text("OK")))
            }
        }
    }
}

// Preview structure for testing the AddTaskView
struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddTaskView(isShowingAddNewTaskView: .constant(true))
                .environment(\.managedObjectContext, CoreDataManger.shared.container.viewContext)
        }
    }
}

