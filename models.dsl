workspace {
    model {
        # People/Actors
        publicUser = person "Public User" "An anonymous user of the bookstore" "Customer"
        authorizedUser = person "Authorized User" "A registered user of the bookstore, with personal account" "Customer"
        internalUser = person "Internal User" "An internal user of the bookstore system" "Customer"

        # External Systems
        identityProvider = softwareSystem "Identity Provider System" "Handles authorization for users" "External System"
        publisherSystem = softwareSystem "Publisher System" "Provides published book details" "External System"
        shippingService = softwareSystem "Shipping Service" "3rd party service to handle the book delivery." "External System"

        # Bookstore System
        bookstoreSystem = softwareSystem "Bookstore System" "Allows users to view about book, and administrate the book details" "Target System" {
            # Level 2: Containers
            frontStoreApp = container "Front-store Application" "Provides all bookstore functionalities to public and authorized users" "JavaScript & ReactJS"
            backOfficeApp = container "Back-office Application" "Provides all bookstore administration functionalities to internal users" "JavaScript & ReactJS"
            searchWebApi = container "Search Web API" "Allows only authorized users searching books records via HTTPS API" "Go"
            # Level 3: Components
            adminWebApi = container "Admin Web API" "Allows only authorized users administering books details via HTTPS API" "Go" {
                bookService = component "Book Service" "Allows administrating book details" "Go"
                authService  = component "Authorizer" "Authorize users by using external Authorization System" "Go"
                bookEventPublisher = component "Book Events Publisher" "Publishes books-related events to Events Publisher" "Go"
            }
            searchDatabase = container "Search Database" "Stores searchable book information" "ElasticSearch" "Database"
            bookstoreDatabase = container "Bookstore Database" "Stores book details" "PostgreSQL" "Database"
            bookEventSystem = container "Book Event System" "Handle the book published event" "Apache Kafka 3.0"
            bookEventConsumer = container "Book Event Consumer" "Handle book update events" "Go"
            publisherRecurrentUpdater = container "Publisher Recurrent Updater" "Listens to external events from Publisher System and updates data using Admin Web API" "Go"
            publicWebApi = container "Public Web API" "Allows public users getting books information" "Go" {
                publicUser -> publicWebApi "Search books information using HTTPS"
                publicWebApi -> bookstoreDatabase "Read/Write data"
            }
        
        }

        # Relationship between People and Software Systems
        publicUser -> frontStoreApp "Uses"
        authorizedUser -> frontStoreApp "Uses"
        authorizedUser -> searchWebApi "Searches books" "Async Request"
        authorizedUser -> adminWebApi "Administrates book details" "Async Request"
        internalUser -> backOfficeApp "Administrates book details" "Async Request"

        # Relationship between Containers
        frontStoreApp -> publicWebApi "Interacts with"
        frontStoreApp -> searchWebApi "Interacts with"
        backOfficeApp -> adminWebApi "Interacts with"

        searchWebApi -> identityProvider "Authorized by"
        adminWebApi -> identityProvider "Uses for authorization"
        adminWebApi -> bookstoreDatabase "Read/Write data" "ODBC"
        bookService -> bookstoreDatabase "Read/Write data" "ODBC"
        authService -> identityProvider "Uses for authorization"
        bookEventPublisher -> bookEventSystem "Publish book update events"
        bookEventConsumer -> searchDatabase "Updates searchable data"
        searchWebApi -> searchDatabase "Searches book information"
        bookstoreSystem -> publisherSystem "Collects published book details"
        bookstoreSystem -> shippingService "Handles book delivery"
        bookEventSystem -> bookEventConsumer "Forwards events to"


        # Relationship between Containers and External System
        publisherSystem -> publisherRecurrentUpdater "Consume book publication update events" {
            tags "Async Request"
        }

        # Relationship between Components
        publisherRecurrentUpdater -> adminWebApi "Updates data using"
        authorizedUser -> bookService "Administering book details via" "JSON/HTTPS"
        internalUser -> authService "Authorizes using" "Sync Request"
        bookService -> authService "Uses"
        bookService -> bookEventPublisher "Uses"
    }

    views {
        # Context View
        systemContext bookstoreSystem {
            include *
            autolayout lr
        }
        # Container View
        container bookstoreSystem {
            include *
            autolayout lr
        }
        # Component View for Admin Web API
        component adminWebApi {
            include *
            autolayout lr
        }

        # Adding styles
        styles {
            element "Customer" {
                background #08427B
                color #ffffff
                fontSize 22
                shape Person
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            relationship "Relationship" {
                dashed false
            }
            relationship "Async Request" {
                dashed true
            }
            element "Database" {
                shape Cylinder
            }
        }
        theme default
    }
}
