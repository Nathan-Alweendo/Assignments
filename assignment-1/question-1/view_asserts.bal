import ballerina/http;

// ==========================================
// 1. DATA MODELS & TYPES (Based on Payload)
// ==========================================

public enum Status {
   AVAILABLE,
   LOANED_OUT,
   UNDER_MAINTENANCE,
   DISPOSED
}

public type SubTask record {|
   string taskId;
   string description;
|};

public type WorkOrder record {|
   string orderId;
   string status;
   string description;
   SubTask[] tasks = [];
|};

public type Schedule record {|
   string scheduleId;
   string 'type;
   string dueDate;
   string description;
   WorkOrder[] workOrders = [];
|};

public type Component record {|
   string compId;
   string name;
   string description;
   Schedule[] schedules = [];
|};

public type Resource record {|
   readonly string assetTag;
   string name;
   string description;
   string institution;
   string site; 
   string category;
   Status status;
   string dateAcquired;
   Component[] components = [];
|};

// ==========================================
// 2. DATABASE INTEGRATION (In-Memory Table)
// ==========================================

table<Resource> key(assetTag) Resource_Table = table [
   {
 assetTag: "NUST-LIB-3DP-001",
 name: "Pro-Series 3D Printer",
 description: "High-precision laboratory printer for simulation.",
 institution: "Namibia University of Science and Technology",
 site: "Main Campus",
 category: "Electronics",
 status: AVAILABLE,
 dateAcquired: "2024-03-10",
 components: []
   },
   {
 assetTag: "UNAM-LIB-LAP-002",
 name: "Dell Latitude Laptop",
 description: "Student loaner laptop.",
 institution: "University of Namibia",
 site: "Main Campus",
 category: "Laptops",
 status: AVAILABLE,
 dateAcquired: "2023-01-15",
 components: []
   }
];

// ==========================================
// 3. RESTFUL API SERVICE IMPLEMENTATION
// ==========================================

service /api on new http:Listener(8080) {

   // --- TASK 1: View all assets - retrieve the full list  ---
   // Endpoint: GET http://localhost:8080/api/assets
   resource function get assets() returns Resource[] {
 return Resource_Table.toArray();
   
}
   // --- TASK 2: View assets by institution and site - filter by category  ---
   // Endpoint: GET http://localhost:8080/api/assets/[institution]/[site]?category=Electronics


    resource function get assets/[string institution]/[string site](string? category)
            returns Resource[] {
        return from var res in Resource_Table
         
            where res.institution == institution
                && res.site == site
                && (category == () || res.category == category)
            select res;
    }
}