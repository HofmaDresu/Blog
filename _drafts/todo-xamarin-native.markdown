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






> Note: If you've already read the previous post on creating the todo app with Xamarin Native, this section will be very familiar to you and you can skip ahead to <a href="#">Displaying a list of Todo items</a>