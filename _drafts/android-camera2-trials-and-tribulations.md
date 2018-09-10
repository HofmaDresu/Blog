---
layout: post
title:  "Trials and Tribulations with Android Camera2 API"
date:   2018-09-09 19:00:00 -0400
tags: Android Camera2 Xamarin 
excerpt_separator: "<!--more-->"
---

I recently had the opportunity to work with the Android Camera2 API on a Xamarin project for a client. I found the API tough to start using initially, so I decided to create a post about using it to help reinforce what I learned. I'm definitely not an expert in Camera2 yet, but this should help others (or future me) understand the basics and save a lot of ramp-up time.<!--more--> 

All code for this post is available on <a href="" target="_blank" rel="noopener">GitHub</a>.

### Existing Resources

Before we get started, I wanted to call out the existing resources I found during my search. Both Xamarin and Google provide sample projects for rear-camera picture and rear-camera video. The links in the table below will bring you to the various projects:

<table>
    <tr>
        <th>Xamarin</th>
        <th>Google (Java and Kotlin)</th>
    </tr>
    <tr>
        <td><a href="https://github.com/xamarin/monodroid-samples/tree/master/android5.0/Camera2Basic" target="_blank" rel="noopener">Photo</a></td>
        <td><a href="https://github.com/googlesamples/android-Camera2Basic" target="_blank" rel="noopener">Photo</a></td>
    </tr>
    <tr>
        <td><a href="https://github.com/xamarin/monodroid-samples/tree/master/android5.0/Camera2VideoSample" target="_blank" rel="noopener">Video</a></td>
        <td><a href="https://github.com/googlesamples/android-Camera2Video" target="_blank" rel="noopener">Video</a></td>
    </tr>
</table>

Google also provides <a href="https://developer.android.com/reference/android/hardware/camera2/package-summary" target="_blank" rel="noopener">API docs</a> for Camera2.

### Creating a New Sample App

While the resources above are all useful and helped me eventually create the functionality I needed, I found them hard to grok as a first time user of this API. What I plan to do with this post is create my own sample application and explain each area to the extent of my understanding. This app will be slightly more complex than the Xamarin and Google examples in order to match the real-world situation that I needed to handle. The biggest additions are:

* Support for both front and rear cameras
* Support for both photo and video capture on the same screen
* A view to display the photo/video after it is taken

The first two points add complications to the code that are tricky to figure out the first time around. I will explain both the complications and the solutions when we get to them. 

The third point provides an easy way to test that we're capturing the photo/video correctly. I won't provide much explanation for the preview screens, but I feel the existing samples are harder to understand without them.

#### The Capture Layout