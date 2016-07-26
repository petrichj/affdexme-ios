![Affectiva Logo](http://developer.affectiva.com/images/logo.png)

###Copyright (c) 2016 Affectiva Inc. <br> See the file [license.txt](license.txt) for copying permission.

*****************************

**AffdexMe** is an app that demonstrates the use of the Affectiva iOS SDK.  It uses the camera on your iOS device to view, process and analyze live video of your face. Start the app and you will see your face on the screen and metrics describing your expressions.

[![Build Status](https://travis-ci.org/Affectiva/affdexme-ios.svg?branch=master)](https://travis-ci.org/Affectiva/affdexme-ios)


Requirements
------------
- Xcode 7
- Affdex SDK 3.1 (iOS)
- Affdex SDK license file


How to build the app
--------------------

- Download and install dependencies of CocoaPods

```
pod install
```
- Add contents of license file to ```AffdexDemoViewController.m```

```
#define YOUR_AFFDEX_LICENSE_STRING_GOES_HERE @"{\"token\": \"01234567890abcdefghijklmnopqrstuvwxyz01234567890abcdefghijklmnop\", \"licensor\": \"Affectiva Inc.\", \"expires\": \"2016-11-20\", \"developerId\": \"developer@mycompany.com\", \"software\": \"Affdex SDK\"}"
```

- Build the project
- Run the app and smile!

***

This app uses some of the excellent [Emoji One emojis](http://emojione.com).
