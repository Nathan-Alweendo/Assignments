import ballerina/http;
import ballerina/time;

// =========================================================
// DATA MODELS & SCHEMAS
// =========================================================

public enum Status {
    AVAILABLE,
    LOANED_OUT,
    UNDER_MAINTENACE,
    DISPOSED
}

public type Resource record {|
    readonly string assetTag;
    string category;
    string description;
    string institution;
    string campus;
    string dateAquired;
|};

public type Component record {|
    readonly string id;
    string name;
    string description;
    string status;
    string assetTag;
    string date_acquired;
|};

public type ScheduleEntry record {|
    readonly string entryID;
    string assetTag;
    string maintenanceType;
    string startdate;
    string duedate;
    string status;
    string description;
|};

public type WorkOrder record {|
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

public type SubTask record {|
    readonly string taskID;
    string workorderID;
    string description;
    string status;
|};

public type Schedule record {|
    string scheduleId;
    string 'type;
    string dueDate;
    string description;
|};

public type Task record {|
    string taskId;
    string description;
|};

public type AssetWorkOrder record {|
    string orderId;
    string status;
    string description;
    Task[] tasks;
|};

public type AssetComponent record {|
    string compId;
    string name;
    string description;
    Schedule[] schedules?;
    AssetWorkOrder[] workOrders?;
|};

public type Asset record {|
    readonly string assetTag;
    string name;
    string description;
    string institution;
    string site;
    string status;
    string dateAcquired;
    AssetComponent[] components?;
    Schedule[] schedules?;
|};

public type AssetScheduleStatusResponse record {|
    string assetTag;
    string name;
    string currentStatus;
    Schedule[] topLevelSchedules;
    Schedule[] componentSchedules;
|};

// =========================================================
// ISOLATED IN-MEMORY STORAGE
// =========================================================

isolated table<SubTask> key(taskID) subtask_Table = table [];
isolated table<ScheduleEntry> key(entryID) ScheduleEntry_Table = table [];
isolated table<Component> key(id) Component_Table = table [];
isolated table<WorkOrder> key(orderID) WorkOrder_Table = table [];
isolated table<Resource> key(assetTag) Resource_table = table [];

isolated table<Asset> key(assetTag) assetTable = table [
    {
        assetTag: "NUST-LIB-3DP-001",
        name: "Pro-Series 3D Printer",
        description: "High-precision laboratory printer for simulation",
        institution: "Namibia University of Science and Technology",
        site: "Main Campus Innovation Lab",
        status: "AVAILABLE",
        dateAcquired: "2024-03-10",
        schedules: [
            {
                scheduleId: "SCH-001",
                'type: "BOOKING",
                dueDate: "2026-09-15",
                description: "Reserved for Mechanical Engineering Lab"
            }
        ],
        components: [
            {
                compId: "C101",
                name: "High-Torque Stepper Motor",
                description: "Main motor for X-axis movement",
                schedules: [
                    {
                        scheduleId: "SCH-882",
                        'type: "MAINTENANCE",
                        dueDate: "2026-09-01",
                        description: "Quarterly calibration and nozzle cleaning."
                    }
                ]
            }
        ]
    }
];

// =========================================================
// HTTP SERVICE
// =========================================================

service / on new http:Listener(9090) {

    // -----------------------------------------------------
    // RESOURCE ENDPOINTS
    // -----------------------------------------------------

    isolated resource function post assets(Resource newResource)
        returns string|error {

        Resource readonlyRes = newResource.cloneReadOnly();

        lock {
            if Resource_table.hasKey(readonlyRes.assetTag) {
                return error("Resource with asset tag already exists");
            }

            Resource_table.add(readonlyRes);
        }

        return "Resource added successfully";
    }

    isolated resource function get assets/[string assetTag]()
        returns Resource|error {

        lock {
            Resource? foundResource = Resource_table[assetTag];

            if foundResource is Resource {
                return foundResource.cloneReadOnly();
            }
        }

        return error("Resource not found");
    }

    isolated resource function put assets/[string assetTag](Resource updatedResource)
        returns string|error {

        if assetTag != updatedResource.assetTag {
            return error(
                "Asset tag in URL does not match asset tag in request body"
            );
        }

        Resource readonlyRes = updatedResource.cloneReadOnly();

        lock {
            if !Resource_table.hasKey(assetTag) {
                return error("Resource not found");
            }

            Resource_table.put(readonlyRes);
        }

        return "Resource updated successfully";
    }

    isolated resource function delete assets/[string assetTag]()
        returns string|error {

        lock {
            if !Resource_table.hasKey(assetTag) {
                return error("Resource not found");
            }

            _ = Resource_table.remove(assetTag);
        }

        return "Resource deleted successfully";
    }

    // -----------------------------------------------------
    // COMPONENT ENDPOINTS
    // -----------------------------------------------------

    isolated resource function post component(Component component)
        returns string|error {

        Component readonlyComp = component.cloneReadOnly();

        lock {
            if !Resource_table.hasKey(readonlyComp.assetTag) {
                return error("Referenced asset does not exist");
            }

            if Component_Table.hasKey(readonlyComp.id) {
                return error("Component already exists");
            }

            Component_Table.add(readonlyComp);
        }

        return "Component added successfully";
    }

    isolated resource function get component/[string id]()
        returns Component|error {

        lock {
            Component? comp = Component_Table[id];

            if comp is Component {
                return comp.cloneReadOnly();
            }
        }

        return error("Component not found");
    }

    isolated resource function put component/[string id](Component component)
        returns string|error {

        if id != component.id {
            return error(
                "Component ID in URL does not match component ID in request body"
            );
        }

        Component readonlyComp = component.cloneReadOnly();

        lock {
            if !Resource_table.hasKey(readonlyComp.assetTag) {
                return error("Referenced asset does not exist");
            }

            if !Component_Table.hasKey(id) {
                return error("Component not found");
            }

            Component_Table.put(readonlyComp);
        }

        return "Component updated successfully";
    }

    isolated resource function delete component/[string id]()
        returns string|error {

        lock {
            if !Component_Table.hasKey(id) {
                return error("Component not found");
            }

            _ = Component_Table.remove(id);
        }

        return "Component deleted successfully";
    }

    // -----------------------------------------------------
    // MAINTENANCE OVERDUE
    // -----------------------------------------------------

    isolated resource function get due_date_passed()
        returns ScheduleEntry[]|error {

        time:Utc currentTime = time:utcNow();
        time:Civil currentCivil = time:utcToCivil(currentTime);
        string today = check time:civilToString(currentCivil);

        lock {
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

            return overdueEntries.cloneReadOnly();
        }
    }

    // -----------------------------------------------------
    // WORK ORDER ENDPOINTS
    // -----------------------------------------------------

    isolated resource function post work_order(WorkOrder workorder)
        returns string|error {

        WorkOrder readonlyWorkOrder = workorder.cloneReadOnly();

        lock {
            if !Resource_table.hasKey(readonlyWorkOrder.assetTag) {
                return error("Referenced asset does not exist");
            }

            if readonlyWorkOrder.componentID != ""
                && !Component_Table.hasKey(readonlyWorkOrder.componentID) {
                return error("Referenced component does not exist");
            }

            if readonlyWorkOrder.entryID != ""
                && !ScheduleEntry_Table.hasKey(readonlyWorkOrder.entryID) {
                return error("Referenced schedule entry does not exist");
            }

            if WorkOrder_Table.hasKey(readonlyWorkOrder.orderID) {
                return error("Work order already exists");
            }

            WorkOrder_Table.add(readonlyWorkOrder);
        }

        return "Work order added successfully";
    }

    isolated resource function get work_order/[string orderID]()
        returns WorkOrder|error {

        lock {
            WorkOrder? workorder = WorkOrder_Table[orderID];

            if workorder is WorkOrder {
                return workorder.cloneReadOnly();
            }
        }

        return error("Work order not found");
    }

    isolated resource function put work_order/[string orderID](WorkOrder workorder)
        returns string|error {

        if orderID != workorder.orderID {
            return error(
                "Work order ID in URL does not match work order ID in request body"
            );
        }

        WorkOrder readonlyWorkOrder = workorder.cloneReadOnly();

        lock {
            if !WorkOrder_Table.hasKey(orderID) {
                return error("Work order not found");
            }

            if !Resource_table.hasKey(readonlyWorkOrder.assetTag) {
                return error("Referenced asset does not exist");
            }

            if readonlyWorkOrder.componentID != ""
                && !Component_Table.hasKey(readonlyWorkOrder.componentID) {
                return error("Referenced component does not exist");
            }

            if readonlyWorkOrder.entryID != ""
                && !ScheduleEntry_Table.hasKey(readonlyWorkOrder.entryID) {
                return error("Referenced schedule entry does not exist");
            }

            WorkOrder_Table.put(readonlyWorkOrder);
        }

        return "Work order updated successfully";
    }

    isolated resource function delete work_order/[string orderID]()
        returns string|error {

        lock {
            if !WorkOrder_Table.hasKey(orderID) {
                return error("Work order not found");
            }

            _ = WorkOrder_Table.remove(orderID);
        }

        return "Work order deleted successfully";
    }

    // -----------------------------------------------------
    // SUB-TASK ENDPOINTS
    // -----------------------------------------------------

    isolated resource function post add_subtask(SubTask task)
        returns string|error {

        SubTask readonlyTask = task.cloneReadOnly();

        lock {
            if !WorkOrder_Table.hasKey(readonlyTask.workorderID) {
                return error("Referenced work order does not exist");
            }

            if subtask_Table.hasKey(readonlyTask.taskID) {
                return error("Sub-task already exists");
            }

            subtask_Table.add(readonlyTask);
        }

        return "Sub-task added successfully";
    }

    isolated resource function get subtask/[string taskID]()
        returns SubTask|error {

        lock {
            SubTask? task = subtask_Table[taskID];

            if task is SubTask {
                return task.cloneReadOnly();
            }
        }

        return error("Sub-task not found");
    }

    isolated resource function put subtask/[string taskID](SubTask task)
        returns string|error {

        if taskID != task.taskID {
            return error(
                "Task ID in URL does not match task ID in request body"
            );
        }

        SubTask readonlyTask = task.cloneReadOnly();

        lock {
            if !subtask_Table.hasKey(taskID) {
                return error("Sub-task not found");
            }

            if !WorkOrder_Table.hasKey(readonlyTask.workorderID) {
                return error("Referenced work order does not exist");
            }

            subtask_Table.put(readonlyTask);
        }

        return "Sub-task updated successfully";
    }

    isolated resource function delete subtask/[string taskID]()
        returns string|error {

        lock {
            if !subtask_Table.hasKey(taskID) {
                return error("Sub-task not found");
            }

            _ = subtask_Table.remove(taskID);
        }

        return "Sub-task deleted successfully";
    }
}

// =========================================================
// ASSET SCHEDULE STATUS API
// =========================================================

isolated service /api/assets on new http:Listener(8080) {

    isolated resource function get status\-schedules/[string assetTag]()
        returns AssetScheduleStatusResponse|http:NotFound {

        lock {
            if !assetTable.hasKey(assetTag) {
                return http:NOT_FOUND;
            }

            Asset asset = assetTable.get(assetTag);

            Schedule[] mainSchedules = asset.schedules ?: [];
            Schedule[] compSchedules = [];

            AssetComponent[]? comps = asset.components;

            if comps is AssetComponent[] {
                foreach AssetComponent comp in comps {
                    Schedule[]? schedules = comp.schedules;

                    if schedules is Schedule[] {
                        foreach Schedule sch in schedules {
                            compSchedules.push(sch);
                        }
                    }
                }
            }

            return {
                assetTag: asset.assetTag,
                name: asset.name,
                currentStatus: asset.status,
                topLevelSchedules: mainSchedules.cloneReadOnly(),
                componentSchedules: compSchedules.cloneReadOnly()
            };
        }
    }
}