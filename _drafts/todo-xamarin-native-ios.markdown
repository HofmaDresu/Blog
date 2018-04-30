---
layout: post
title:  "Todo in Xamarin Native Part 2 (iOS)"
date:   2018-04-30 11:00:00 -0400
tags: mobile xamarin ios
excerpt_separator: "<!--more-->"
---

In this post we're going to create a todo application on iOS using Xamarin Native. We'll see how we can leverage the Core code we've already written, allowing us to concentrate on the iOS specific code. This is a continuation of the Android app we created in <a href="/2018/04/29/todo-xamarin-native-android">part 1</a>, so I recommend reading that first if you haven't already. <!--more-->  Full source code for this application is available <a href="https://github.com/HofmaDresu/TodoMobile/tree/master/TodoXamarinNative" target="_blank">on GitHub</a>.

### Tools and Environment
> Note: If you've already read the previous post on creating the todo app with Xamarin Forms, this section will be very familiar to you and you can skip ahead to <a href="#creating-hello-world">Creating Hello World</a>

We can develop for Xamarin on either a PC or a Mac. On PC we would use Visual Studio (I'm using Visual Studio 2017 Community) and on Mac we would use Visual Studio for Mac, both available <a href="https://www.visualstudio.com/" target="_blank">here</a>. No matter which OS you develop on, you'll need a Mac with XCode installed. If you're developing on a Windows machine, Visual Studio will connect to the Mac for iOS compilation. This is needed because Apple requires a Mac to compile iOS applications.

With all this installed, we can now start building our app!

<h3 id="creating-hello-world">Creating Hello World</h3>
The first thing we want to do is create our default iOS project. Since we're using our existing solution we can just add our new project to that. We can open TodoXamarinNative.sln then right click on the Solution and select "Add -> New Project...". In the dialog that appears we'll select "Visual C# -> iOS -> Universal -> Blank App (iOS)" and name the project TodoXamarinNative.iOS.

![Create iOS Project]({{ "/assets/img/todo-xamarin-native-ios/CreateProject.PNG" }})

Next we need to create a reference from our new iOS project to Core. To do this, right click on References under TodoXamarinNative.iOS and select "Add Reference". It should open a dialog with the Projects tab open (if not, select the Projects tab). We'll select TodoXamarinNative.Core and click OK.

![Set iOS Core Reference]({{ "/assets/img/todo-xamarin-native-ios/ProjectReferenceIOS.PNG" }})

We now have a solution with 3 projects: Core, Android, and iOS. To run it on iOS we first tell Visual Studio to set our new project as startup project (right click on TodoXamarinNative.iOS and select "Set as Startup Project"). If we try to run our application now we'll see it start up but throw an exception. This is because we still need to create our initial screen. There are a couple ways to do this, the most common of which are using a Storyboard or creating it through code. We're going to opt for the code approach here. While this doesn't give us the designer tools that a storyboard would, it's much easier for both maintenance and when working with other developers.

Our application can be run right now, but it will throw an exception if we try. This is because we haven't actually created our initial view yet. To do this we need to create a new View Controller and tell iOS to use it as our Root View Controller. We'll add the view controller by clicking "Add Class" on our iOS project and name it MainViewController.
> You could almost certainly come up with a more descriptive name, but this lines up nicely with our MainActivity in the Android project. I find it convenient to use similar names between OSs wherever possible.
We then need to tell our class to inherit from UIViewController and give it a title and background color.

{% highlight csharp %}
using UIKit;

namespace TodoXamarinNative.iOS
{
    class MainViewController : UIViewController
    {
        public MainViewController()
        {
            Title = "Todo List";
            View.BackgroundColor = UIColor.White;
        }
    }
}
{% endhighlight %}

Then we'll open AppDelegate.cs and update FinishedLaunching with our new MainViewController. We're also going to wrap our view controller in a UINavigationController. This gives us a few useful things:
* It automatically handles the top safe area on iPhone X
* It displays our title
* It sets up navigation that we'll need later in the app

{% highlight csharp %}
public override bool FinishedLaunching(UIApplication application, NSDictionary launchOptions)
{
    // create a new window instance based on the screen size
    Window = new UIWindow(UIScreen.MainScreen.Bounds);

    // If you have defined a root view controller, set it here:
    Window.RootViewController = new UINavigationController(new MainViewController());

    // make the window visible
    Window.MakeKeyAndVisible();

    return true;
}
{% endhighlight %}

Now when we run it, we'll see the default application.

<div class="os-screenshots">
    <img src="/assets/img/todo-xamarin-native-ios/BlankPage.png" >
</div>

Our application is now up and running, but it's not exactly what one would call "exciting" or "useful" yet. That's what we're going to do in the rest of this post!

### Connecting to the data layer
Before we get to the meat of our UI, we need to connect to the data layer. The first thing we need to do is add the sqlite-net-pcl nuget package to our iOS project.

![Add Sqlite Package]({{ "/assets/img/todo-xamarin-native-ios/AddSqlite.PNG" }})

Next we'll open AppDelegate.cs in our iOS project and add a new static property called TodoRepository. Then we'll edit the FinishedLaunching method and instantiate the new property.

{% highlight csharp %}
...
public static TodoRepository TodoRepository;
...
public override bool FinishedLaunching(UIApplication application, NSDictionary launchOptions)
{
    var docFolder = Environment.GetFolderPath(Environment.SpecialFolder.Personal);
    var libFolder = Path.Combine(docFolder, "..", "Library", "Databases");

    if (!Directory.Exists(libFolder))
    {
        Directory.CreateDirectory(libFolder);
    }

    var repositoryFilePath = Path.Combine(libFolder, "TodoRepository.db3");
    TodoRepository = new TodoRepository(repositoryFilePath);

    return true;
}
...
{% endhighlight %}

<h3 id="displaying-todo-list">Displaying a list of Todo Items</h3>
Now that we've finished our data layer, it's time to actually show something to the user! At this point we're switching out of shared code and will be working entirely in the iOS project. We'll start by displaying a simple list of our Todo Items without any user interaction.

There are several ways to create UIs in iOS, the most common of which are Storyboards and through code. Storyboards are designer files that allow you to lay out the UI of multiple screens and the transitions between them. They are reasonably nice to use if you're the sole developer, however they can quickly become complicated and cause conflicts if there are multiple developers. Instead we're going to create our UI in code. In my opinion, this is better both for version control and for multi-developer scenarios.

We need to create two things to display our list: a UITableView to hold our items and a UITableViewSource to translate our list into rows in the table (this is similar in concept to the Adapter we used on the Android side). We'll start with the UITableaViewSource by creating a new class called TodoItemTableSource. We'll add a constructor that takes in a list of TodoItems and implement the GetCell and RowsInSection methods.

{% highlight csharp %}
using System;
using System.Collections.Generic;
using Foundation;
using TodoXamarinNative.Core;
using UIKit;

namespace TodoXamarinNative.iOS
{
    class TodoItemTableSource : UITableViewSource
    {
        private const string CellIdentifier = "TodoItemCell";
        private readonly List<TodoItem> _todoItems;

        public TodoItemTableSource(List<TodoItem> todoItems)
        {
            _todoItems = todoItems;
        }

        public override UITableViewCell GetCell(UITableView tableView, NSIndexPath indexPath)
        {
            var cell = new UITableViewCell(UITableViewCellStyle.Default, CellIdentifier);
            cell.TextLabel.Text = _todoItems[indexPath.Row].Title;
            return cell;
        }

        public override nint RowsInSection(UITableView tableview, nint section)
        {
            return _todoItems.Count;
        }
    }
}
{% endhighlight %}
> Note: we're using the built in UITableViewCellStyle.Default for our cell's layout. There are a few other options built in, but we could also create our own custom cell.

We also need open our MainViewController and add + populate the list. We'll do this by creating the list in ViewDidLoad and populating it in ViewDidAppear. The only part of this that isn't obvious is that we're using constraints to position our list. Constraints tell iOS how to position our view and work well across multiple device sizes.

{% highlight csharp %}
public override void ViewDidLoad()
{
    base.ViewDidLoad();

    _todoTableView = new UITableView
    {
        TranslatesAutoresizingMaskIntoConstraints = false
    };
    View.Add(_todoTableView);

    _todoTableView.TopAnchor.ConstraintEqualTo(View.TopAnchor).Active = true;
    _todoTableView.BottomAnchor.ConstraintEqualTo(View.BottomAnchor).Active = true;
    _todoTableView.LeftAnchor.ConstraintEqualTo(View.LeftAnchor).Active = true;
    _todoTableView.RightAnchor.ConstraintEqualTo(View.RightAnchor).Active = true;
}

public override async void ViewDidAppear(bool animated)
{
    base.ViewDidAppear(animated);

    var todoList = await AppDelegate.TodoRepository.GetList();
    _todoTableView.Source = new TodoItemTableSource(todoList);
    _todoTableView.ReloadData();
}
{% endhighlight %}
> Setting .Active = true on each of our constraints looks weird, but if we don't do this the app won't use those settings

Now our application will display the list of our Todos!

<div class="os-screenshots">
    <img src="/assets/img/todo-xamarin-native-ios/InitialList.png" >
</div>

The only thing remaining that we should show is whether-or-not the items are completed.

### Completing, Uncompleting, and Deleting Items
We're going to start by implemeting actions that the user can take without leaving the main screen: Completing, Uncompleting, and Deleting items. Much like displaying the items, this involves platform specific code to wire up.

##### Android
We'll start with Completing and Uncompleting tasks since we already have a CheckBox control to interact with. The first thing we need to do is update our TodoAdapter to raise an event when the user clicks a checkbox. We need to create an EventHandler called OnCompletedChanged and a method called IsCompleted_CheckedChange that calls the handler.

{% highlight csharp %}
class TodoAdapter : BaseAdapter
{
    Context context;
    private List<TodoItem> _todoItems;
    public EventHandler<int> OnCompletedChanged;
...
public override View GetView(int position, View convertView, ViewGroup parent)
{
    ...
    holder.IsCompleted.Checked = currentTodoItem.IsCompleted;
    holder.IsCompleted.Tag = currentTodoItem.Id;
    holder.IsCompleted.CheckedChange -= IsCompleted_CheckedChange;
    holder.IsCompleted.CheckedChange += IsCompleted_CheckedChange;

    return view;
}        
...
private void IsCompleted_CheckedChange(object sender, CompoundButton.CheckedChangeEventArgs e)
{
    var id = (int)((View)sender).Tag;
    OnCompletedChanged?.Invoke(sender, id);
}
{% endhighlight %}
> We're using the 'Tag' property of the CheckBox to store our TodoItem's Id so we can pass it to the EventHandler

Next we need to update our MainActivity to respond to OnCompletedChanged. To do this, we'll also need to store our todo list in a private field.

{% highlight csharp %}
...
public class MainActivity : Activity
{
    private ListView _todoListView;
    private List<TodoItem> _todoList;
...
protected override async void OnResume()
{
    base.OnResume();

    await UpdateTodoList();
}

private async Task UpdateTodoList()
{
    _todoList = await MainApplication.TodoRepository.GetList();
    var adapter = new TodoAdapter(this, _todoList.OrderBy(t => t.IsCompleted).ToList());
    adapter.OnCompletedChanged += HandleItemCompletedChanged;
    _todoListView.Adapter = adapter;
}

private async void HandleItemCompletedChanged(object sender, int todoId)
{
    var targetItem = _todoList.Single(t => t.Id == todoId);
    await MainApplication.TodoRepository.ChangeItemIsCompleted(targetItem);
    await UpdateTodoList();
}
{% endhighlight %}

Now when we run the application, we can see our list updating when the user clicks an item's checkbox.

<div class="os-screenshots">
    <img src="/assets/img/todo-xamarin-native/ChangeCompletedAndroid.gif" />
</div>

Next we want to allow the user to delete an item from the list. Conveniently, Android ListViews have a built-in context menu we can call when the user long presses an item. First thing we'll do is display the menu with a "delete" button.

We need to adjust our MainActivity to do two things: register our listview for a context menu, and implement an override for OnCreateContextMenu where we set our items. We might be tempted to handle registration in the constructor, thinking that we only want to do that once, however we want to register after the adapter is set in OnResume so Android knows what items need to be handled.

{% highlight csharp %}
    ...
    _todoListView.Adapter = adapter;
    RegisterForContextMenu(_todoListView);
}
...
public override void OnCreateContextMenu(IContextMenu menu, View v, IContextMenuContextMenuInfo menuInfo)
{
    base.OnCreateContextMenu(menu, v, menuInfo);
    if (v.Id == _todoListView.Id)
    {
        AdapterContextMenuInfo info = (AdapterContextMenuInfo)menuInfo;
        var item = _todoList.Single(t => t.Id == _todoListView.Adapter.GetItemId(info.Position));
        var title = item.Title;
        menu.SetHeaderTitle(title);

        menu.Add("Delete");
    }
}
{% endhighlight %}

If we try to run the app now, we won't see the context menu that we expect. This is because we need to make a couple changes in our adapter to support this. First we need to enable long press on our view, and second we need to actually implement the GetItemId method that we're calling in OnCreateContextMenu.

{% highlight csharp %}
...
public override long GetItemId(int position)
{
    return _todoItems[position].Id;
}
...
public override View GetView(int position, View convertView, ViewGroup parent)
{
    ...
    view = inflater.Inflate(Resource.Layout.TodoListItem, parent, false);
    view.LongClickable = true;
{% endhighlight %}

Now we'll see a context menu with our item's title and a Delete button when the user long presses on a todo item.

<div class="os-screenshots">
    <img src="/assets/img/todo-xamarin-native/DeleteButtonAndroid.png" />
</div>
    
Finally we should implement the delete button. For this we'll override the OnContextItemSelected method in MainActivity, making it remove the selected item from the database and refresh our list.

{% highlight csharp %}
public override bool OnContextItemSelected(IMenuItem menuItem)
{
    switch (menuItem.GroupId)
    {
        case 0:
            var info = (AdapterContextMenuInfo)menuItem.MenuInfo;
            var item = _todoList.Single(t => t.Id == _todoListView.Adapter.GetItemId(info.Position));
            MainApplication.TodoRepository.DeleteItem(item)
                .ContinueWith(_ =>
                {
                    RunOnUiThread(async () =>
                    {
                        await UpdateTodoList();
                    });
                });
            return true;
        default:
            return base.OnContextItemSelected(menuItem);
    }
}
{% endhighlight %}

There are a few interesting things to look at here. 
* We used a ContinueWith instead of an await. We did this because the base OnContextItemSelected method expects to return a bool, so we can't adjust it to be an async function.
* We used a method we haven't seen before: RunOnUiThread. This marshalls the action back to the UI thread, and is required when you need to make a visual change from a background thread. In our case, we're updating the ListView's adapter
* Our switch statement is currently hard-coded to expect 'delete' to be in the 0th position. This is not a good idea in more complex apps, since future developers can add or re-arrange context items. There are better ways to handle this, but they're beyond what I want to get into for this post.

With that implemented, we can run the app and see that our item deletion works!

<div class="os-screenshots">
    <img src="/assets/img/todo-xamarin-native/DeleteItemAndroid.gif" />
</div>

Now we'll switch to iOS and add our actions there.

##### iOS
TODO

### Adding Todo Items

Our app is doing pretty well at this point, but we're missing one very important feature: adding new todo items! We're going to add a button to our todo list screen and create a new screen where the user can enter their item. Following the pattern of the previous two sections, this will involve solely OS specific code.

##### Android

The first thing we want to do is create an "Add Todo Item" button for the user to click. We'll do this by editing our Main.axml layout file.

{% highlight xml %}
...
    <ListView
        android:id="@+id/TodoList"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"/>
    <Button
        android:id="@+id/AddNewItem"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"/>
</LinearLayout>
{% endhighlight %}

This adds our new button to the bottom of our screen. Notice we used the "layout_weight" attribute again on the ListView to tell it to consume all available space.

<div class="os-screenshots">
    <img src="/assets/img/todo-xamarin-native/AddButtonAndroid.png" />
</div>

Before we implement the buttions functionality, we should create a new screen for it to navigate to. We'll add a new Activity to TodoXamarinNative.Android called "AddTodoItemActivity" and a new layout to Resources/layout called "AddTodoItem". Our layout will contain an EditText and two Buttons (Cancel and Save), and we'll tell AddTodoItemActivity to use our layout in the OnCreate method.

{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center">
  <EditText
    android:id="@+id/TodoTitle"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"/>
  <LinearLayout
    android:orientation="horizontal"
    android:layout_width="match_parent"
    android:layout_height="wrap_content">
    <Button
      android:id="@+id/CancelButton"
      android:text="Cancel"
      android:layout_width="0dp"
      android:layout_height="wrap_content"
      android:layout_weight="1"
      android:layout_marginLeft="5dp"
      android:layout_marginRight="5dp"/>
    <Button
      android:id="@+id/SaveButton"
      android:text="Save"
      android:layout_width="0dp"
      android:layout_height="wrap_content"
      android:layout_weight="1"
      android:layout_marginRight="5dp"
      android:layout_marginLeft="5dp"/>
  </LinearLayout>
</LinearLayout>
{% endhighlight %}

{% highlight csharp %}
using Android.App;
using Android.OS;

namespace TodoXamarinNative.Android
{
    [Activity(Label = "AddTodoItemActivity")]
    public class AddTodoItemActivity : Activity
    {
        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);

            SetContentView(Resource.Layout.AddTodoItem);
        }
    }
}
{% endhighlight %}

We did a couple new things in our layout worth calling out. First, we used layout_weight again but a little differently than before. Instead of setting a single element to use layout_weight, we told both buttons to use the same weight. This will cause them to both expand to use half of the available space (excluding the left and right margins we set). We also set the main StackLayout's gravity to 'center'. This will put our controls in the center of the screen vertically.

Next we need to wire up our button and tell it to navigate to our new activity. We'll do this in the OnCreate method in MainActivity.

{% highlight csharp %}
protected override void OnCreate(Bundle savedInstanceState)
{
    ...
    FindViewById<Button>(Resource.Id.AddNewItem).Click += 
            (s, e) => StartActivity(new Intent(this, typeof(AddTodoItemActivity)));
}
{% endhighlight %}

Now when the user clicks our button, they're taken to the AddTodoItemActivity.

<div class="os-screenshots">
    <img src="/assets/img/todo-xamarin-native/AddItemScreenAndroid.png" />
</div>

Now it's time to implement our Add Item screen. First we'll start with the Cancel button, since that has the least amount of work to do. We'll open AddTodoItemActivity and add a single line that calls the built in Finish method.

{% highlight csharp %}
protected override void OnCreate(Bundle savedInstanceState)
{
    ...
    FindViewById<Button>(Resource.Id.CancelButton).Click += (s, e) => Finish();
}
{% endhighlight %}

Next we'll implement the "Save" button. This has a little more work to do, but not much. We need to:
* Read the text from our EditText
* Save a new Item to the database
* Call Finish
Because there are more steps, we'll split it out into a separate method.

{% highlight csharp %}
protected override void OnCreate(Bundle savedInstanceState)
{
    ...    
    FindViewById<Button>(Resource.Id.SaveButton).Click += HandleSave;
}

private async void HandleSave(object s, EventArgs e)
{
    var todoText = FindViewById<EditText>(Resource.Id.TodoTitle).Text;
    await MainApplication.TodoRepository.AddItem(new TodoItem { Title = todoText });
    Finish();
}
{% endhighlight %}

With that in place, our user can add items!

<div class="os-screenshots">
    <img src="/assets/img/todo-xamarin-native/AddItemAndroid.gif" />
</div>

That finishes our functionality on Android, but there's one more thing we should cover before finishing iOS. You may have noticed that our screen titles aren't very useful. Let's fix that. If we look in both of our Activity files, there's an Activity attribute with a Label. That label is what Android is displaying to our user, so lets set them to something more useful.

{% highlight csharp %}
...
[Activity(Label = "Todo List", MainLauncher = true)]
public class MainActivity : Activity
...
{% endhighlight %}

{% highlight csharp %}
...
[Activity(Label = "Add Todo Item")]
public class AddTodoItemActivity : Activity
...
{% endhighlight %}

Now our screen titles are much better.

<div class="os-screenshots">
    <label></label>
    <img src="/assets/img/todo-xamarin-native/TitledTodoListAndroid.png" />
    <label></label>
    <img src="/assets/img/todo-xamarin-native/TitledAddItemAndroid.png" />
</div>

Now let's move onto iOS and finish our application there.

##### iOS
TODO

### Conclusion
And there we have it! We've created a simple Todo application for both iOS and Android using Xamarin Native. We've created the UIs using native-style platform specific code while sharing our data storage code between the platforms. While we didn't do a lot with shared code, hopefully you can see how we would use the same technique for things like business logic, web request, or most other non-UI functionality you need. 