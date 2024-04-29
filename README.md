# K-Logger
K-Logger is a light and independent logger with its own storage
- Wraps native os_log logger
- Works on a background thread
- Current thread logging
- High fault tolerance and test coverage
- Built-in limited store and logs rewriting logic
- Easy log method and access to log files

## Requirements
- iOS 14.0+
- macOS 11+

## Usage
K-Logger provides light methods for logging:


## Logging levels
K-Logger provides 5 default logging levels

- `info` for system messages and debug purposes
- `user` for mostly UI-related user actions
- `warning` for warning messages
- `error` for errors
- `critical` for critical cases

```js
Log.info("Info message example", data: ["data_example_key": true], module: "EXAMPLE MODULE")
// 2024-04-29 13:29:58.672103+0300 [Info] [EXAMPLE MODULE] Info message example ["data_example_key": true]

Log.user("User action message example")
// 2024-04-29 13:28:32.374259+0300 [Debug] [USER] User action message example

Log.warning("Warning message example", data: ["data_example_key": true], module: "EXAMPLE MODULE")
// 2024-04-29 13:30:57.213673+0300 [Critical] [EXAMPLE MODULE] Warning message example ["data_example_key": true]

Log.error("Error message example", data: ["data_example_key": true], module: nil)
// 2024-04-29 13:31:53.623552+0300 [Error] Error message example ["data_example_key": true]

Log.critical("Critical message example", data: ["data_example_key": true], module: "EXAMPLE MODULE")
// 2024-04-29 13:30:57.213673+0300 [Critical] [EXAMPLE MODULE] Critical message example ["data_example_key": true]
```

and 4 extra
- `request in` for requests input logging
- `request out` for requests output logging
- `analytics` for analytics logging
- `flow` navigation actions logging

```js
Log.requestOut("Request out message example")
// 2024-04-29 13:42:11.017197+0300 [REQUEST OUT] Request out message example

Log.requestIn("{exampleData: {requestInJsonKey: exampleValue}}}", operationName: "ExampleOperationName", statusCode: 200)
// 2024-04-29 13:40:03.343440+0300 [REQUEST IN] ExampleOperationName, 200
//  -->>  {exampleData: {requestInJsonKey: exampleValue}}}

Log.analytics("Analytics message example")
// 2024-04-29 13:19:48.285491+0300 [Debug] [ANALYTICS] Analytics message example
```

## Log utils
Users can get log files using the following methods:
```js
Log.utils.lastLogFile(completion: <(LogFile?) -> Void>)
Log.utils.logFiles(completion: <(LogFile?) -> Void>)

let lastLogFile = await Log.utils.lastLogFile()
let logFiles = await Log.utils.logFiles()
```

Get log files directory:
```js
let logFilesDirectoryPath = Log.utils.logsDirectoryPath
```
## Storage logic
K-Logger stores up to 10 log files of 2 MB each.
When the limits are reached, it will delete the oldest log file and create a new one

## Log file content example
```
#Encoding: UTF-8
#Version: 1.2.1
#Date: 2024-04-26 10:14 GMT / 2024-04-26 13:14 GMT+3
#Fields: timestamp level [thread, *tag] message *params

2024-04-26 10:14:54.562Z RO [com.apple.root.background-qos] GetReply
   URL: https://test.example.io/
   HEADERS: {"X-APOLLO-OPERATION-NAME":"GetReply","Content-Type":"application/json","apollographql-client-name":"com.example.com","apollographql-client-version":"3.0.30-489","X-APOLLO-OPERATION-TYPE":"query","Authorization":"Bearer TOKEN..."}
   PARAMETERS: {"fileId":"VG9waWNzUmVwbHk6Nm1TdTZaTWZYckxLb1lRdVRwS2ZyZA=="}
2024-04-26 10:14:54.550Z RI [com.apple.root.background-qos] GetReply, 200
  --->>  {"node":{"index":3,"id":"VG9waWNzUmVwbHk6Nm1TdTZaTWZYckxLb1lRdVR...
2024-04-26 10:14:57.424Z D [main, FLOW] <MainCoordinator> Returned to root VC. Closed view controllers: <StudioProjectViewController>
2024-04-26 10:14:57.525Z D [main, FLOW] <MainCoordinator> Top VC: <CustomTabBarController>
2024-04-26 10:14:58.116Z D [main, FLOW] <MainCoordinator> Top VC: <StudioProjectViewController>
```
