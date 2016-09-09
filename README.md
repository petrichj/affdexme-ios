![Affectiva Logo](http://developer.affectiva.com/images/logo.png)

###Copyright (c) 2016 Affectiva Inc. <br> See the file [license.txt](license.txt) for copying permission.

*****************************

**AffdexMe** is an app that demonstrates the use of the Affectiva iOS SDK.  It uses the camera on your iOS device to view, process and analyze live video of your face. Start the app and you will see your face on the screen and metrics describing your expressions.

This is an Xcode 7 project.

In order to use this project, you will need to:
- Obtain the Affectiva iOS SDK (visit http://www.affectiva.com/solutions/apis-sdks/)
- Have a valid CocoaPods installation on your machine
- Install the Affdex SDK on your machine using the Podfile:
```
pod install
```

- Open the Xcode workspace file AffdexMe-iOS.xcworkspace -- not the .xcodeproj file.
- Build the project for your simulator or device.  The simulator supports video
  file processing since it cannot access the Mac camera.  Build and run on a
  iPad or iPhone to capture your own video.
- Run the app and smile!

[![Build Status](https://travis-ci.org/Affectiva/affdexme-ios.svg?branch=master)](https://travis-ci.org/Affectiva/affdexme-ios)

***

This app uses some of the excellent [Emoji One emojis](http://emojione.com).

