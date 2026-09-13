import ballerina/http;
import ballerina/time;

type Resource record {|
    readonly string assetTag;
    string category;
    string description;
    string institution;
    string campus;
    string dateAquired;
|};

enum Status {
    AVAILABLE,
    LOANED_OUT,
    UNDER_MAINTENACE,
    DISPOSED
}

// Record for components and assetTag as the foreign key
type Component record {|
    readonly string id;
    string name;
    string description;
    string status;
    string assetTag;
    string date_acquired;
|};

// Record for ScheduleEntry and assetTag as the foreign key
type ScheduleEntry record {|
    readonly string entryID;
    string assetTag;
    string maintenanceType;
    string startdate;
    string duedate;
    string status;
    string description;
|};

// Record for WorkOrder and assetTag as the foreign key
type WorkOrder record {|
    readonly string orderID;
    string entryID;
    string assetTag;
    string componentID;
    string description;
    string status;
    string dateopened;
    string dateclosed;
    string assignedTo;
|};

// Record for subtask and workorder as the foreign key
type subtask record {|
    readonly string taskID;
    string workorderID;
    string description;
    string status;
|};

table<subtask> key(taskID) subtask_Table = table [];
table<ScheduleEntry> key(entryID) ScheduleEntry_Table = table [];
table<Component> key(id) Component_Table = table [];
table<WorkOrder> key(orderID) WorkOrder_Table = table [];
table<Resource> key(assetTag) Resource_table = table [];

//defining the table listing for Add/Remove institutions
string[] institution_listings = ["NUST", "UNAM"];

