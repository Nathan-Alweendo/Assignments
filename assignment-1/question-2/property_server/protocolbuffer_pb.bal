import ballerina/grpc;
import ballerina/protobuf;

public const string PROTOCOLBUFFER_DESC = "0A1470726F746F636F6C6275666665722E70726F746F120D6163636F6D6D6F646174696F6E22F8010A0850726F7065727479121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07686F73745F69641802200128095206686F7374496412120A046E616D6518032001280952046E616D65121A0A086C6F636174696F6E18042001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180520012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180620012801520D70726963655065724E6967687412350A0673746174757318072001280E321D2E6163636F6D6D6F646174696F6E2E50726F7065727479537461747573520673746174757322760A045573657212170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D6512140A05656D61696C1803200128095205656D61696C122B0A04726F6C6518042001280E32172E6163636F6D6D6F646174696F6E2E55736572526F6C655204726F6C6522E1010A1241646450726F70657274795265717565737412170A07686F73745F69641801200128095206686F7374496412120A046E616D6518022001280952046E616D65121A0A086C6F636174696F6E18032001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180420012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180520012801520D70726963655065724E6967687412350A0673746174757318062001280E321D2E6163636F6D6D6F646174696F6E2E50726F7065727479537461747573520673746174757322500A1341646450726F7065727479526573706F6E7365121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412180A0773756363657373180220012808520773756363657373226A0A11437265617465557365725265717565737412120A046E616D6518012001280952046E616D6512140A05656D61696C1802200128095205656D61696C122B0A04726F6C6518032001280E32172E6163636F6D6D6F646174696F6E2E55736572526F6C655204726F6C6522540A12437265617465557365727353756D6D61727912230A0D746F74616C5F63726561746564180120012805520C746F74616C4372656174656412190A08757365725F69647318022003280952077573657249647322B0010A1555706461746550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07686F73745F69641802200128095206686F7374496412260A0F70726963655F7065725F6E69676874180320012801520D70726963655065724E6967687412350A0673746174757318042001280E321D2E6163636F6D6D6F646174696F6E2E50726F7065727479537461747573520673746174757322670A1655706461746550726F7065727479526573706F6E736512330A0870726F706572747918012001280B32172E6163636F6D6D6F646174696F6E2E50726F7065727479520870726F706572747912180A077375636365737318022001280852077375636365737322510A1552656D6F766550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07686F73745F69641802200128095206686F73744964227E0A1652656D6F766550726F7065727479526573706F6E736512180A0773756363657373180120012808520773756363657373124A0A1472656D61696E696E675F70726F7065727469657318022003280B32172E6163636F6D6D6F646174696F6E2E50726F7065727479521372656D61696E696E6750726F7065727469657322760A1E4C697374417661696C61626C6550726F7065727469657352657175657374121A0A086C6F636174696F6E18012001280952086C6F636174696F6E121B0A096D696E5F707269636518022001280152086D696E5072696365121B0A096D61785F707269636518032001280152086D6178507269636522380A1553656172636850726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F706572747949642288010A1653656172636850726F7065727479526573706F6E736512390A0673746174757318012001280E32212E6163636F6D6D6F646174696F6E2E417661696C6162696C697479537461747573520673746174757312330A0870726F706572747918022001280B32172E6163636F6D6D6F646174696F6E2E50726F7065727479520870726F7065727479229B010A13426F6F6B50726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412190A0867756573745F696418022001280952076775657374496412220A0D636865636B5F696E5F64617465180320012809520B636865636B496E4461746512240A0E636865636B5F6F75745F64617465180420012809520C636865636B4F75744461746522780A14426F6F6B50726F7065727479526573706F6E7365122C0A12626F6F6B696E675F726571756573745F69641801200128095210626F6F6B696E6752657175657374496412180A077375636365737318022001280852077375636365737312180A076D65737361676518032001280952076D65737361676522450A15436F6E6669726D426F6F6B696E6752657175657374122C0A12626F6F6B696E675F726571756573745F69641801200128095210626F6F6B696E67526571756573744964228A010A16436F6E6669726D426F6F6B696E67526573706F6E7365121D0A0A626F6F6B696E675F69641801200128095209626F6F6B696E67496412180A0773756363657373180220012808520773756363657373121D0A0A746F74616C5F636F73741803200128015209746F74616C436F737412180A076D65737361676518042001280952076D6573736167652A300A0E50726F7065727479537461747573120D0A09415641494C41424C451000120F0A0B554E415641494C41424C4510012A1F0A0855736572526F6C6512080A04484F5354100012090A05475545535410012A3F0A12417661696C6162696C69747953746174757312160A1250524F50455254595F415641494C41424C45100012110A0D4E4F545F415641494C41424C4510013285060A144163636F6D6D6F646174696F6E5365727669636512550A0C6164645F70726F706572747912212E6163636F6D6D6F646174696F6E2E41646450726F7065727479526571756573741A222E6163636F6D6D6F646174696F6E2E41646450726F7065727479526573706F6E736512550A0C6372656174655F757365727312202E6163636F6D6D6F646174696F6E2E43726561746555736572526571756573741A212E6163636F6D6D6F646174696F6E2E437265617465557365727353756D6D6172792801125E0A0F7570646174655F70726F706572747912242E6163636F6D6D6F646174696F6E2E55706461746550726F7065727479526571756573741A252E6163636F6D6D6F646174696F6E2E55706461746550726F7065727479526573706F6E7365125E0A0F72656D6F76655F70726F706572747912242E6163636F6D6D6F646174696F6E2E52656D6F766550726F7065727479526571756573741A252E6163636F6D6D6F646174696F6E2E52656D6F766550726F7065727479526573706F6E736512650A196C6973745F617661696C61626C655F70726F70657274696573122D2E6163636F6D6D6F646174696F6E2E4C697374417661696C61626C6550726F70657274696573526571756573741A172E6163636F6D6D6F646174696F6E2E50726F70657274793001125E0A0F7365617263685F70726F706572747912242E6163636F6D6D6F646174696F6E2E53656172636850726F7065727479526571756573741A252E6163636F6D6D6F646174696F6E2E53656172636850726F7065727479526573706F6E736512580A0D626F6F6B5F70726F706572747912222E6163636F6D6D6F646174696F6E2E426F6F6B50726F7065727479526571756573741A232E6163636F6D6D6F646174696F6E2E426F6F6B50726F7065727479526573706F6E7365125E0A0F636F6E6669726D5F626F6F6B696E6712242E6163636F6D6D6F646174696F6E2E436F6E6669726D426F6F6B696E67526571756573741A252E6163636F6D6D6F646174696F6E2E436F6E6669726D426F6F6B696E67526573706F6E7365620670726F746F33";

