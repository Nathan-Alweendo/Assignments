# Assignment 1
# Distributed Systems Project - Assignment 1

A robust, concurrent academic tracking and property management system implemented in Ballerina. The project is split into two primary architectures: a REST/HTTP API tracking platform for the Ministry of Higher Education, and an interactive gRPC Microservice platform for accommodation rentals.

---

## 👥 Project Contribution Ledger & Matrix

### Question 1: Ministry Resource & Maintenance Ledger (REST/HTTP)
* **Nathan** (@Nathan)
  * Implemented core resource scheduling system (add/remove routines).
  * Developed the automated backend background process for parsing and identifying past-due maintenance entries.
  * Built the complex asset component framework, sub-task tracking lifecycle endpoints, and general edge-case API mistake handlers.
* **Doctrine** (@doctorine206)
  * Implemented global inventory tracking modules.
  * Developed campus-specific collection filtering pipelines based on institution parameters.
* **Eugene** (@EugeneSondo)
  * Engineered the core device registration registry tracking capabilities (add, update, view, delete loops).
* **Terry** (@Nkululeko)
  * Implemented structural validation checks for checking physical item availability states and future booking schedules.
* **Kennedy** (@kenneydidit16)
  * Programmed the institution management controls for dynamically scaling location sites across the system network directory ledger.

### Question 2: Distributed Accommodation Platform (gRPC Microservice)
* **Nathan** (@Nathan)
  * Developed the highly concurrent, bulk client-side streaming user generation protocol (`create_users`).
* **Doctrine** (@doctorine206)
  * Engineered the remote structural ledger insertion and removal endpoints (`add_property` and `remove_property`).
* **Eugene** (@EugeneSondo)
  * Authored the remote simple RPC parameter modification and standard request allocation features (`update_property` and `book_property`).
* **Terry** (@Nkululeko)
  * Implemented the server-side streaming filter engine for matching active property search requests (`list_available_properties`).
* **Kennedy** (@kenneydidit16)
  * Programmed individual item lookups and thread-safe dynamic room confirmation date verification algorithms (`search_property` and `confirm_booking`).

---

## 🛠️ Architecture & Core Framework Capabilities

* **Isolation Control Scopes:** The backend environment ensures data thread safety across distributed parallel access pathways by using isolated structural tables (`table<T> key(K)`) protected by transaction `lock` blocks.
* **Dynamic UUID Mappings:** System actors and temporary request tokens are automatically tracked using cryptographically secure Type-4 UUID strings.
* **REST & gRPC Integration:** Seamless implementation of standard HTTP microservice routing alongside lightning-fast Protocol Buffer communication.

---

## 🚀 Execution & Quick Start Guide

### Question 1 (REST System)
```bash
# Terminal 1: Spin up the HTTP Backend Engine
cd assignment-1/question-1/server
bal run

# Terminal 2: Spin up the Ministry Client Menu Interface
cd assignment-1/question-1/client-side
bal run client.bal
```

### Question 2 (gRPC System)
```bash
# Terminal 1: Boot the Microservice Backend Server
cd assignment-1/question-2/property_server
bal run

# Terminal 2: Boot the Accommodation Client Menu Interface
cd assignment-1/question-2/property_client
bal run client.bal
```
