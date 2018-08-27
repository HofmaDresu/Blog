---
layout: post
title:  "Todo in Flutter"
date:   2018-08-02 12:00:00 -0400
tags: mobile flutter
---

Today we're going to create a Todo application using Flutter. Flutter is a cross platform framework created by Google that uses the <a href="https://www.dartlang.org/" target="_blank" rel="noopener">Dart language</a> to create Android and iOS applications with a lot of code sharing opportunities. Full source code for this application is available <a href="" target="_blank" rel="noopener">on GitHub</a>. 

This post was extra fun for me as I had not used either Flutter or Dart before working on this! I ended up going through Dart's <a href="https://www.dartlang.org/guides/language/language-tour" target="_blank" rel="noopener">Language Tour</a> and a free Flutter introduction on <a href="https://www.udacity.com/course/build-native-mobile-apps-with-flutter--ud905" target="_blank" rel="noopener">Udacity</a>. I highly recommend both if you want to start learning Flutter development.

> Note: All of my steps are using Visual Code on Mac. Your mileage may vary if you use a different IDE or operating system.

# Tools and Environment
You can develop Flutter applications on Windows, Mac, and Linux. However, iOS development can only be done on Mac, which is why I'm using it for this application. You also have your choice on what IDE you want to use. Flutter's documentation currently provides setup steps for <a href="https://flutter.io/using-ide/" target="_blank" rel="noopener">Android Studio/IntelliJ</a> and <a href="https://flutter.io/using-ide-vscode/" target="_blank" rel="noopener">Visual Studio Code</a>. I have both installed: Android Studio for easy Android SDK and emulator support, and VS Code for development.

Depending on what OSs you're targeting, you'll also need to install the Android SDK for Android and XCode for iOS. Flutter provides setup directions <a href="https://flutter.io/get-started/install/" target="_blank" rel="noopener"> here</a>.

Once we have our development environment set up, we can begin coding our app!