public isolated client class AccommodationServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, PROTOCOLBUFFER_DESC);
    }

    isolated remote function add_property(AddPropertyRequest|ContextAddPropertyRequest req) returns AddPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyRequest message;
        if req is ContextAddPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("accommodation.AccommodationService/add_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddPropertyResponse>result;
    }

    isolated remote function add_propertyContext(AddPropertyRequest|ContextAddPropertyRequest req) returns ContextAddPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyRequest message;
        if req is ContextAddPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("accommodation.AccommodationService/add_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function update_property(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns UpdatePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("accommodation.AccommodationService/update_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <UpdatePropertyResponse>result;
    }

    isolated remote function update_propertyContext(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns ContextUpdatePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("accommodation.AccommodationService/update_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <UpdatePropertyResponse>result, headers: respHeaders};
    }

    isolated remote function remove_property(RemovePropertyRequest|ContextRemovePropertyRequest req) returns RemovePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("accommodation.AccommodationService/remove_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <RemovePropertyResponse>result;
    }

    isolated remote function remove_propertyContext(RemovePropertyRequest|ContextRemovePropertyRequest req) returns ContextRemovePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("accommodation.AccommodationService/remove_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <RemovePropertyResponse>result, headers: respHeaders};
    }

    isolated remote function search_property(SearchPropertyRequest|ContextSearchPropertyRequest req) returns SearchPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("accommodation.AccommodationService/search_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchPropertyResponse>result;
    }

    isolated remote function search_propertyContext(SearchPropertyRequest|ContextSearchPropertyRequest req) returns ContextSearchPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("accommodation.AccommodationService/search_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function book_property(BookPropertyRequest|ContextBookPropertyRequest req) returns BookPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("accommodation.AccommodationService/book_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <BookPropertyResponse>result;
    }

    isolated remote function book_propertyContext(BookPropertyRequest|ContextBookPropertyRequest req) returns ContextBookPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("accommodation.AccommodationService/book_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <BookPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function confirm_booking(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ConfirmBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("accommodation.AccommodationService/confirm_booking", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ConfirmBookingResponse>result;
    }

    isolated remote function confirm_bookingContext(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ContextConfirmBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("accommodation.AccommodationService/confirm_booking", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ConfirmBookingResponse>result, headers: respHeaders};
    }

    isolated remote function create_users() returns Create_usersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("accommodation.AccommodationService/create_users");
        return new Create_usersStreamingClient(sClient);
    }

    isolated remote function list_available_properties(ListAvailablePropertiesRequest|ContextListAvailablePropertiesRequest req) returns stream<Property, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailablePropertiesRequest message;
        if req is ContextListAvailablePropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("accommodation.AccommodationService/list_available_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return new stream<Property, grpc:Error?>(outputStream);
    }

    isolated remote function list_available_propertiesContext(ListAvailablePropertiesRequest|ContextListAvailablePropertiesRequest req) returns ContextPropertyStream|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailablePropertiesRequest message;
        if req is ContextListAvailablePropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("accommodation.AccommodationService/list_available_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return {content: new stream<Property, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class Create_usersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendCreateUserRequest(CreateUserRequest message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextCreateUserRequest(ContextCreateUserRequest message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveCreateUsersSummary() returns CreateUsersSummary|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <CreateUsersSummary>payload;
        }
    }

    isolated remote function receiveContextCreateUsersSummary() returns ContextCreateUsersSummary|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <CreateUsersSummary>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class PropertyStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Property value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Property value;|} nextRecord = {value: <Property>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public isolated client class AccommodationServiceUpdatePropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendUpdatePropertyResponse(UpdatePropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextUpdatePropertyResponse(ContextUpdatePropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class AccommodationServiceRemovePropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendRemovePropertyResponse(RemovePropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextRemovePropertyResponse(ContextRemovePropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class AccommodationServicePropertyCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendProperty(Property response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextProperty(ContextProperty response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class AccommodationServiceBookPropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendBookPropertyResponse(BookPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextBookPropertyResponse(ContextBookPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class AccommodationServiceConfirmBookingResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendConfirmBookingResponse(ConfirmBookingResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextConfirmBookingResponse(ContextConfirmBookingResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class AccommodationServiceAddPropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendAddPropertyResponse(AddPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextAddPropertyResponse(ContextAddPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class AccommodationServiceSearchPropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendSearchPropertyResponse(SearchPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextSearchPropertyResponse(ContextSearchPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class AccommodationServiceCreateUsersSummaryCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCreateUsersSummary(CreateUsersSummary response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCreateUsersSummary(ContextCreateUsersSummary response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextCreateUserRequestStream record {|
    stream<CreateUserRequest, error?> content;
    map<string|string[]> headers;
|};

public type ContextPropertyStream record {|
    stream<Property, error?> content;
    map<string|string[]> headers;
|};

public type ContextUpdatePropertyResponse record {|
    UpdatePropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextBookPropertyRequest record {|
    BookPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextUpdatePropertyRequest record {|
    UpdatePropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchPropertyResponse record {|
    SearchPropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextConfirmBookingRequest record {|
    ConfirmBookingRequest content;
    map<string|string[]> headers;
|};

public type ContextConfirmBookingResponse record {|
    ConfirmBookingResponse content;
    map<string|string[]> headers;
|};

public type ContextListAvailablePropertiesRequest record {|
    ListAvailablePropertiesRequest content;
    map<string|string[]> headers;
|};

public type ContextAddPropertyResponse record {|
    AddPropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextRemovePropertyRequest record {|
    RemovePropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextAddPropertyRequest record {|
    AddPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextCreateUserRequest record {|
    CreateUserRequest content;
    map<string|string[]> headers;
|};

public type ContextRemovePropertyResponse record {|
    RemovePropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextSearchPropertyRequest record {|
    SearchPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextProperty record {|
    Property content;
    map<string|string[]> headers;
|};

public type ContextBookPropertyResponse record {|
    BookPropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersSummary record {|
    CreateUsersSummary content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type UpdatePropertyResponse record {|
    Property property = {};
    boolean success = false;
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type BookPropertyRequest record {|
    string property_id = "";
    string guest_id = "";
    string check_in_date = "";
    string check_out_date = "";
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type User record {|
    string user_id = "";
    string name = "";
    string email = "";
    UserRole role = HOST;
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type UpdatePropertyRequest record {|
    string property_id = "";
    string host_id = "";
    float price_per_night = 0.0;
    PropertyStatus status = AVAILABLE;
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type SearchPropertyResponse record {|
    AvailabilityStatus status = PROPERTY_AVAILABLE;
    Property property = {};
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type ConfirmBookingRequest record {|
    string booking_request_id = "";
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type ConfirmBookingResponse record {|
    string booking_id = "";
    boolean success = false;
    float total_cost = 0.0;
    string message = "";
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type ListAvailablePropertiesRequest record {|
    string location = "";
    float min_price = 0.0;
    float max_price = 0.0;
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type AddPropertyResponse record {|
    string property_id = "";
    boolean success = false;
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type RemovePropertyRequest record {|
    string property_id = "";
    string host_id = "";
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type AddPropertyRequest record {|
    string host_id = "";
    string name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    PropertyStatus status = AVAILABLE;
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type CreateUserRequest record {|
    string name = "";
    string email = "";
    UserRole role = HOST;
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type RemovePropertyResponse record {|
    boolean success = false;
    Property[] remaining_properties = [];
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type SearchPropertyRequest record {|
    string property_id = "";
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type Property record {|
    string property_id = "";
    string host_id = "";
    string name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    PropertyStatus status = AVAILABLE;
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type BookPropertyResponse record {|
    string booking_request_id = "";
    boolean success = false;
    string message = "";
|};

@protobuf:Descriptor {value: PROTOCOLBUFFER_DESC}
public type CreateUsersSummary record {|
    int total_created = 0;
    string[] user_ids = [];
|};

public enum PropertyStatus {
    AVAILABLE, UNAVAILABLE
}

public enum UserRole {
    HOST, GUEST
}

public enum AvailabilityStatus {
    PROPERTY_AVAILABLE, NOT_AVAILABLE
}
