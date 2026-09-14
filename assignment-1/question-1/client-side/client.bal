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
        io:println("3. Manage Ministry Institutions & Resources");
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

// 1. OVERDUE LOGS
function viewOverdueMaintenance() returns error? {
    io:println("\n[Scanning] Querying past-due items from backend...");
    http:Response res = check backendClient->get("/due_date_passed");
    
    if res.statusCode == 200 {
        json payload = check res.getJsonPayload();
        io:println("\n--- OVERDUE ENTRIES FOUND ---");
        io:println(payload.toJsonString());
    } else {
        io:println("Backend Notice: No overdue maintenance schedules found or connection error.");
    }
}

// 2. ORDERS MENU
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
        io:println("Server Response Code: ", res.statusCode);
        io:println("Server Body Output: ", check res.getTextPayload());
    } 
    else if subChoice == "2" {
        string id = io:readln("Enter Work Order ID: ");
        http:Response res = check backendClient->get("/work_order/" + id);
        if res.statusCode == 200 {
            json payload = check res.getJsonPayload();
            io:println("\n--- WORK ORDER RECORD ---");
            io:println(payload.toJsonString());
        } else {
            io:println("Error: Work order ID not found on server.");
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
        io:println("Server Response Code: ", res.statusCode);
        io:println("Server Body Output: ", check res.getTextPayload());
    }
}

// 3. UPDATED INSTITUTION INTERFACE: GLOBAL, CAMPUS & RESOURCE TRACKING
function manageInstitutionsMenu() returns error? {
    io:println("\n--- CAMPUS RESOURCE MANAGEMENT ---");
    io:println("1. Global View (Show All Book & Loan Resources)");
    io:println("2. Campus View (Filter Resources by Specific Institution)");
    io:println("3. Register a New Campus Resource (Book or Loan)");
    io:println("4. Back to Main Menu");
    string instChoice = io:readln("Select an action (1-4): ");

    if instChoice == "1" {
        io:println("\n[Scanning] Fetching global inventory directory...");
        http:Response res = check backendClient->get("/resources/global");
        if res.statusCode == 200 {
            json list = check res.getJsonPayload();
            io:println("\n--- GLOBAL INVENTORY MAP ---");
            io:println(list.toJsonString());
        } else {
            io:println("Error: Could not retrieve global system directory.");
        }
    } 
    else if instChoice == "2" {
        string campusName = io:readln("Enter Campus Name to filter (e.g., IUM, UNAM, NUST): ");
        io:println("\n[Filtering] Gathering records for campus: " + campusName);
        
        http:Response res = check backendClient->get("/resources/campus/" + campusName);
        if res.statusCode == 200 {
            json list = check res.getJsonPayload();
            io:println("\n--- CAMPUS VIEW: " + campusName + " ---");
            io:println(list.toJsonString());
        } else {
            io:println("Error: Could not find resource entries for this campus.");
        }
    } 
    else if instChoice == "3" {
        string resourceID = io:readln("Enter Unique Resource ID (e.g., RES-101): ");
        string title = io:readln("Enter Title/Description of Item: ");
        string resourceType = io:readln("Enter Resource Category (BOOK or LOAN): ");
        string campusAssignment = io:readln("Assign to Campus Name: ");
        
        // FIX: Replaced .toUpperCase() with standard type-bound method
        string upperType = string:toUpperAscii(resourceType);

        json resourcePayload = {
            "resourceID": resourceID,
            "title": title,
            "resourceType": upperType,
            "institutionName": campusAssignment,
            "status": "AVAILABLE"
        };

        http:Response res = check backendClient->post("/resources", resourcePayload);
        io:println("Server Response Code: ", res.statusCode);
        io:println("Server Body Output: ", check res.getTextPayload());
    }
}
