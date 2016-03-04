![Affectiva Logo](http://developer.affectiva.com/images/logo.png)

###Copyright (c) 2016 Affectiva Inc. <br> See the file [license.txt](license.txt) for copying permission.

*****************************

**AffdexMe** is an app that demonstrates the use of the Affectiva iOS SDK.  It uses the camera on your iOS device to view, process and analyze live video of your face. Start the app and you will see your face on the screen and metrics describing your expressions.

This is an Xcode 7 project.

In order to use this project, you will need to:
- Obtain the Affectiva iOS SDK (visit http://www.affectiva.com/solutions/apis-sdks/)
- Copy Affdex.framework into the frameworks folder.
- Add the contents of the license file near the top of the AffdexDemoViewController.m file. For example:

```
#define YOUR_AFFDEX_LICENSE_STRING_GOES_HERE @"{\"token\": \"01234567890abcdefghijklmnopqrstuvwxyz01234567890abcdefghijklmnop\", \"licensor\": \"Affectiva Inc.\", \"expires\": \"2016-11-20\", \"developerId\": \"developer@mycompany.com\", \"software\": \"Affdex SDK\"}"
```

- Build the project
- Run the app and smile!

[![Build Status](https://travis-ci.org/Affectiva/affdexme-ios.svg?branch=master)](https://travis-ci.org/Affectiva/affdexme-ios)

***

This app uses some of the excellent [Emoji One emojis](http://emojione.com).