# A service representing a network-accessible API
# bound to port `9090`.
// A service representing a network-accessible API
// bound to port 9090.
service / on new http:Listener(9090) {

// =========================================================
// RESOURCE CRUD OPERATIONS 
// =========================================================

// CREATE: Add a new resource
resource function post assets(Resource newResource) returns string|error {

    if Resource_table.hasKey(newResource.assetTag) {
        return error("Resource with asset tag already exists");
    }

    Resource_table.add(newResource);

    return "Resource added successfully";
}

// READ: Look up a resource using its asset tag
resource function get assets/[string assetTag]() returns Resource|error {

    Resource? foundResource = Resource_table[assetTag];

    if foundResource is Resource {
        return foundResource;
    }

    return error("Resource not found");
}

// UPDATE: Update an existing resource
resource function put assets/[string assetTag](Resource updatedResource) returns string|error {

    if !Resource_table.hasKey(assetTag) {
        return error("Resource not found");
    }

    if assetTag != updatedResource.assetTag {
        return error(
            "Asset tag in URL does not match asset tag in request body"
        );
    }

    Resource_table.put(updatedResource);

    return "Resource updated successfully";
}

// DELETE: Remove a resource using its asset tag
resource function delete assets/[string assetTag]() returns string|error {

    if !Resource_table.hasKey(assetTag) {
        return error("Resource not found");
    }

    var _ = Resource_table.remove(assetTag);

    return "Resource deleted successfully";
}
    // =========================================================
    // COMPONENT CRUD OPERATIONS 
    // =========================================================

    // CREATE: Add a new component
    resource function post component(Component component) returns string|error {

        // Check that the referenced resource exists
        if !Resource_table.hasKey(component.assetTag) {
            return error("Referenced asset does not exist");
        }

        // Check if component already exists
        if Component_Table.hasKey(component.id) {
            return error("Component already exists");
        }

        Component_Table.add(component);

        return "Component added successfully";
    }

    // READ: Look up a component using its ID
    resource function get component/[string id]() returns Component|error {

        Component? component = Component_Table[id];

        if component is Component {
            return component;
        }

        return error("Component not found");
    }

    // UPDATE: Update an existing component
    resource function put component/[string id](Component component) returns string|error {

        // Check that the component exists
        if !Component_Table.hasKey(id) {
            return error("Component not found");
        }

        // Make sure the ID in the URL matches the ID in the request body
        if id != component.id {
            return error(
                "Component ID in URL does not match component ID in request body"
            );
        }

        // Check that the referenced resource exists
        if !Resource_table.hasKey(component.assetTag) {
            return error("Referenced asset does not exist");
        }

        Component_Table.put(component);

        return "Component updated successfully";
    }

    // DELETE: Remove a component using its ID
    resource function delete component/[string id]() returns string|error {

        if !Component_Table.hasKey(id) {
            return error("Component not found");
        }

        var _ = Component_Table.remove(id);

        return "Component deleted successfully";
    }


    // =========================================================
    // MAINTENANCE & OVERDUE CHECK
    // =========================================================

    // Identify maintenance entries where the due date has passed
    resource function get due_date_passed() returns ScheduleEntry[]|error {

        time:Utc currentTime = time:utcNow();
        time:Civil currentCivil = time:utcToCivil(currentTime);

        string today = check time:civilToString(currentCivil);

        ScheduleEntry[] overdueEntries =
            from var entry in ScheduleEntry_Table
            where entry.maintenanceType == "MAINTENANCE"
                && entry.duedate < today
            select entry;

        if overdueEntries.length() == 0 {
            return error(
                "No maintenance entries found with due date passed"
            );
        }

        return overdueEntries;
    }


    // =========================================================
    // WORK ORDER CRUD OPERATIONS
    // =========================================================

    // CREATE: Add a new work order
    resource function post work_order(WorkOrder workorder) returns string|error {

        // Check that the referenced resource exists
        if !Resource_table.hasKey(workorder.assetTag) {
            return error("Referenced asset does not exist");
        }

        // Check that the referenced component exists
        if workorder.componentID != ""
            && !Component_Table.hasKey(workorder.componentID) {
            return error("Referenced component does not exist");
        }

        // Check that the referenced schedule entry exists
        if workorder.entryID != ""
            && !ScheduleEntry_Table.hasKey(workorder.entryID) {
            return error("Referenced schedule entry does not exist");
        }

        // Check if work order already exists
        if WorkOrder_Table.hasKey(workorder.orderID) {
            return error("Work order already exists");
        }

        WorkOrder_Table.add(workorder);

        return "Work order added successfully";
    }

    // READ: Look up a work order
    resource function get work_order/[string orderID]() returns WorkOrder|error {

        WorkOrder? workorder = WorkOrder_Table[orderID];

        if workorder is WorkOrder {
            return workorder;
        }

        return error("Work order not found");
    }

    // UPDATE: Update an existing work order
    resource function put work_order/[string orderID](WorkOrder workorder)
            returns string|error {

        if !WorkOrder_Table.hasKey(orderID) {
            return error("Work order not found");
        }

        // Check that the referenced resource exists
        if !Resource_table.hasKey(workorder.assetTag) {
            return error("Referenced asset does not exist");
        }

        // Check that the referenced component exists
        if workorder.componentID != ""
            && !Component_Table.hasKey(workorder.componentID) {
            return error("Referenced component does not exist");
        }

        // Check that the referenced schedule entry exists
        if workorder.entryID != ""
            && !ScheduleEntry_Table.hasKey(workorder.entryID) {
            return error("Referenced schedule entry does not exist");
        }

        WorkOrder_Table.put(workorder);

        return "Work order updated successfully";
    }

    // DELETE: Remove a work order
    resource function delete work_order/[string orderID]() returns string|error {

        if !WorkOrder_Table.hasKey(orderID) {
            return error("Work order not found");
        }

        var _ = WorkOrder_Table.remove(orderID);

        return "Work order deleted successfully";
    }


    // =========================================================
    // SUB-TASK CRUD OPERATIONS
    // =========================================================

    // CREATE: Add a new sub-task
    resource function post add_subtask(subtask task) returns string|error {

        // Check that the referenced work order exists
        if !WorkOrder_Table.hasKey(task.workorderID) {
            return error("Referenced work order does not exist");
        }

        // Check if sub-task already exists
        if subtask_Table.hasKey(task.taskID) {
            return error("Sub-task already exists");
        }

        subtask_Table.add(task);

        return "Sub-task added successfully";
    }

    // READ: Look up a sub-task
    resource function get subtask/[string taskID]() returns subtask|error {

        subtask? task = subtask_Table[taskID];

        if task is subtask {
            return task;
        }

        return error("Sub-task not found");
    }

    // UPDATE: Update an existing sub-task
    resource function put subtask/[string taskID](subtask task)
            returns string|error {

        if !subtask_Table.hasKey(taskID) {
            return error("Sub-task not found");
        }

        // Check that the referenced work order exists
        if !WorkOrder_Table.hasKey(task.workorderID) {
            return error("Referenced work order does not exist");
        }

        subtask_Table.put(task);

        return "Sub-task updated successfully";
    }

    // DELETE: Remove a sub-task
    resource function delete subtask/[string taskID]() returns string|error {

        if !subtask_Table.hasKey(taskID) {
            return error("Sub-task not found");
        }

        var _ = subtask_Table.remove(taskID);

        return "Sub-task deleted successfully";
    }

    // Kennedy's Task: Manage Institutions (5 Marks)
    //Retrieve current listed institutions
    resource function get institutions() returns string[] {
        lock {
            return institution_listings;
        }
    }

    //Add a new institution name to system listings
    resource function post institutions(string institutionName) returns string|error {
        lock {
            if institutionName.trim() == "" {
                return error("Institution name cannot be blank");
            }
            if institution_listings.indexOf(institutionName) != () {
                return error("Institution already exists in system listings");
            }
            institution_listings.push(institutionName);
            return "Institution added successfully";
        }
    }

    //Remove an institution from system listings
    resource function delete institutions/[string name]() returns string|error {
        lock {
            int? index = institution_listings.indexOf(name);
            if index is int {
                _ = institution_listings.remove(index);
                return "Institution removed successfully";
            }
            return error("Institution not found in system listings");
        }
    }

}
