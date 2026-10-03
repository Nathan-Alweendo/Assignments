import ballerina/http;

type OpeningHours record {| string open; string close; |};

type Restaurant record {|
    readonly string restaurantId;
    string name;
    string address;
    map<OpeningHours> openingHours;
|};

type MenuItem record {|
    string itemId;
    string restaurantId;
    string name;
    decimal price;
    int stock;
|};

table<Restaurant> key(restaurantId) restaurants = table [];

service /restaurants on new http:Listener(9091){
    resource function get .() returns Restaurant[] {
        return restaurants.toArray();
    }

    resource function post .(Restaurant restaurant) returns Restaurant|http:Conflict{
        if restaurants.hasKey(restaurant.restaurantId) {
            return http:CONFLICT;
        }
        restaurants.add(restaurant);
        return restaurant;
    }
}