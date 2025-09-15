# Authentication Security Problems

## Description

Storing __API Key__ and __Project ID__ as hard-coded values ​​in app is a serious security risk. If app is compromised (e.g. through decompilation or source code leakage), attackers can access this data and use it to gain unauthorized access to Firebase Realtime Database or other Firebase project services. This is especially dangerous because:
* The __API Key__ gives access to all __Firebase APIs__, including __Authentication__, __Realtime Database__, and other services, unless security rules are strict.
* The __Project ID__ reveals the structure of project and can be used to form API URLs (e.g. https://<project-id>-default-rtdb.firebaseio.com/).
* Since the methods for obtaining and renewing tokens (via __accounts:signUp__ and __securetoken.googleapis.com/v1/token__) are standard and documented, an attacker with an __API key__ can easily authenticate and access data if the database security rules are not strict enough.

## Guidelines for secure API key and Project ID management

To help minimize risks, can:
* Store the __API key__ and __Project ID__ outside of code in environment variables or configuration files aren't included in the repository or compiled into the app. These files can be encrypted. The __API key__ and __Project ID__ can also be encrypted.
* Server-side layer: Instead of directly accessing __Firebase__ from a client app can use an intermediary server handles requests and stores keys in a secure environment (or an environment that creates the illusion of security).

## Implementation

Current implementation uses the simplest method of protection: isolating some variables and storing them outside the application. This applies to the URI_AUTH, URI_DB, and URI_REFRESH variables. In the users.toit application, these variables will be initialized as follows:

```
URI_AUTH    := load_uri_auth
URI_DB      := load_uri_db
URI_REFRESH := load_uri_refresh
```

To create a variable storage environment, the __storage_init.toit__ app was written, which must be launched before the __users.toit__ application is launched. The storage environment can be cleared using the __storage_destroy.toit__ app.

The app also includes saving the current token and refresh token to flash storage to minimize the number of requests to the cloud.

