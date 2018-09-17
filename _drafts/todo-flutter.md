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

> I recommend installing Android Studio no matter what IDE you use for day-to-day coding. As of this posting it has access to more useful tools (though the VSCode community is doing great job adapting them)

Depending on what OSs you're targeting, you'll also need to install the Android SDK for Android and XCode for iOS. Flutter provides setup directions <a href="https://flutter.io/get-started/install/" target="_blank" rel="noopener"> here</a>.

Once we have our development environment set up, we can begin coding our app!

### Creating Hello World

The first thing we'll do is create a default app and see what Flutter gives us out of the box on both OSs. To do this we'll use the VSCode command "Flutter: New Project". This will prompt us for a project name then set up a hello world type app for us to use as a starting point. When that's complete we'll run the app to see what it created. We can run the app on iOS Simulators, Android Emulators, or physical devices. For this post we'll be using an iPhone X Simulator and an Nexus 5X emulator.

There are a few commands useful for handling devices and running the project that we'll want to be aware of. The first one is "flutter emulators". This gives us a list of available simulators and emulators that we can use.

{% highlight cmd %}
Matts-MacBook-Pro:todo_flutter hofmadresu$ flutter emulators
10 available emulators:

Nexus_5X_API_23     • Nexus 5X      • Google • Nexus 5X API 23
Nexus_5X_API_24     • Nexus 5X      • Google • Nexus 5X API 24
Nexus_5X_API_25     • Nexus 5X      • Google • Nexus 5X API 25
Nexus_5X_API_26     • Nexus 5X      • Google • Nexus 5X API 26
Nexus_5_API_21      • Nexus 5       • Google • Nexus 5 API 21
Nexus_5_API_22      • Nexus 5       • Google • Nexus 5 API 22
Nexus_One_API_25    • Nexus One     • Google • Nexus One API 25
Pixel_2_API_P       • pixel_2       • Google • Pixel 2 API P
Slowpoke_API_25     • Nexus 5X      • Google • Slowpoke_API_25
apple_ios_simulator • iOS Simulator • Apple

To run an emulator, run 'flutter emulators --launch <emulator id>'.
To create a new emulator, run 'flutter emulators --create [--name xyz]'.

You can find more information on managing emulators at the links below:
  https://developer.android.com/studio/run/managing-avds
  https://developer.android.com/studio/command-line/avdmanager
{% endhighlight %}

Once we see the list, we'll use the launch tag to start our simulator and emulator.

{% highlight cmd %}
Matts-MacBook-Pro:todo_flutter hofmadresu$ flutter emulators --launch "Nexus 5X"
Matts-MacBook-Pro:todo_flutter hofmadresu$ flutter emulators --launch "iOS Simulator"
{% endhighlight %}

And finally we'll use "flutter run -d all" to build and launch our app. The "-d all" parameter tells flutter to deploy to all running devices at the same time so we can see Android and iOS simultaneously.

{% highlight cmd %}
Matts-MacBook-Pro:todo_flutter hofmadresu$ flutter run -d all
Using hardware rendering with device Android SDK built for x86 64. If you get graphics artifacts, consider enabling software rendering with "--enable-software-rendering".
Launching lib/main.dart on Android SDK built for x86 64 in debug mode...
Initializing gradle...                                       0.9s
Resolving dependencies...                                    6.9s
Running 'gradlew assembleDebug'...                           3.6s
Built build/app/outputs/apk/debug/app-debug.apk.
Launching lib/main.dart on iPhone X in debug mode...
Starting Xcode build...
 ├─Assembling Flutter resources...                    1.3s

 └─Compiling, linking and signing...                  1.9s

Xcode build done.                                            4.8s
Syncing files to device Android SDK built for x86 64...      5.1s
Syncing files to device iPhone X...                          4.1s

🔥  To hot reload changes while running, press "r". To hot restart (and rebuild state), press "R".
An Observatory debugger and profiler on Android SDK built for x86 64 is available at: http://127.0.0.1:50123/
An Observatory debugger and profiler on iPhone X is available at: http://127.0.0.1:50136/
For a more detailed help message, press "h". To quit, press "q".
{% endhighlight %}

Once that's up and running we can see our app running on both OSs.

<div class="os-screenshots">
    <label>Android</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-flutter/HelloWorldAndroid.webp">
        <img src="/assets/img/todo-flutter/HelloWorldAndroid.png" >
    </picture>
    <label>iOS</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-flutter/HelloWorldIOS.webp">
        <img src="/assets/img/todo-flutter/HelloWorldIOS.png" >
    </picture>
</div>