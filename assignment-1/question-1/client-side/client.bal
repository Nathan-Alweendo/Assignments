import ballerina/http;
import ballerina/io;

// Connects to the running service
final http:Client backendClient = check new ("http://localhost:9090");

public function main() returns error? {
    boolean keepRunning = true;

    io:println("====================================================");
    io:println("  MINISTRY OF HIGHER EDUCATION - SYSTEM TERMINAL    ");
    io:println("====================================================");

    while keepRunning {
        // Main Interactive Menu Options
        io:println("\n--- MAIN MENU INTERFACE ---");
        io:println("1. Check Maintenance Overdue Logs");
        io:println("2. Manage System Work Orders & Tasks");
        io:println("3. Manage Ministry Institutions");
        io:println("4. Exit Terminal Session");
        
        string choice = io:readln("Select a menu option (1-4): ");

        match choice {
            "1" => { check viewOverdueMaintenance(); }
            "2" => { check manageWorkOrdersMenu(); }
            "3" => { check manageInstitutionsMenu(); }
            "4" => {
                io:println("Shutting down client connection. Goodbye!");
                keepRunning = false;
            }
            _ => { io:println("Invalid option. Please try again."); }
        }
    }
}

//OVERDUE LOGS
function viewOverdueMaintenance() returns error? {
    io:println("\n[Scanning] Querying past-due items from backend...");
    http:Response res = check backendClient->get("/due_date_passed");
    
    if res.statusCode == 200 {
        json payload = check res.getJsonPayload();
        io:println("\n--- OVERDUE ENTRIES FOUND ---");
        io:println(payload.toJsonString());
    } else {
        io:println("Backend Notice: No overdue maintenance schedules found.");
    }
}

//ORDERS MENU
function manageWorkOrdersMenu() returns error? {
    io:println("\n--- WORK ORDER MANAGEMENT ---");
    io:println("1. Open a New Work Order");
    io:println("2. Look up Work Order by ID");
    io:println("3. Add a Sub-task to an Order");
    string subChoice = io:readln("Select an action (1-3): ");

    if subChoice == "1" {
        string orderID = io:readln("Enter New Order ID: ");
        string assetTag = io:readln("Enter Linked Asset Tag: ");
        string desc = io:readln("Enter Fault Description: ");
        
        json orderPayload = {
            "orderID": orderID,
            "entryID": "",
            "assetTag": assetTag,
            "componentID": "",
            "description": desc,
            "status": "OPEN",
            "dateopened": "2026-08-11",
            "dateclosed": "",
            "assignedTo": "Maintenance Staff"
        };

        http:Response res = check backendClient->post("/work_order", orderPayload);
        io:println("Server Response: ", check res.getTextPayload());
    } 
    else if subChoice == "2" {
        string id = io:readln("Enter Work Order ID: ");
        http:Response res = check backendClient->get("/work_order/" + id);
        if res.statusCode == 200 {
            json payload = check res.getJsonPayload();
            io:println(payload.toJsonString());
        } else {
            io:println("Error: Work order not found.");
        }
    }
    else if subChoice == "3" {
        string taskID = io:readln("Enter Sub-task ID: ");
        string workorderID = io:readln("Enter Parent Work Order ID: ");
        string desc = io:readln("Enter Sub-task Description (e.g., replace screen): ");

        json taskPayload = {
            "taskID": taskID,
            "workorderID": workorderID,
            "description": desc,
            "status": "PENDING"
        };

        http:Response res = check backendClient->post("/add_subtask", taskPayload);
        io:println("Server Response: ", check res.getTextPayload());
    }
}

//KENNEDY'S INSTITUTION INTERFACE
function manageInstitutionsMenu() returns error? {
    io:println("\n--- INSTITUTION LIST MANAGEMENT ---");
    io:println("1. View Current Registered Listings");
    io:println("2. Add a New Institution");
    io:println("3. Remove an Institution");
    string instChoice = io:readln("Select an action (1-3): ");

    if instChoice == "1" {
        json list = check backendClient->get("/institutions");
        io:println("\nActive System Directory: ", list.toJsonString());
    } 
    else if instChoice == "2" {
        string name = io:readln("Enter Institution Name to Add (e.g. IUM): ");
        string urlWithPath = "/institutions?institutionName=" + name;
        
        // Pass () as the body payload since the backend reads it from the URL string
        http:Response res = check backendClient->post(urlWithPath, ());
        io:println("Server Response: ", check res.getTextPayload());
    } 
    else if instChoice == "3" {
        string name = io:readln("Enter Institution Name to Remove: ");
        http:Response res = check backendClient->delete("/institutions/" + name);
        io:println("Server Response: ", check res.getTextPayload());
    }
    
}
