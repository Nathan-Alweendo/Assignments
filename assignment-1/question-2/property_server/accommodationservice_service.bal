import ballerina/grpc;
import ballerina/uuid;
//  Data Structures with Readonly Keys 

type TableProperty record {|
    readonly string property_id;
    *Property; 
|};

type TableUser record {|
    readonly string user_id;
    *User;
|};

type Booking record {|
    readonly string booking_id;
    string booking_request_id;
    string property_id;
    string guest_id;
    string check_in_date;
    string check_out_date;
    float total_cost;
|};

// In-Memory Data Tables
table<TableProperty> key(property_id) property_table = table [];
table<TableUser> key(user_id) user_table = table [];
table<Booking> key(booking_id) booking_table = table [];

// Helper table to track pending booking requests before confirmation
map<BookPropertyRequest> pending_bookings = {};

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: PROTOCOLBUFFER_DESC}
service "AccommodationService" on ep {

    remote function add_property(AddPropertyRequest value) returns AddPropertyResponse|error {
    }

    remote function update_property(UpdatePropertyRequest value) returns UpdatePropertyResponse|error {
        
    }

    remote function remove_property(RemovePropertyRequest value) returns RemovePropertyResponse|error {
    }

    remote function search_property(SearchPropertyRequest value) returns SearchPropertyResponse|error {
    }

    remote function book_property(BookPropertyRequest value) returns BookPropertyResponse|error {
    }

    remote function confirm_booking(ConfirmBookingRequest value) returns ConfirmBookingResponse|error {
    }

    remote function create_users(stream<CreateUserRequest, grpc:Error?> clientStream) returns CreateUsersSummary|error {
       string []createdIds=[];
        check from  CreateUserRequest req in clientStream 
        do {
            string newUserId=uuid:createType4AsString();
            TableUser newUser={
                user_id: newUserId,
                name:req.name,
                email: req.email,
                role: req.role
            };
            user_table.add(newUser);
            createdIds.push(newUserId);
        };
        CreateUsersSummary summary={
            total_created: createdIds.length(),
            user_ids: createdIds
        };
        return summary;
    }

    remote function list_available_properties(ListAvailablePropertiesRequest value) returns stream<Property, error?>|error {
    }
}
