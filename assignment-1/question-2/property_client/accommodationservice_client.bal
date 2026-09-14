import ballerina/io;

AccommodationServiceClient ep = check new ("http://localhost:9090");

function listAvailableProperties(string location, float min_price, float max_price) returns error? {
    ListAvailablePropertiesRequest listReq = {location: location, min_price: min_price, max_price: max_price};
    stream<Property, error?> propertiesStream = check ep->list_available_properties(listReq);
    check propertiesStream.forEach(function(Property p) {
        io:println(string `ID: ${p.property_id} | ${p.name} | ${p.location} | ${p.property_type} | $${p.price_per_night}/night | ${p.status}`);
    });
}

public function main() returns error? {
    map<string> emailToUserId = {};
    map<UserRole> emailToUserRole = {};

    string property_id="";
    string host_id="";
    string name="";
    string location="";
    string property_type="";
    float price_per_night=0;
    PropertyStatus propertyStatus=AVAILABLE;
    string email="";
    UserRole role=GUEST;
    string guest_id="";
    string check_in_date="";
    string check_out_date="";
    string booking_request_id="";
    string lastCreatedUserID="";

    boolean running=false;
    while running!=true{
        io:println("1.Create Users");
        io:println("2.Add Property");
        io:println("3.Update Property");
        io:println("4.Remove Property");
        io:println("5.List Available Property");
        io:println("6.Search Property");
        io:println("7.Book Property");
        io:println("8.Confirm Booking");
        io:println("9.Exit");

        io:print("Enter choice:");
        string user_choices=io:readln();

        int user_choice=check int:fromString(user_choices);

        match user_choice{
            1=>{
                io:println("User Creation");
                Create_usersStreamingClient create_usersStreamingClient = check ep->create_users();

                string[] sentEmails = [];

                boolean addingUsers = true;
                while addingUsers {
                    io:print("Enter name:");
                    name=io:readln();
                    io:print("Enter email:");
                    email=io:readln();

                    boolean roleSet=false;
                    while roleSet!=true{
                        io:print("Enter Role (Guest or Host):");
                        string roles=io:readln();
                        if roles.equalsIgnoreCaseAscii("Guest"){
                            role=GUEST;
                            roleSet=true;
                        }
                        else if roles.equalsIgnoreCaseAscii("Host") {
                            role=HOST;
                            roleSet=true;
                        }else{
                            io:println("Invalid input. Please type 'Guest' or 'Host'.");
                        }
                    }

                    CreateUserRequest create_usersRequest = {name: name, email: email, role: role};
                    check create_usersStreamingClient->sendCreateUserRequest(create_usersRequest);

                    sentEmails.push(email);
                    emailToUserRole[email] = role;

                    io:print("Add another user? (y/n): ");
                    string more = io:readln();
                    addingUsers = more.equalsIgnoreCaseAscii("y");
                }

                check create_usersStreamingClient->complete();
                CreateUsersSummary? create_usersResponse = check create_usersStreamingClient->receiveCreateUsersSummary();

                if create_usersResponse is CreateUsersSummary{
                    io:println("Users successfully created");
                    int i = 0;
                    foreach string id in create_usersResponse.user_ids{
                        if i < sentEmails.length() {
                            string sentEmail = sentEmails[i];
                            emailToUserId[sentEmail] = id;
                            lastCreatedUserID = id;
                            io:println(sentEmail + " -> Generated User ID: " + id);
                        }
                        i += 1;
                    }
                }
            }

            2=>{
                io:print("Enter your email: ");
                string hostEmail = io:readln();

                string? foundHostId = emailToUserId[hostEmail];
                UserRole? hostRole = emailToUserRole[hostEmail];

                if foundHostId is () || hostRole is () {
                    io:println("No user found with that email. Please register first (Option 1).");
                } else if hostRole != HOST {
                    io:println("This email belongs to a Guest, not a Host. Only Hosts can add properties.");
                } else {
                    host_id = foundHostId;

                    io:println("Enter property details");
                    io:print("Enter property name:");
                    name=io:readln();
                    io:print("Enter location:");
                    location=io:readln();
                    io:print("Enter property type:");
                    property_type=io:readln();
                    io:print("Enter price per night:");
                    string price_per_nights=io:readln();
                    price_per_night=check float:fromString(price_per_nights);

                    boolean statusSet=false;
                    while statusSet!=true{
                        io:print("Enter property status (Available or Unavailable):");
                        string property_statuss=io:readln();
                        if property_statuss.equalsIgnoreCaseAscii("Available"){
                            propertyStatus=AVAILABLE;
                            statusSet=true;
                        }
                        else if property_statuss.equalsIgnoreCaseAscii("Unavailable"){
                            propertyStatus=UNAVAILABLE;
                            statusSet=true;
                        }
                        else{
                            io:println("Invalid input. Please type 'Available' or 'Unavailable'.");
                        }
                    }

                    AddPropertyRequest add_propertyRequest = {host_id: host_id, name: name, location: location, property_type: property_type, price_per_night: price_per_night, status: propertyStatus};
                    AddPropertyResponse add_propertyResponse = check ep->add_property(add_propertyRequest);
                    io:println(add_propertyResponse);
                }
            }

            3=>{
                io:print("Enter your email: ");
                string hostEmail = io:readln();

                string? foundHostId = emailToUserId[hostEmail];
                UserRole? hostRole = emailToUserRole[hostEmail];

                if foundHostId is () || hostRole is () {
                    io:println("No user found with that email. Please register first (Option 1).");
                } else if hostRole != HOST {
                    io:println("This email belongs to a Guest, not a Host. Only Hosts can update properties.");
                } else {
                    host_id = foundHostId;

                    io:print("Enter property id to update:");
                    property_id=io:readln();

                    io:print("Enter new price:");
                    string price_per_nights=io:readln();
                    price_per_night=check float:fromString(price_per_nights);

                    boolean statusSet=false;
                    while statusSet!=true{
                        io:print("Enter new status of property (Available or Unavailable):");
                        string statuss=io:readln();
                        if statuss.equalsIgnoreCaseAscii("Available"){
                            propertyStatus=AVAILABLE;
                            statusSet=true;
                        }
                        else if statuss.equalsIgnoreCaseAscii("Unavailable"){
                            propertyStatus=UNAVAILABLE;
                            statusSet=true;
                        }
                        else{
                            io:println("Invalid input. Please type 'Available' or 'Unavailable'.");
                        }
                    }

                    UpdatePropertyRequest update_propertyRequest = {property_id: property_id, host_id: host_id, price_per_night: price_per_night, status: propertyStatus};
                    UpdatePropertyResponse update_propertyResponse = check ep->update_property(update_propertyRequest);
                    io:println(update_propertyResponse);
                }
            }

            4=>{
                io:print("Enter your email: ");
                string hostEmail = io:readln();

                string? foundHostId = emailToUserId[hostEmail];
                UserRole? hostRole = emailToUserRole[hostEmail];

                if foundHostId is () || hostRole is () {
                    io:println("No user found with that email. Please register first (Option 1).");
                } else if hostRole != HOST {
                    io:println("This email belongs to a Guest, not a Host. Only Hosts can remove properties.");
                } else {
                    host_id = foundHostId;

                    io:print("Enter property id to remove:");
                    property_id=io:readln();

                    RemovePropertyRequest remove_propertyRequest = {property_id: property_id, host_id: host_id};
                    RemovePropertyResponse remove_propertyResponse = check ep->remove_property(remove_propertyRequest);
                    io:println(remove_propertyResponse);
                }
            }

            5=>{
                io:print("Enter location:");
                location=io:readln();
                io:print("Enter minimum price:");
                string min_prices=io:readln();
                float min_price=check float:fromString(min_prices);
                io:print("Enter maximum price:");
                string max_prices=io:readln();
                float max_price=check float:fromString(max_prices);

                check listAvailableProperties(location, min_price, max_price);
            }

            6=>{
                io:println("Search property by id");
                io:print("Enter property id:");
                property_id=io:readln();
                SearchPropertyRequest search_propertyRequest = {property_id: property_id};
                SearchPropertyResponse search_propertyResponse = check ep->search_property(search_propertyRequest);
                io:println(search_propertyResponse);
            }

            7=>{
                io:print("Enter your email: ");
                string guestEmail = io:readln();

                string? foundGuestId = emailToUserId[guestEmail];
                UserRole? guestRole = emailToUserRole[guestEmail];

                if foundGuestId is () || guestRole is () {
                    io:println("No user found with that email. Please register first (Option 1).");
                } else if guestRole != GUEST {
                    io:println("This email belongs to a Host, not a Guest. Only Guests can book properties.");
                } else {
                    guest_id = foundGuestId;

                    io:println("Here are the currently available properties:");
                    io:print("Filter by location (leave blank for any): ");
                    string filterLocation = io:readln();
                    io:print("Minimum price (0 for no minimum): ");
                    float filterMin = check float:fromString(io:readln());
                    io:print("Maximum price (0 for no maximum): ");
                    float filterMax = check float:fromString(io:readln());

                    check listAvailableProperties(filterLocation, filterMin, filterMax);

                    io:print("Enter the property id you'd like to book: ");
                    property_id=io:readln();
                    io:print("Enter check in date (e.g. 19 September 2026):");
                    check_in_date=io:readln();
                    io:print("Enter check out date (e.g. 23 September 2026):");
                    check_out_date=io:readln();

                    BookPropertyRequest book_propertyRequest = {property_id: property_id, guest_id: guest_id, check_in_date: check_in_date, check_out_date: check_out_date};
                    BookPropertyResponse book_propertyResponse = check ep->book_property(book_propertyRequest);

                    booking_request_id = book_propertyResponse.booking_request_id;
                    io:println(book_propertyResponse);
                }
            }

            8=>{
                io:print("Confirm Booking (press 1 to confirm or 2 to go back):");
                string user_input=io:readln();
                int user_inp=check int:fromString(user_input);

                if(user_inp==1){
                    if booking_request_id == "" {
                        io:println("No pending booking request found. Please book a property first (Option 7).");
                    } else {
                        ConfirmBookingRequest confirm_bookingRequest = {booking_request_id: booking_request_id};
                        ConfirmBookingResponse confirm_bookingResponse = check ep->confirm_booking(confirm_bookingRequest);
                        io:println(confirm_bookingResponse);
                        booking_request_id = "";
                    }
                }
                else if (user_inp==2){
                    io:println("Returning to menu.");
                }
                else {
                    io:println("Invalid option.");
                }
            }

            9=>{
                io:println("Exiting Accommodation Service");
                running=true;
            }
            _=>{
                io:println("Invalid Option");
            }
        }
    }
}
