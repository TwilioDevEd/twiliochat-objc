# twiliochat-objc
[![Build Status](https://travis-ci.org/TwilioDevEd/twiliochat-objc.svg?branch=master)](https://travis-ci.org/TwilioDevEd/twiliochat-objc)

Objective-C implementation of Twilio Chat

### Running the Application
1. Clone the repository and `cd` into it.
1. Install the application's dependencies with [CocoaPods](https://cocoapods.org/)

   ```bash
   $ pod install
   ```
1. Open the project with `XCode`, but don't use `twiliochat.xcodeproj` file, for
   CocoaPods dependencies to work, you must use `twiliochat.xcworkspace`.
1. Now configure your [Parse](https://www.parse.com) keys so the application can
   manage sessions. Click [here](#create-a-parse-app) for more information on how
   to create a `Parse App`.
   The project includes a sample `Keys.example.plist` file, but you need to duplicate
   it, name it `Keys.plist` and within Xcode change the values to match your
   `Parse Keys`. You can copy the file outside of XCode, and can locate the file
   at:

   ```
   project_root/twiliochat/Keys.example.plist
   ```
   You can also do this in XCode. It doesn't matter how you do it, just make sure that
   the project holds a file named `Keys.plist` and holds your parse keys within it.
   Inside the project the file is located at:

   ```
   twiliochat -> Resources -> Keys.plist
   ```

1. Now the project is ready to run at least in the simulator. So, just click the play
   button in XCode and try our App!

### Create a Parse App
This objective-c application uses [Parse](https://www.parse.com) to manage sessions.

The first thing you need to do, is login into your parse account, if you don't have
one yet, register for one, it's free!

Once you are logged in, visit [your app dashboard](https://www.parse.com/apps/)
to create a new app. The next step is to get your parse `Application ID` and
`Client Key`, for this, visit the following url, replacing first your your app's
ID portion of it:

```
https://www.parse.com/apps/<your_app_id>/edit#keys
```

You will need both of these keys to configure the Twilio Chat Application.
