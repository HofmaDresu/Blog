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

> If you're already familiar with the React ecosystem you probably know about libraries like Redux and the Flux archicture and wonder why we're not using those. Basically they're a big enough topic that it felt like adding that would be too much for a single post. If you don't already know about those, don't worry about it :)

React, and by extension React Native, is interesting because it takes a very explicitely component-driven view for creating the UI. We want to think of each individual portion of our UI from the bottom up and decide what parts should be encapsulated into their own component. This, of course, can be refactored and adjusted as we go, but it's good to put some initial thought into it. For our initial todo list we're going to create 2 components: a TodoItemComponent, which handles displaying the individual item, and a TodoListComponent, which handles displaying a list of TodoItemComponent.

> Note: The naming convention we're using for our components is optional. On larger projects you may find it better to use a different convention or use folders to separate file types

The first thing we need to do is decide on what our todo data will look like. Since this is a simple app, we can get away with a very simple object that contains a key (unique id), title, and isCompleted. Let's create a starting list by opening App.js and adding the following code above the App class:

{% highlight javascript %}
...
const todoItems = [
  { key: '0', title: "Create first todo", isCompleted: true },
  { key: '1', title: "Climb a mountain", isCompleted: false },
  { key: '2', title: "Create React Native blog post", isCompleted: false },
 ];
...
{% endhighlight %}

Next we'll create our TodoItemComponent. React has two main ways we can create components: class and functional. Class components are used when you need to maintain non-persisted state (like text input) and functional components are used when that isn't needed (there's more nuance to this, but that's enough to get going). Since this will be a very simple component that just handles displaying data, we're going to use a functional component. We'll create a new file called TodoItemComponent.js and export a function that takes in our item's title and displays it with a bottom border.

{% highlight jsx %}
import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

export default function TodoItem({title, ...props}) {
  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <Text>{title}</Text>
      </View>
      <View style={styles.border} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    display: 'flex',
    flexDirection: 'column',
    height: 40,
    backgroundColor: '#fff',
  },
  content: {
    flexGrow: 1,
    justifyContent: 'center',
  },
  border: {
    height: 1,
    backgroundColor: '#aaa',
  },
});
{% endhighlight %}

> Note: React Native uses a JavaScript variant of CSS to handle styles. I'll try to keep the styles fairly simple, the most advanced will be flexbox, but a working knowledge of CSS is very useful when developing on React Native.

Now we need to create our list. This will be another simple component that just displays data, so we'll use a functional component again. We'll create a new file called TodoListComponent.js with the following code:

{% highlight jsx %}
import React from 'react';
import { StyleSheet, FlatList } from 'react-native';
import TodoItemComponent from './TodoItemComponent';

export default function TodoList({todoItems, ...props}) {
  return (
    <FlatList style={styles.container}
      data={todoItems}
      renderItem={({item, index, section}) => <TodoItemComponent {...item} />}
    />
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
});
{% endhighlight %}

This is structurally similiar to our TodoItemComponent with two differences I want to call out. First, we used a new component from ReactNative called FlatList. This handles displaying our list with a lot of added benefits over doing it ourselves, like scrolling and item virtualization (for memory optimization). Second we used our TodoItemComponent in this file, so we needed to import it at the top of this file.

The final thing we need to do is adjust our App.jsx file to display this list. We need to import TodoListComponent and change our render method to display our new content:

{% highlight jsx %}
...
import TodoList from './TodoListComponent';
...
  render() {
    return (
      <TodoList todoItems={todoItems} />
    );
  }
...
{% endhighlight %}

Now when we run our app we can see our todo items in a list!

<div class="os-screenshots">
    <label>Android</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-react-native/InitialListAndroid.webp">
        <img src="/assets/img/todo-react-native/InitialListAndroid.png" >
    </picture>
    <label>iOS</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-react-native/InitialListIOS.webp">
        <img src="/assets/img/todo-react-native/InitialListIOS.png" >
    </picture>
</div>

