import ballerina/grpc;

type PropertyRecord record {|
    readonly string property_id;
    string property_name;
    string location;
    string property_type;
    float price_per_night;
    string status;
    string host_id;
|};

type BookingCartRecord record {|
    readonly string cart_id;
    string guest_id;
    string property_id;
    string check_in_date;
    string check_out_date;
|};

table<PropertyRecord> key(property_id) propertyTable = table [];
table<BookingCartRecord> key(cart_id) bookingCartTable = table [];

int propertyCounter = 100;
int bookingCounter = 500;

listener grpc:Listener ep = new (9090);

@grpc:ServiceDescriptor {descriptor: ROOT_DESCRIPTOR_ACCOMMODATION, name: "AccommodationService"}
service "AccommodationService" on ep {

    isolated remote function add_property(AddPropertyRequest req) returns AddPropertyResponse|error {
        lock {
            propertyCounter += 1;
            string newId = "PROP_" + propertyCounter.toString();

            PropertyRecord newProp = {
                property_id: newId,
                property_name: req.property_name,
                location: req.location,
                property_type: req.property_type,
                price_per_night: <float>req.price_per_night,
                status: req.status,
                host_id: req.host_id
            };

            propertyTable.add(newProp);

            return {
                property_id: newId,
                message: "Property created successfully"
            };
        }
    }

    isolated remote function create_users(stream<UserProfile, error?> clientStream) returns CreateUsersResponse|error {
        int count = 0;
        check clientStream.forEach(function(UserProfile user) {
            count += 1;
        });
        return {
            total_created: count,
            message: "Users registered successfully"
        };
    }

    isolated remote function update_property(UpdatePropertyRequest req) returns UpdatePropertyResponse|error {
        lock {
            if propertyTable.hasKey(req.property_id) {
                PropertyRecord existing = propertyTable.get(req.property_id);
                existing.price_per_night = <float>req.price_per_night;
                existing.status = req.status;
                propertyTable.put(existing);
                return {success: true, message: "Property updated successfully"};
            }
            return {success: false, message: "Property not found"};
        }
    }

    isolated remote function remove_property(RemovePropertyRequest req) returns stream<Property, error?>|error {
        lock {
            _ = propertyTable.remove(req.property_id);

            Property[] remainingProps = [];
            foreach var p in propertyTable {
                if p.location == req.region {
                    remainingProps.push({
                        property_id: p.property_id,
                        property_name: p.property_name,
                        location: p.location,
                        property_type: p.property_type,
                        price_per_night: <float>p.price_per_night,
                        status: p.status
                    });
                }
            }
            return remainingProps.toStream();
        }
    }

    isolated remote function list_available_properties(ListPropertiesRequest req) returns stream<Property, error?>|error {
        lock {
            Property[] matches = [];
            foreach var p in propertyTable {
                if p.status == "Available" &&
                   (req.location == "" || p.location == req.location) &&
                   p.price_per_night >= <float>req.min_price &&
                   (req.max_price == 0.0 || p.price_per_night <= <float>req.max_price) {
                    
                    matches.push({
                        property_id: p.property_id,
                        property_name: p.property_name,
                        location: p.location,
                        property_type: p.property_type,
                        price_per_night: <float>p.price_per_night,
                        status: p.status
                    });
                }
            }
            return matches.toStream();
        }
    }

    isolated remote function search_property(SearchPropertyRequest req) returns SearchPropertyResponse|error {
        lock {
            if propertyTable.hasKey(req.property_id) {
                PropertyRecord p = propertyTable.get(req.property_id);
                Property propDetails = {
                    property_id: p.property_id,
                    property_name: p.property_name,
                    location: p.location,
                    property_type: p.property_type,
                    price_per_night: <float>p.price_per_night,
                    status: p.status
                };
                return {
                    available: p.status == "Available",
                    property_details: propDetails,
                    status_message: "Property found"
                };
            }
            return {
                available: false,
                property_details: {},
                status_message: "Not Available"
            };
        }
    }

    isolated remote function book_property(BookPropertyRequest req) returns BookPropertyResponse|error {
        lock {
            bookingCounter += 1;
            string cartId = "CART_" + bookingCounter.toString();

            BookingCartRecord cartItem = {
                cart_id: cartId,
                guest_id: req.guest_id,
                property_id: req.property_id,
                check_in_date: req.check_in_date,
                check_out_date: req.check_out_date
            };

            bookingCartTable.add(cartItem);

            return {
                booking_cart_id: cartId,
                message: "Added to temporary booking cart"
            };
        }
    }

    isolated remote function confirm_booking(ConfirmBookingRequest req) returns ConfirmBookingResponse|error {
        lock {
            if bookingCartTable.hasKey(req.booking_cart_id) {
                BookingCartRecord cart = bookingCartTable.get(req.booking_cart_id);

                if propertyTable.hasKey(cart.property_id) {
                    PropertyRecord prop = propertyTable.get(cart.property_id);
                    
                    // Simple calculation example (assuming 3 nights stay)
                    float totalCost = prop.price_per_night * 3.0;

                    _ = bookingCartTable.remove(req.booking_cart_id);

                    return {
                        booking_id: "BOOK_" + req.booking_cart_id,
                        total_cost: <float>totalCost,
                        confirmation_status: "Confirmed"
                    };
                }
            }
            return {
                booking_id: "",
                total_cost: 0.0,
                confirmation_status: "Failed - Invalid booking request"
            };
        }
    }
}