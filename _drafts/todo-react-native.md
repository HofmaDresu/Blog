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

We're going to use the second option today so we don't have to rely on having physical devices but get the simple setup. I have node 8.11.2 and npm 6.0.1 installed and will be using the iPhone X simulator and a Nexus 5x API 26 emulator.  First we need to install create-react-native-app.

{% highlight bash %}
    npm install -g create-react-native-app
{% endhighlight %}

Then we'll open our terminal to the directory where we want to create our project and run the following commands to create and start our project.

{% highlight bash %}
    create-react-native-app TodoReactNative
    cd TodoReactNative
    npm start
{% endhighlight %}

This will start the application using Expo and give us the following options.

{% highlight bash %}
 › Press a to open Android device or emulator, or i to open iOS emulator.
 › Press s to send the app URL to your phone number or email address
 › Press q to display QR code.
 › Press r to restart packager, or R to restart packager and clear cache.
 › Press d to toggle development mode. (current mode: development)
{% endhighlight %}

Finally we'll run our application on the iOS simulator and Android emulator. Make sure to start your emulator through Android Studio (or whatever tool you're using) before following this step. In our terminal we'll type "i" and wait for it to launch then type "a".

On the Android emulator we'll see a request for permissions. Follow the instructions and hit 'back'.
> The Expo app crashed when I first ran this. If this happens to you, just hit 'a' again in your terminal to re-launch.

On the iOS emulator we'll see a "Welcome to Expo" screen. Click "Got it" to proceed to our app.

<div class="os-screenshots">
    <label>Android</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-react-native/HelloWorldAndroid.webp">
        <img src="/assets/img/todo-react-native/HelloWorldAndroid.png" >
    </picture>
    <label>iOS</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-react-native/HelloWorldIOS.webp">
        <img src="/assets/img/todo-react-native/HelloWorldIOS.png" >
    </picture>
</div>

Now that  we have see our hello world up and running on both OSs, it's time to begin building our app!

### Displaying a list of Todo items

The first thing we want to do is set up our main todo list

> If you're already familiar with the React ecosystem you probably know about libraries like Redux and the Flux archicture and wonder why we're not using those. Basically they're a big enough topic that it felt like adding that would be too much for a single post. If you don't know about those, don't worry about it :)