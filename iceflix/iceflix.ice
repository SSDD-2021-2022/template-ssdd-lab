//
// Final Version
//
[["ice-prefix"]] module IceFlix {

    ///////////// Errors /////////////

    // Raised if provided authentication token is wrong
    // Also raised if invalid user/password
    exception Unauthorized { };
    
    // Raised if provided media ID is not found
    exception WrongMediaId { string mediaId; };

    // Raised if some item is requested but currently unavailable
    exception TemporaryUnavailable { };

    // Raised if file transfer fails
    exception UploadError { };

    // Raised if service is unknown/unrecognized
    exception UnknownService { };

    ///////////// Media server related interfaces /////////////

    // Handle media stream
    interface StreamController {
        string getSDP(string userToken, int port) throws Unauthorized;
        string getSyncTopic();
        void refreshAuthentication(string userToken) throws Unauthorized;
        void stop();
    };

    // Event channel for StreamController() notifications to client
    interface StreamSync {
        // Emitted when StreamController() detects token/user revocation
        void requestAuthentication();
    };

    // List of bytes
    sequence<byte> Bytes;

    // Handle administrative media upload
    interface MediaUploader {
        Bytes receive(int size);
        void close();
    };

    // Handle media storage
    interface StreamProvider {
        StreamController* getStream(string mediaId, string userToken) throws Unauthorized, WrongMediaId;
        bool isAvailable(string mediaId);
        void reannounceMedia(string srvId) throws UnknownService;

        // Upload new media file and return media id
        string uploadMedia(string fileName, MediaUploader* uploader, string adminToken) throws Unauthorized, UploadError;
        void deleteMedia(string mediaId, string adminToken) throws Unauthorized, WrongMediaId;
    };

    // Event channel for StreamProvider() to MediaCatalog() notifications
    interface StreamAnnouncements {
        // Emitted when new media found/uploaded at the StreamProvider()
        void newMedia(string mediaId, string initialName, string srvId);
        // Emitted then media is removed from the StreamProvider()
        void removedMedia(string mediaId, string srvId);
    };

    ///////////// Custom Types /////////////

    // List of strings
    sequence<string> StringList;

    // Media info
    struct MediaInfo {
        string name;
        StringList tags;
     };

    // Media location
    struct Media {
        string mediaId;
        StreamProvider *provider;
        MediaInfo info;
    };

    dictionary<string, StringList> TagsPerUser;
    struct MediaDB {
        string mediaId;
        string name;
        TagsPerUser tagsPerUser;
    };

    sequence<MediaDB> MediaDBList;

    ///////////// Catalog server /////////////
   
    interface MediaCatalog {
        Media getTile(string mediaId, string userToken) throws WrongMediaId, TemporaryUnavailable, Unauthorized;
        StringList getTilesByName(string name, bool exact);

        StringList getTilesByTags(StringList tags, bool includeAllTags, string userToken) throws Unauthorized;
        void addTags(string mediaId, StringList tags, string userToken) throws Unauthorized, WrongMediaId;
        void removeTags(string mediaId, StringList tags, string userToken) throws Unauthorized, WrongMediaId;

        void renameTile(string mediaId, string name, string adminToken) throws Unauthorized, WrongMediaId;

        void updateDB(MediaDBList catalogDatabase, string srvId) throws UnknownService;
    };

    // Emitted when any MediaCatalog() updates its data store
    interface CatalogUpdates {
        void renameTile(string mediaId, string name, string srvId);
        void addTags(string mediaId, StringList tags, string user, string srvId);
        void removeTags(string mediaId, StringList tags, string user, string srvId);
    };

    ///////////// Auth server /////////////

    dictionary<string, string> UsersPasswords;
    dictionary<string, string> UsersToken;

    struct UsersDB {
        UsersPasswords userPasswords;
        UsersToken usersToken;
    };

    interface Authenticator {
        string refreshAuthorization(string user, string passwordHash) throws Unauthorized;
        bool isAuthorized(string userToken);
        string whois(string userToken) throws Unauthorized;

        void addUser(string user, string passwordHash, string adminToken) throws Unauthorized, TemporaryUnavailable;
        void removeUser(string user, string adminToken) throws Unauthorized, TemporaryUnavailable;

        void updateDB(UsersDB currentDatabase, string srvId) throws UnknownService;
    };

    // Event channel for Authenticator() for notifications to other Authenticator()
    interface UserUpdates {
        // Emitted when new user is added
        void newUser(string user, string passwordHash, string srvId);
        // Emitted when new token is created
        void newToken(string user, string userToken, string srvId);
    };

    // Event channel for Authenticator() for notifications to all microservices 
    interface Revocations {
        // Emitted when token expires
        void revokeToken(string userToken, string srvId);
        // Emitted when user is removed
        void revokeUser(string user, string srvId);
    };

    ///////////// Main server /////////////
    sequence<Authenticator*> AuthenticatorList;
    sequence<MediaCatalog*> MediaCatalogList;

    struct VolatileServices {
        AuthenticatorList authenticators;
        MediaCatalogList mediaCatalogs;
    };

    interface Main {
        Authenticator* getAuthenticator() throws TemporaryUnavailable;
        MediaCatalog* getCatalog() throws TemporaryUnavailable;

        void updateDB(VolatileServices currentServices, string srvId) throws UnknownService;

        bool isAdmin(string adminToken);
    };

    // Event channel for all microservices to all microservices
    interface ServiceAnnouncements {
        // Emitted on server starts, before it is ready to attend clients
        void newService(Object* service, string srvId);

        // Emmited when server starts to be available
        void announce(Object* service, string srvId);
    };
};
