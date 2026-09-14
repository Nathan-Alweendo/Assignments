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

// Global integer counter used to generate simple incremental IDs
int booking_counter = 1000;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: PROTOCOLBUFFER_DESC}
service "AccommodationService" on ep {

    remote function add_property(AddPropertyRequest value) returns AddPropertyResponse|error {
    }

//Eugenes update_property code
   remote function update_property(UpdatePropertyRequest value) returns UpdatePropertyResponse|error {
    lock {
        TableProperty? existing = property_table[value.property_id];

        if existing is () {
            return {
                property: {
                    property_id: "",
                    host_id: "",
                    name: "",
                    location: "",
                    property_type: "",
                    price_per_night: 0.0,
                    status: "UNAVAILABLE"
                },
                success: false
            };
        }

        if existing.host_id != value.host_id {
            return {
                property: {
                    property_id: "",
                    host_id: "",
                    name: "",
                    location: "",
                    property_type: "",
                    price_per_night: 0.0,
                    status: "UNAVAILABLE"
                },
                success: false
            };
        }

        TableProperty updatedProperty = {
            property_id: existing.property_id,
            host_id: existing.host_id,
            name: existing.name,
            location: existing.location,
            property_type: existing.property_type,
            price_per_night: value.price_per_night,
            status: value.status
        };

        property_table.put(updatedProperty);

        return {
            property: updatedProperty,
            success: true
        };
    }
}

    remote function remove_property(RemovePropertyRequest value) returns RemovePropertyResponse|error {
    }

//Kennedy's confirm_booking code
remote function search_property(SearchPropertyRequest value) returns SearchPropertyResponse|error {
    lock {
        // Find property directly by its unique key
        TableProperty? prop = property_table[value.property_id];

        //Use exact case-sensitive string literals for gRPC enum comparison
        if prop is TableProperty && prop.status == "AVAILABLE" {
            
            Property matchingDetails = {
                property_id: prop.property_id,
                host_id: prop.host_id,
                name: prop.name,
                location: prop.location,
                property_type: prop.property_type,
                price_per_night: prop.price_per_night,
                status: prop.status
            };

            // 2. Fixed: Use string literal "AVAILABLE" for the AvailabilityStatus enum
            SearchPropertyResponse response = {
                status: <AvailabilityStatus>"AVAILABLE",
                property: matchingDetails
            };
            return response;
        } else {
            SearchPropertyResponse fallbackResponse = {
                status: NOT_AVAILABLE
            };
            return fallbackResponse;
        }
    }
}


//Eugenes book_property code
    remote function book_property(BookPropertyRequest value) returns BookPropertyResponse|error {
    lock {
        // Check whether the property exists
        TableProperty? property = property_table[value.property_id];

        if property is () {
            return {
                booking_request_id: "",
                success: false,
                message: "Property not found"
            };
        }

        // Check whether the guest exists
        TableUser? guest = user_table[value.guest_id];

        if guest is () {
            return {
                booking_request_id: "",
                success: false,
                message: "Guest not found"
            };
        }

        // Make sure the user is a guest
        if guest.role != "GUEST" {
            return {
                booking_request_id: "",
                success: false,
                message: "Only guests can book properties"
            };
        }

        // Check whether the property is available
        if property.status != "AVAILABLE" {
            return {
                booking_request_id: "",
                success: false,
                message: "Property is not available"
            };
        }

        // Check that dates were supplied
        if value.check_in_date == "" || value.check_out_date == "" {
            return {
                booking_request_id: "",
                success: false,
                message: "Check-in and check-out dates are required"
            };
        }

        // Check that check-out is after check-in
        if value.check_in_date >= value.check_out_date {
            return {
                booking_request_id: "",
                success: false,
                message: "Check-out date must be after check-in date"
            };
        }

        // Generate a booking request ID
        string bookingRequestId = uuid:createType4AsString();

        // Store the booking request temporarily
        pending_bookings[bookingRequestId] = value;

        return {
            booking_request_id: bookingRequestId,
            success: true,
            message: "Booking request created successfully"
        };
    }
}

//Kennedy's confirm_booking code
    remote function confirm_booking(ConfirmBookingRequest value) returns ConfirmBookingResponse|error {
        lock {
            //Fetch the temporary request from the map
            if !pending_bookings.hasKey(value.booking_request_id) {
                ConfirmBookingResponse errResponse = {booking_id: "", success: false, message: "REJECTED - Request not found", total_cost: 0.0};
                return errResponse;
            }
            BookPropertyRequest pending = pending_bookings.get(value.booking_request_id);

            //Simple Overlap Check Loop (Compares standard YYYY-MM-DD strings directly)
            foreach var existing in booking_table {
                if existing.property_id == pending.property_id {
                    // Formula check: (New_Start < Existing_End) AND (New_End > Existing_Start)
                    if pending.check_in_date < existing.check_out_date && pending.check_out_date > existing.check_in_date {
                        _ = pending_bookings.remove(value.booking_request_id); // Clear staging cart
                        ConfirmBookingResponse overlapResponse = {booking_id: "", success: false, message: "REJECTED - Dates overlap", total_cost: 0.0};
                        return overlapResponse;
                    }
                }
            }

            //Fetch property to get the base nightly rate and safely handle type guards
            TableProperty? prop = property_table[pending.property_id];
            if prop is () {
                return error("Property no longer exists");
            }

            //Calculate flat base cost from active property data records safely 
            float totalCostCalculated = <float>prop.price_per_night; 

            //Save the finalized booking into the table ledger
            booking_counter += 1;
            string officialBookingId = "BK-" + booking_counter.toString();

            Booking finalBooking = {
                booking_id: officialBookingId,
                booking_request_id: value.booking_request_id,
                property_id: pending.property_id,
                guest_id: pending.guest_id,
                check_in_date: pending.check_in_date,
                check_out_date: pending.check_out_date,
                total_cost: totalCostCalculated
            };
            booking_table.add(finalBooking);

            //Clear out the temporary cart item
            _ = pending_bookings.remove(value.booking_request_id);

            ConfirmBookingResponse validResponse = {
                booking_id: officialBookingId,
                success: true,
                message: "CONFIRMED",
                total_cost: totalCostCalculated
            };
            return validResponse;
        }
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
            Property[] filteredProperties = [];

        foreach var prop in TableProperty {
            // Check availability status enum from protobuf
            if prop.status != AVAILABLE {
                continue;
            }

            // Optional filter: Location (case-insensitive check or direct matching)
            if req.location != "" && prop.location.toLowerAscii() != req.location.toLowerAscii() {
                continue;
            }

            // Optional filter: Minimum Price
            if req.min_price > 0.0 && prop.price_per_night < req.min_price {
                continue;
            }

            // Optional filter: Maximum Price
            if req.max_price > 0.0 && prop.price_per_night > req.max_price {
                continue;
            }

            filteredProperties.push(prop);
        }

        // Return as a stream to fulfill the server-side streaming requirement
        return filteredProperties.toStream();
    }
}
