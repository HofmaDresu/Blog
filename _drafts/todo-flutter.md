---
layout: post
title:  "Todo in Flutter"
date:   2018-09-16 12:00:00 -0400
tags: mobile flutter
---

Today we're going to create a Todo application using Flutter. Flutter is a cross platform framework created by Google that uses the <a href="https://www.dartlang.org/" target="_blank" rel="noopener">Dart language</a> to create Android and iOS applications with a lot of code sharing opportunities. Full source code for this application is available <a href="" target="_blank" rel="noopener">on GitHub</a>. 

This post was extra fun for me as I had not used either Flutter or Dart before working on this! I ended up going through Dart's <a href="https://www.dartlang.org/guides/language/language-tour" target="_blank" rel="noopener">Language Tour</a> and a free Flutter introduction on <a href="https://www.udacity.com/course/build-native-mobile-apps-with-flutter--ud905" target="_blank" rel="noopener">Udacity</a>. I highly recommend both if you want to start learning Flutter development. Because this is my first time using Flutter, I'm sure there are optimizations and useful tricks that I missed while creating this post. If you know of anything good that I missed, I'd love to hear about it on Twitter <a href="https://www.twitter.com/{{ site.twitter_username| cgi_escape | escape }}" target="_blank">@{{site.twitter_username}}</a>.

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

This initial app doesn't do much yet, but it gives us the structure we need and some examples of layout and actions we can use to create our Todo app!

### Displaying a list of Todo items

The first thing we want to do is create a TodoItem class that will hold our data. We only need 3 properties on this object to cover this app's functionality: a unique id, a title, and whether-or-not it has been completed. We'll also extend the Comparable class so we can easily sort our items later.  For this we'll create a new file in the 'lib' directory called "todoItem.dart" with the following content:

{% highlight dart %}
class TodoItem extends Comparable {
  final int id;
  final String name;
  bool isComplete;

  TodoItem({this.id, this.name, this.isComplete = false});

  @override
  int compareTo(other) {
    if (this.isComplete && !other.isComplete) {
      return 1;
    } else if (!this.isComplete && other.isComplete) {
      return -1;
    } else {
      return this.id.compareTo(other.id);
    }
  }
}
{% endhighlight %}

Next we'll create an initial list scree where we'll show the Todo items. All UI elements in Flutter are Widgets and extend either StatelessWidget or StatefulWidget. Since our list will include data we can manipulate (the isComplete property) we'll use Stateful for this screen. StatefulWidgets use 2 main parts: the Widget and a State object. The State object should be named _[WidgetName]State by convention. We'll first create the Widget by creating a "todoListScreen.dart" file in the lib directory and adding the following content.

{% highlight dart %}
import 'package:flutter/material.dart';
import 'todoItem.dart';

class TodoListScreen extends StatefulWidget {
  TodoListScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TodoListScreenState createState() => new _TodoListScreenState();
}
{% endhighlight %}

As you can see, there's not much to a basic stateful screen widget. The real work happens in the companion State class. We'll create this in the same file for simplicity's sake. _TodoListScreenState will handle creating and displaying a static list of Todo items. We'll also wire up a placeholder button and action that we'll later use for adding items.

{% highlight dart %}
class _TodoListScreenState extends State<TodoListScreen> {
  List<TodoItem> _todoItems = List();

  @override
  initState() {
    super.initState();
    // TODO use dynamic todo items
    _todoItems.add(TodoItem(id: 0, name: "Create First Todo", isComplete: true));
    _todoItems.add(TodoItem(id: 1, name: "Run a Marathon"));
    _todoItems.add(TodoItem(id: 2, name: "Create Todo_Flutter blog post"));
  }

  void _addTodoItem() {
    // TODO navigate to Create Todo Item Screen
  }

