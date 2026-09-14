import ballerina/http;
import ballerina/io;

// Connects to the running REST service on port 9090
final http:Client backendClient = check new ("http://localhost:9090");

public function main() returns error? {
    boolean keepRunning = true;

    io:println("====================================================");
    io:println("  MINISTRY OF HIGHER EDUCATION - SYSTEM TERMINAL    ");
    io:println("====================================================");

    while keepRunning {
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
            "status": "UNDER_MAINTENACE", // FIXED: Changed 'OPEN' to match valid server enum values
            "dateopened": "2026-09-14",
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
            "status": "UNDER_MAINTENACE" // FIXED: Aligned to valid server enum string
        };

        http:Response res = check backendClient->post("/add_subtask", taskPayload);
        io:println("Server Response Code: ", res.statusCode);
        io:println("Server Body Output: ", check res.getTextPayload());
    }
}

// 3. UPDATED INSTITUTION INTERFACE
function manageInstitutionsMenu() returns error? {
    io:println("\n--- CAMPUS RESOURCE MANAGEMENT ---");
    io:println("1. View Resource Details by Asset Tag");
    io:println("2. Register a New Campus Resource");
    io:println("3. Back to Main Menu");
    string instChoice = io:readln("Select an action (1-3): ");

    if instChoice == "1" {
        string tag = io:readln("Enter Asset Tag to search (e.g., NUST-LIB-3DP-001): ");
        io:println("\n[Scanning] Fetching asset configuration directory...");
        
        // FIXED: Route path converted from /resources to /assets
        http:Response res = check backendClient->get("/assets/" + tag);
        if res.statusCode == 200 {
            json item = check res.getJsonPayload();
            io:println("\n--- ASSET CONFIGURATION DATA ---");
            io:println(item.toJsonString());
        } else {
            io:println("Error: Could not retrieve asset registry data.");
        }
    } 
    else if instChoice == "2" {
        string assetTag = io:readln("Enter Unique Asset Tag (e.g., RES-102): ");
        string desc = io:readln("Enter Description of Item: ");
        string category = io:readln("Enter Category (e.g., BOOK or LOAN): ");
        string institution = io:readln("Enter Institution Name (e.g., NUST): ");
        string campus = io:readln("Assign to Campus Location: ");

        // FIXED: Remapped keys to exactly match the backend 'Resource' structural fields
        json resourcePayload = {
            "assetTag": assetTag,
            "category": category,
            "description": desc,
            "institution": institution,
            "campus": campus,
            "status": "AVAILABLE", // <--- ADD THIS LINE EXACTLY
            "dateAcquired": "2026-09-14" 
        };


        // FIXED: Target context altered from /resources to /assets
        http:Response res = check backendClient->post("/assets", resourcePayload);
        io:println("Server Response Code: ", res.statusCode);
        io:println("Server Body Output: ", check res.getTextPayload());
    }
}
