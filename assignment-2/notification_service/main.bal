import ballerinax/kafka;
import ballerina/io;

listener kafka:Listener notificationListener = new (kafka:DEFAULT_URL, {
    groupId: "notification-service-group",
    topics: ["orders.created", "payments.completed", "payments.failed",
        "delivery.assigned", "delivery.completed"]
});

service on notificationListener {

    remote function onConsumerRecord(kafka:BytesConsumerRecord[] records) returns error? {
        foreach kafka:BytesConsumerRecord event in records {
            io:println("========================================");
            io:println("        KAFKA EVENT RECEIVED");
            io:println("========================================");
            io:println("Message received from Kafka");
            io:println("========================================");
        }
    }
}

public function main() {
    io:println("Notification Service started.");
    io:println("Waiting for Kafka events...");
}