A clever observer may notice that our items are going under the action bar on both OSs. This is definitely not the desired behavior, so we'll take care of it before moving on. There are a couple ways to do this, but since we know we'll eventually want navigation we'll add the basic nav structure now and use the navigation bar to adjust our content's position.

We're going to use <a href="https://facebook.github.io/react-native/docs/navigation.html#react-navigation" target="_blank" rel="noopener">React Navigation</a> to handle our navigation. There are other options available, but this is powerful enough for our needs while staying easy to use. The first thing we need to do is install the react-navigation package

{% highlight bash %}
    npm install --save react-navigation
{% endhighlight %}

Next we're going need to create our home screen. This is going to be almost the same as our App.js file, so just rename that to TodoListScreen.js and change the class name to TodoListScreen. We'll also add a title to a new static object, navigationOptions, so our nav bar knows what to display:

{% highlight jsx %}
...
export default class TodoListScreen extends React.Component {
  static navigationOptions = {
      title: 'Todo List',
  };
...
{% endhighlight %}

Now create a new App.js. Here we'll create our initial navigation structure. Since we only have one screen, this will be very simple:

{% highlight jsx %}
import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import TodoListScreen from './TodoListScreen';
import { createStackNavigator } from 'react-navigation';

export default createStackNavigator({
  Home: TodoListScreen ,
});
{% endhighlight %}

And that's it! Now when we run our app it looks a little better:
<div class="os-screenshots">
    <label>Android</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-react-native/ListWithNavBarAndroid.webp">
        <img src="/assets/img/todo-react-native/ListWithNavBarAndroid.png" >
    </picture>
    <label>iOS</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-react-native/ListWithNavBarIOS.webp">
        <img src="/assets/img/todo-react-native/ListWithNavBarIOS.png" >
    </picture>
</div>

The last thing we want to do before moving on to actions is let the user know which items are active and which have been completed. We'll do this by splitting our list into sections, displaying active items first and completed items second. This is very easy to do from our current setup, and can be compeleted with only a few changes to TodoListComponent. We need to

1. Change our FlatList to a SectionList
2. Split our todoItems array into an array of sections
3. Tell the SectionList how to display our section headers

{% highlight jsx %}
import React from 'react';
import { StyleSheet, SectionList, Text } from 'react-native';
import TodoItemComponent from './TodoItemComponent';

export default function TodoList({todoItems, ...props}) {
  let activeItems = todoItems.filter(i => !i.isCompleted);
  let completedItems = todoItems.filter(i => i.isCompleted);
  let sections = [
    { title:"Active", data:activeItems },
    { title:"Completed", data:completedItems},
  ];

  return (
    <SectionList style={styles.container}
      sections={sections}
      renderItem={({item, index, section}) => <TodoItemComponent {...item} />}
      renderSectionHeader={({section: {title}}) => (
        <Text style={styles.sectionHeader}>{title}</Text>
      )}
    />
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  sectionHeader: {
    fontWeight: 'bold',
    backgroundColor: '#eee',
    paddingTop: 5,
    paddingBottom: 5,    
  },
});
{% endhighlight %}

Now when we run the app we see our items split apart based on their active vs completed status. 

<div class="os-screenshots">
    <label>Android</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-react-native/SectionedListAndroid.webp">
        <img src="/assets/img/todo-react-native/SectionedListAndroid.png" >
    </picture>
    <label>iOS</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-react-native/SectionedListIOS.webp">
        <img src="/assets/img/todo-react-native/SectionedListIOS.png" >
    </picture>
</div>

> The section headers follow platform norms when scrolling. If you add enough todo items, you'll notice that iOS uses sticky headers and Android scrolls the headers off the screen immediately.

Now we're ready to start adding user interactions!

### Completing, Uncompleting and Deleting Items

As much fun as it is to stare at a static list of Todos, our user probably wants to edit the list. We'll start by allowing them to complete, uncomplete, and delete items from the existing list.

The first thing we want to do is add something the user can interact with. SectionList doesn't natively give us a way to add context actions to our items, so we'll just add custom buttons.
> There are 3rd party libraries that handle this, but I want to keep outside dependencies to a minimum for this post

We need to create a new component for our interaction options. We're going to use React Native's TouchableHighlight to create button-like components that we can style to make the choices obvious for the user. Since these will only be used by our TodoItemComponent, we can add our code directly to TodoItemComponent.js.

{% highlight jsx %}
...
import { StyleSheet, Text, View, TouchableHighlight } from 'react-native';

function TodoItemActionButton({title, isDestructive, ...props}) {
  return (
    <TouchableHighlight style={ isDestructive ? styles.destructiveActionButton : styles.actionButton }>
      <Text style={styles.actionButtonText}>{title}</Text>
    </TouchableHighlight>
  );
}
...
const styles = StyleSheet.create({
  ...  
  actionButton: {
    backgroundColor: '#00f',
    display: 'flex',
    justifyContent:'center',
  },
  destructiveActionButton: {
    backgroundColor: '#f00',
    display: 'flex',
    justifyContent:'center',
  },
  actionButtonText: {
    color: '#fff',
    paddingLeft: 10,
    paddingRight: 10,
  },
});
{% endhighlight %}

Now we want to use our TodoActionButton in our TodoItemComponent. This is mostly straightforward, but we also need to make some style changes to keep things looking correct.

{% highlight jsx %}
...
    <Text style={styles.todoTitle}>{title}</Text>
    <TodoItemActionButton title={isCompleted ? "Uncomplete" : "Complete"}
        isDestructive={false} />
    <TodoItemActionButton  title="Delete" isDestructive={true} />
...
const styles = StyleSheet.create({
  ...
  content: {
    flexGrow: 1,
    alignItems: 'stretch',
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'flex-start',
  },
  ...
  todoTitle: {
    flexGrow: 1,
    alignSelf: 'center',
  },
...
{% endhighlight %}

When we run the app now we'll see complete, uncomplete, and delete buttons!

<div class="os-screenshots">
    <label>Android</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-react-native/ActionButtonsAndroid.webp">
        <img src="/assets/img/todo-react-native/ActionButtonsAndroid.png" >
    </picture>
    <label>iOS</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-react-native/ActionButtonsIOS.webp">
        <img src="/assets/img/todo-react-native/ActionButtonsIOS.png" >
    </picture>
</div>

Of course, our buttons don't do anything yet. We'll start by implementing our complete and uncomplete buttons. This is an interesting thing to think about if it's your first time using React: since our todo list (state) is held up at the TodoListScreen level, that's where we want to handle changing our data there. We'll do this by adding our list to the component's "state" and creating a new function that alters the state when called.

{% highlight jsx %}
...
  constructor(props) {
    super(props);
    this.state = {todoItems};

    // This binding is necessary to make `this` work in the callback
    this.toggleItemCompleted = this.toggleItemCompleted.bind(this);
  }
  toggleItemCompleted(itemKey) {
    this.setState((prevState, props) => {
      // Use a temporary variable to avoid directly modifying state
      const tempTodoItems = prevState.todoItems;
      const toggledItemIndex = tempTodoItems.findIndex(item => item.key === itemKey);
      tempTodoItems[toggledItemIndex].isCompleted = 
        !tempTodoItems[toggledItemIndex].isCompleted;
      return {todoItems: tempTodoItems};
    });
  }
  render() {
...
{% endhighlight %}

Now we need to pass this function down through our component hierarchy until we can add it to our button.

###### TodoListScreen
{% highlight jsx %}
...
  <TodoList todoItems={this.state.todoItems} onToggleItemCompleted={this.toggleItemCompleted} />
...
{% endhighlight %}

###### TodoListComponent
{% highlight jsx %}
...
export default function TodoList({todoItems, onToggleItemCompleted, ...props}) {
...
renderItem={({item, index, section}) => <TodoItemComponent {...item} 
                                        itemKey={item.key}
                                        onToggleCompleted={onToggleItemCompleted} />}
...
{% endhighlight %}
> Note: We also passed itemKey here. 'key' is a keyword for SectionList and is not automatically passed with ...item, and we need the key to identify which item is being edited

###### TodoItemComponent.TodoItem
{% highlight jsx %}
...
export default function TodoItem({itemKey, title, isCompleted, 
                                    onToggleCompleted, ...props}) {
...
        <TodoItemActionButton title={isCompleted ? "Uncomplete" : "Complete"} 
          isDestructive={false}
          onPress={() => onToggleCompleted(itemKey)} />
        <TodoItemActionButton title="Delete" 
          isDestructive={true}
          onPress={() => {}/*TODO*/} />
...
{% endhighlight %}

###### TodoItemComponent.TodoItemActionButton
{% highlight jsx %}
...
function TodoItemActionButton({title, isDestructive, onPress, ...props}) {
...
    <TouchableHighlight 
      style={ isDestructive ? styles.destructiveActionButton : styles.actionButton } 
      onPress={onPress}>
...
{% endhighlight %}

With that flury of changes, we've enabled Complete and Uncomplete functionality. 

<div class="os-screenshots">
    <label>Android</label>
    <img src="/assets/img/todo-xamarin-forms/CompleteUncompleteAndroid.gif" />
    <label>iOS</label>
    <img src="/assets/img/todo-xamarin-forms/CompleteUncompleteIOS.gif">
</div>

All of that work also paved the way to add Delete functionality as well. The steps to do this are exactly the same as for Complete/Uncomplete, so I'm just going to show the code changes without repeating any description. The one thing we don't need to change this time around is the TodoItemActionButton. We were clever in our first implementation and made it generic enough to work with any onPress function.

###### TodoListScreen
{% highlight jsx %}
...
constructor(props) {
  ...
  this.deleteItem = this.deleteItem.bind(this);
}
...
deleteItem(itemKey) {
  this.setState((prevState, props) => {
    // Use a temporary variable to avoid directly modifying state
    let tempTodoItems = prevState.todoItems;
    const deletedItemIndex = tempTodoItems.findIndex(item => item.key === itemKey);
    tempTodoItems.splice(deletedItemIndex, 1);
    return {todoItems: tempTodoItems};
  });
}
...
  <TodoList todoItems={this.state.todoItems} onToggleItemCompleted={this.toggleItemCompleted}
    onDeleteItem={this.deleteItem} />
...
{% endhighlight %}

###### TodoListComponent
{% highlight jsx %}
...
export default function TodoList({todoItems, onToggleItemCompleted, onDeleteItem, ...props}) {
...
renderItem={({item, index, section}) => <TodoItemComponent {...item} 
                                        itemKey={item.key}
                                        onToggleCompleted={onToggleItemCompleted}
                                        onDeleteItem={onDeleteItem} />}
...
{% endhighlight %}

###### TodoItemComponent.TodoItem
{% highlight jsx %}
...
export default function TodoItem({itemKey, title, isCompleted, 
                                    onToggleCompleted, onDeleteItem, ...props}) {
...
        <TodoItemActionButton title={isCompleted ? "Uncomplete" : "Complete"} 
          isDestructive={false}
          onPress={() => onToggleCompleted(itemKey)} />
        <TodoItemActionButton title="Delete" 
          isDestructive={true}
          onPress={() => {onDeleteItem(itemKey)} />
...
{% endhighlight %}

And now the user can delete items from their list!

<div class="os-screenshots">
    <label>Android</label>
    <img src="/assets/img/todo-xamarin-forms/DeleteAndroid.gif" />
    <label>iOS</label>
    <img src="/assets/img/todo-xamarin-forms/DeleteIOS.gif">
</div>

We only have two pieces of functionality remaining to finish our app: persistence and 'add item'. We're going to work on persistence next so we can navigate between screens without losing data.

### Persisting the Todo List

We're going to use a very simple form of persistence for this application, <a href="https://facebook.github.io/react-native/docs/asyncstorage.html" target="_blank" rel="_noopener">AsyncStorage</a>. AsyncStorage is a key-value storage mechanism provided directly in the React Native library and has a simple API. While easy to use for a small application, it has drawbacks from both performance and design perspectives. You'll likely want to look into other solutions for more complicated applications.

The first thing we need to do is initialize our storage and read our TodoList from it. Since this is a sample app, we'll also populate our todo list with data anytime it's empty. To do this we'll edit TodoListScreen by adding a new method, initializeTodoList, where we'll handle the basic data logic.

> In a more complex application this may make more sence at a higher level, for example in App.js. However, for this example I find it easier to keep this logic contained in as few files as practical

{% highlight jsx %}
...
import { StyleSheet, Text, View, AsyncStorage } from 'react-native';
...
const initialTodoItems = [ // Renamed to better reflect the new usage
...
  constructor(props) {
    super(props);

    this.state = { todoItems: [] }; // Set default empty list
    ...
    this.initializeTodoList = this.initializeTodoList.bind(this);

    this.initializeTodoList();
  }
  async initializeTodoList() {
    let todoItems = initialTodoItems.slice(); // Start with a copy of our initial list

    // If there's already a saved list, use that instead
    const storedTodoItems = await AsyncStorage.getItem("todoList");
    if(storedTodoItems != null) {
      const storedTodoArray = JSON.parse(storedTodoItems);
      if(storedTodoArray.length) todoItems = storedTodoArray;
    }

    this.setState({todoItems: todoItems});
  }
...
{% endhighlight %}

Next we want to update our toggleItemCompleted and deleteItem methods to save any changes the user makes. We can do this just by adding a callback to our setState calls.

{% highlight jsx %}
...
  toggleItemCompleted(itemKey) {
    this.setState((prevState, props) => {
      ...
    }, () => AsyncStorage.setItem("todoList", JSON.stringify(this.state.todoItems)));
  }
  deleteItem(itemKey) {
    this.setState((prevState, props) => {
      ...
    }, () => AsyncStorage.setItem("todoList", JSON.stringify(this.state.todoItems)));
  }
...
{% endhighlight %}

And that's it! Our application now persists any changes the user makes. You can see this by deleting or completing a todo and reloading the application ("R,R" on Android emulator, "⌘+R" on iOS simulator). If you delete all items, you can reset the initial list by reloading the application (if you want to remove this functionality, just adjust initializeTodoList to stop using initialTodoItems).

### Adding Todo Items

And now we've made it to the last piece we're going to implement for this application: Adding Items! We're going to go through a couple steps to do this: Adding an 'Add Todo' Button, Wiring Up Navigation, Creating an Add Todo screen, and finally Implementing Add.

Adding the 'Add Todo' button is fairly straightforward. We're just going to add a new Button element to TodoListScreen and adjust our styles to make the button always appear at the bottom of the screen:

{% highlight jsx %}
...
import { StyleSheet, Text, View, Button, AsyncStorage } from 'react-native';
...
  render() {
    return (
      <View style={styles.container}>
        <TodoList todoItems={this.state.todoItems} onToggleItemCompleted={this.toggleItemCompleted}
          onDeleteItem={this.deleteItem} style={styles.todoList} />
        <Button title="Add Item" onPress={() => {}} />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    display: 'flex',
    flexGrow: 1,
    flexDirection: 'column',
  },
  todoList: {
    flexGrow: 1,
  },
});
{% endhighlight %}

When we run this we'll see our button at the bottom of the screen.

<div class="os-screenshots">
    <label>Android</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-react-native/AddTodoAndroid.webp">
        <img src="/assets/img/todo-react-native/AddTodoAndroid.png" >
    </picture>
    <label>iOS</label>
    <picture>
        <source type="image/webp" srcset="/assets/img/todo-react-native/AddTodoIOS.webp">
        <img src="/assets/img/todo-react-native/AddTodoIOS.png" >
    </picture>
</div>

> You may notice that the 'Add Item' button on the iPhone 10 is beneath a system control. We'll fix that later after we've created the 'add' functionality



Creating the Add Todo screen is fairly similiar to work we've already done, so we're not going to spend much time on it.