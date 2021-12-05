//
// L1 Version
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

    // Raised if file transfer fail
    exception UploadError { };

    // Raised if service is unrecognized
    exception UnknownService { };

    ///////////// Media server related interfaces /////////////

    // Handle media stream
    interface StreamController {
        string getSDP(string userToken, int port) throws Unauthorized;
        void stop();
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

        // Upload new media file and return media id
        string uploadMedia(string fileName, MediaUploader* uploader, string adminToken) throws Unauthorized, UploadError;
        void deleteMedia(string mediaId, string adminToken) throws Unauthorized, WrongMediaId;
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
   
    ///////////// Catalog server /////////////
   
    interface MediaCatalog {
        Media getTile(string mediaId) throws WrongMediaId, TemporaryUnavailable;
        StringList getTilesByName(string name, bool exact);

        StringList getTilesByTags(StringList tags, bool includeAllTags, string userToken) throws Unauthorized;
        void addTags(string mediaId, StringList tags, string userToken) throws Unauthorized, WrongMediaId;
        void removeTags(string mediaId, StringList tags, string userToken) throws Unauthorized, WrongMediaId;

        void renameTile(string mediaId, string name, string adminToken) throws Unauthorized, WrongMediaId;

        void updateMedia(string mediaId, string initialName, StreamProvider* provider);
    };

    ///////////// Auth server /////////////

    interface Authenticator {
        string refreshAuthorization(string user, string passwordHash) throws Unauthorized;
        bool isAuthorized(string userToken);
        string whois(string userToken) throws Unauthorized;

        void addUser(string user, string passwordHash, string adminToken) throws Unauthorized;
        void removeUser(string user, string adminToken) throws Unauthorized;
    };

    ///////////// Main server /////////////

    interface Main {
        Authenticator* getAuthenticator() throws TemporaryUnavailable;
        MediaCatalog* getCatalog() throws TemporaryUnavailable;

        void register(Object* service) throws UnknownService;
        
        bool isAdmin(string adminToken);
    };
};
