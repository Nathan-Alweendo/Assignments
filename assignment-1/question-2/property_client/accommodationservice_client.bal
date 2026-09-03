import ballerina/io;

AccommodationServiceClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    AddPropertyRequest add_propertyRequest = {host_id: "ballerina", name: "ballerina", location: "ballerina", property_type: "ballerina", price_per_night: 1, status: "AVAILABLE"};
    AddPropertyResponse add_propertyResponse = check ep->add_property(add_propertyRequest);
    io:println(add_propertyResponse);

    UpdatePropertyRequest update_propertyRequest = {property_id: "ballerina", host_id: "ballerina", price_per_night: 1, status: "AVAILABLE"};
    UpdatePropertyResponse update_propertyResponse = check ep->update_property(update_propertyRequest);
    io:println(update_propertyResponse);

    RemovePropertyRequest remove_propertyRequest = {property_id: "ballerina", host_id: "ballerina"};
    RemovePropertyResponse remove_propertyResponse = check ep->remove_property(remove_propertyRequest);
    io:println(remove_propertyResponse);

    SearchPropertyRequest search_propertyRequest = {property_id: "ballerina"};
    SearchPropertyResponse search_propertyResponse = check ep->search_property(search_propertyRequest);
    io:println(search_propertyResponse);

    BookPropertyRequest book_propertyRequest = {property_id: "ballerina", guest_id: "ballerina", check_in_date: "ballerina", check_out_date: "ballerina"};
    BookPropertyResponse book_propertyResponse = check ep->book_property(book_propertyRequest);
    io:println(book_propertyResponse);

    ConfirmBookingRequest confirm_bookingRequest = {booking_request_id: "ballerina"};
    ConfirmBookingResponse confirm_bookingResponse = check ep->confirm_booking(confirm_bookingRequest);
    io:println(confirm_bookingResponse);

    ListAvailablePropertiesRequest list_available_propertiesRequest = {location: "ballerina", min_price: 1, max_price: 1};
    stream<Property, error?> list_available_propertiesResponse = check ep->list_available_properties(list_available_propertiesRequest);
    check list_available_propertiesResponse.forEach(function(Property value) {
        io:println(value);
    });

    CreateUserRequest create_usersRequest = {name: "ballerina", email: "ballerina", role: "HOST"};
    Create_usersStreamingClient create_usersStreamingClient = check ep->create_users();
    check create_usersStreamingClient->sendCreateUserRequest(create_usersRequest);
    check create_usersStreamingClient->complete();
    CreateUsersSummary? create_usersResponse = check create_usersStreamingClient->receiveCreateUsersSummary();
    io:println(create_usersResponse);
}