  Widget _createTodoItemWidget(TodoItem item) {
    // TODO customize todo item display to show completion status
    return ListTile(
      title: Text(item.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    _todoItems.sort();
    final todoItemWidgets = _todoItems.map(_createTodoItemWidget).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: todoItemWidgets,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodoItem,
        tooltip: 'Add Todo',
        child: Icon(Icons.add),
      ),
    );
  }
}
{% endhighlight %}

The last thing we need to do before running the app is update main.dart to use our new TodoListScreen. This mostly involves deleting the placeholder code and importing and using our new class.

{% highlight dart %}
import 'package:flutter/material.dart';
import 'todoListScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Flutter',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(title: 'Todo List'),
    );
  }
}
{% endhighlight %}

> I also removed usages of the 'new' keyword from this code. Older dart required the keyword but it became optional in dart 2. I've decided to omit it from this project as I think it makes reading the widget structure easier. I'm not sure what the best practice for it is.

With that done we can run our app and see a few Todo items.

<div class="os-screenshots">
    <label>Android</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-flutter/InitialListAndroid.webp">
        <img src="/assets/img/todo-flutter/InitialListAndroid.png" >
    </picture>
    <label>iOS</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-flutter/InitialListIOS.webp">
        <img src="/assets/img/todo-flutter/InitialListIOS.png" >
    </picture>
</div>

This is nice, but we probably want to show the user which items are completed. We'll do this by adding a simple checkbox on the right side of each item. Since we already separated TodoItem widget creation into a separate method, we only need to adjust _createTodoItemWidget in todoListScreen.dart.

{% highlight dart %}
Widget _createTodoItemWidget(TodoItem item) {
  return ListTile(
    title: Text(item.name),
    contentPadding: EdgeInsets.all(16.0),
    trailing: Checkbox(
      value: item.isComplete,
      onChanged: (value) => { }
    ),
  );
}
{% endhighlight %}

This will let our users see which items are complete and which still need to be done.

<div class="os-screenshots">
    <label>Android</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-flutter/ShowCompleteAndroid.webp">
        <img src="/assets/img/todo-flutter/ShowCompleteAndroid.png" >
    </picture>
    <label>iOS</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-flutter/ShowCompleteIOS.webp">
        <img src="/assets/img/todo-flutter/ShowCompleteIOS.png" >
    </picture>
</div>

### Completing, Uncompleting and Deleting Items
Now that we're showing our list of Todos, we should let the user interact with them. We'll start by adding the ability to complete, uncomplete, and delete items from the list. These will all be in-memory operations to start with. Later we'll add persistance to the app so these actions are saved.

The first thing we'll add is complete and uncomplete functionality. The user will trigger these changes by tapping on the checkbox we created in the last section. We need to add a new private method to _TodoListScreenState called _updateTodoCompleteStatus(TodoItem item, bool newStatus). There we'll copy our item list and update the target's completed status. Then we'll call setState to tell Flutter to update our state and refresh the UI. Last we'll update the checkbox in _createTodoItemWidget to call our new method.

> Note: Our new method is not particularly efficient. If we were building a production-quality app that could have a long list we would want to use a smarter algorithm

{% highlight dart %}
void _updateTodoCompleteStatus(TodoItem item, bool newStatus) {
  final tempTodoItems = _todoItems;
  tempTodoItems.firstWhere((i) => i.id ==item.id).isComplete = newStatus;
  setState(() { _todoItems = tempTodoItems; });
  // TODO: Persist change
}

...

Widget _createTodoItemWidget(TodoItem item) {
  return ListTile(
    title: Text(item.name),
    trailing: Checkbox(
      value: item.isComplete,
      onChanged: (value) => _updateTodoCompleteStatus(item, value),
    ),
  );
}
{% endhighlight %}

Now when we run the app we can see the list updating when todo items are completed and uncompleted.

<div class="os-screenshots">
    <label>Android</label>
    <picture>
        <img src="/assets/img/todo-flutter/CompleteUncompleteAndroid.gif" >
    </picture>
    <label>iOS</label>
    <picture>
        <img src="/assets/img/todo-flutter/CompleteUncompleteIOS.gif" >
    </picture>
</div>