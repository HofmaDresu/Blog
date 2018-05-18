---
layout: post
title:  "Todo in React Native"
date:   2018-05-17 13:00:00 -0400
tags: mobile react-native
---

In this post we're going to build a basic Todo application using React Native. React Native is a cross platform tool created by Facebook that lets you build iOS and Android applications. It provides a lot of code sharing between applications, both from your business logic and at least some of your UI code. This doesn't include platform specific controls, like Android's Floating Action Button, or native behaviors, like notifications, but it still allows a lot of re-use. Let's get started by seeing what React Native gives out-of-the-box with a Hello World application. Full source code for this application is available <a href="https://github.com/HofmaDresu/TodoMobile/tree/master/TodoReactNative" target="_blank" rel="noopener">on GitHub</a>

### Tools and Environment

The first things you need for developing with React Native are <a href="https://nodejs.org/en/download/" target="_blank" rel="noopener">Node.js</a>, npm, a text editor, and terminal access. If you plan to develop for iOS and use a simulator, you must develop on a Mac machine (at least at the time of this writing). Android can be developed in any environment.

React Native has a few different ways you can set up your environment depending on what level of development you're doing:
* If you're just looking for a quick prototype, you can use the command create-react-native-app to get up and runing without any additional setup. This will let you run your application on physical devices using the Expo tool. This has the advantage of letting you get up-and-running without installing any platform specific developement tools, but doesn't let you run on simulators or build native code into your project.
* If you know you don't need to build native code into your project but want to run on simultors as well as physical devices (highly recommended for production quality projects) you can still use create-react-native-app. However you'll also need to install XCode and the Android development libraries (most easily installed with <a href="https://developer.android.com/studio/" target="_blank" rel="noopener">Android Studio</a>).
* If you're building a more complex object that needs native code, you have 2 options: you can use create-react-native-app and the "eject" command, or you can use the react-native command. Both require XCode and the Android development libraries.

For more in-depth details, React Native provides good instructions for all options at its <a href="https://facebook.github.io/react-native/docs/getting-started.html" target="_blank" rel="noopener">getting started</a> page.

### Creating Hello World


### Displaying a list of Todo items

