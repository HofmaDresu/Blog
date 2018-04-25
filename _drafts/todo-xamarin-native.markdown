---
layout: post
title:  "Todo in Xamarin Native"
date:   2018-04-24 13:00:00 -0400
tags: mobile xamarin
excerpt_separator: "<!--more-->"
---

In this post we're going to create a todo application on both iOS and Android using Xamarin native. Xamarin is a cross platform development tool on the .NET stack that allows you to share application logic and other 'core' code (like data persistance, API access, etc) across target platforms. To get started we're going to create the default project files and see what Xamarin gives us out of the box. <!--more--> Full source code for this application is available <a href="https://github.com/HofmaDresu/TodoMobile/tree/master/TodoXamarinNative" target="_blank">on GitHub</a>.

> Note: All of my steps are using Visual Studio 2017 Community on Windows. Your mileage may vary if you work on a different edition of VS or on Visual Studio for Mac.

### Tools and Environment
> Note: If you've already read the previous post on creating the todo app with Xamarin Native, this section will be very familiar to you and you can skip ahead to <a href="#creating-hello-world">Creating Hello World</a>

We can develop for Xamarin Forms on either a PC or a Mac. On PC we would use Visual Studio (I'm using Visual Studio 2017 Community) and on Mac we would use Visual Studio for Mac, both available <a href="https://www.visualstudio.com/" target="_blank">here</a>. For Android development, the installers for Visual Studio will install all additional dependencies, like the Android SDK, emulators, Java, etc. iOS setup can be a little trickier: no matter which OS you develop on, you'll
need a Mac with XCode installed. If you're developing on a Windows machine, Visual Studio will connect to the Mac for iOS compilation. This is needed because Apple requires a Mac to compile iOS applications.

In addition to Visual Studio, I would also recommend installing Android Studio. This isn't required, especially for quick prototyping, but it has better tools for creating/managing emulators and for managing the SDK.

With all this installed, we can now start building our app!

<h3 id="creating-hello-world">Creating Hello World</h3>
The first thing we want to do is create our default iOS and Android projects. Unfortunately, at the time of this writing there is no built-in template to do this (there used to be, but it was removed at some point). Instead, we're going to create our 3 projects manually. First we'll create a core .NET Standard project by selecting "File->New Project" and in the dialog that appears select "Visual C# -> .NET Standard -> Class Library (.NET Standard)", naming the project TodoXamarinNative.Core and the solution TodoXamarinNative.

![Create Core Project]({{ "/assets/img/todo-xamarin-native/CreateCoreProject.PNG" }})

Next we'll create our Android project and set Core as a dependency. First we right click on the Solution and select "Add -> New Project...". In the dialog that appears we'll select "Visual C# -> Android -> Blank App (Android)" and name the project TodoXamarinNative.Android.

![Create Android Project]({{ "/assets/img/todo-xamarin-native/CreateAndroidProject.PNG" }})

To set up our dependency, right click on References under TodoXamarinNative.Android and select "Add Reference". It should open a dialog with the Projects tab open (if not, select the Projects tab). We'll select TodoXamarinNative.Core and click OK.

![Set Android Core Reference]({{ "/assets/img/todo-xamarin-native/ProjectReferenceAndroid.PNG" }})

Now we'll do the same thing for iOS. We open the Add New Project dialog again and select "Visual C# -> iOS -> Universal -> Single View App (iOS)" and name the project TodoXamarinNative.iOS. We choose "Single View App" here because it handles some of the required boilerplate to wire up the application. If we chose "Blank App" like we did for Android, we'd need to do that all ourselves.

![Create iOS Project]({{ "/assets/img/todo-xamarin-native/CreateIOSProject.PNG" }})

Finally we set up our reference to Core. This is done the same way for iOS as we did it for Android.

![Set iOS Core Reference]({{ "/assets/img/todo-xamarin-native/ProjectReferenceIOS.PNG" }})

This gives us a solution with 3 projects: Core, Android, and iOS. If we run it on both OSs, we'll see the default application.

<div class="os-screenshots">
    <label>Android</label>
    <img src="/assets/img/todo-xamarin-native/HelloWorldAndroid.png" />
    <label>iOS</label>
    <img src="/assets/img/todo-xamarin-native/HelloWorldIOS.png" >
</div>

We can see our app is up-and-running on both OSs, but it's not exactly what one would call "exciting" or "useful" yet. That's what we're going to do in the rest of this post!

### Creating the Data Layer
> Note: If you've already read the previous post on creating the todo app with Xamarin Native, this section will be very familiar to you and you can skip ahead to <a href="#">Displaying a list of Todo items</a>

First we're going to create our core data layer. This is where we'll handle CRUD operations for our todo list database. We want to create this in our Core project so we can share the code between iOS and Android with as little repetition as possible. On a more complicated app we may decide to create this layer later, but since this is very simple I want to get it out of the way so we can get into building the UI.