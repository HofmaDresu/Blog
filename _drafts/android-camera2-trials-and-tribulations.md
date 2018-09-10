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

> Note: For this sample I'm targeting SDK 21. I'm doing keep permissions code from complicating the example. For a real production app, you'll need to target a modern version and make sure you handle the required permissions (Camera, Microphone, Storage)

#### The Capture Layout

The first thing we want to do is create a layout where we'll allow the user to take photos and videos. This will be a mostly straightforward view with 4 main parts: a reverse camera button, a camera preview, a take picture button, and a record video button. We'll do this with the following code

{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent">
  <LinearLayout
      android:id="@+id/button_section"
      android:layout_height="100dp"
      android:layout_width="match_parent"
      android:layout_alignParentBottom="true"
      android:background="@android:color/white"
      android:orientation="horizontal">
    <Button
      android:id="@+id/take_picture_button"
      android:layout_height="80dp"
      android:layout_width="0dp"
      android:layout_weight="1"
      android:layout_gravity="center_vertical"
      android:text="Take Picture"/>
    <Button
      android:id="@+id/record_video_button"
      android:layout_height="80dp"
      android:layout_width="0dp"
      android:layout_weight="1"
      android:layout_gravity="center_vertical"
      android:text="Record Video"/>
  </LinearLayout>
  <AndroidCamera2Demo.Controls.AutoFitTextureView
      android:id="@+id/surface"
      android:layout_height="match_parent"
      android:layout_width="match_parent"
      android:layout_centerHorizontal="true"
      android:layout_above="@id/button_section" />
  <ImageButton
      android:id="@+id/reverse_camera_button"
      android:layout_width="wrap_content"
      android:layout_height="wrap_content"
      android:layout_alignParentLeft="true"
      android:layout_alignParentTop="true"
      android:src="@drawable/twotone_switch_camera_black_48" />
</RelativeLayout>
{% endhighlight %}

The only really interesting thing here is the AutoFitTextureView. This is a custom class that inherits TextureView and gives us the ability to adjust its size to fit our camera's aspect ratio. This prevents the preview image from appearing squashed or stretched.

{% highlight csharp %}
using System;
using Android.Content;
using Android.Util;
using Android.Views;

namespace AndroidCamera2Demo.Controls
{
    /// <summary>
    /// AutoFitTextureView provides the method SetAspectRatio. This method adjusts the dimensions of the view the smallest amount possible to match the desired aspect ratio
    /// </summary>
    class AutoFitTextureView : TextureView
    {
        private int ratioWidth = 0;
        private int ratioHeight = 0;

        public AutoFitTextureView(Context context) : this(context, null)
        {
        }

        public AutoFitTextureView(Context context, IAttributeSet attrs) :
        this(context, attrs, 0)
        {
        }

        public AutoFitTextureView(Context context, IAttributeSet attrs, int defStyle) :
            base(context, attrs, defStyle)
        {

        }


        /// <summary>
        /// Set the desired aspect ratio for this view
        /// </summary>
        /// <param name="width"></param>
        /// <param name="height"></param>
        public void SetAspectRatio(int width, int height)
        {
            if (width < 0 || height < 0)
                throw new Exception("Size cannot be negative.");
            ratioWidth = width;
            ratioHeight = height;
            RequestLayout();
        }

        protected override void OnMeasure(int widthMeasureSpec, int heightMeasureSpec)
        {
            base.OnMeasure(widthMeasureSpec, heightMeasureSpec);
            int width = MeasureSpec.GetSize(widthMeasureSpec);
            int height = MeasureSpec.GetSize(heightMeasureSpec);
            if (0 == ratioWidth || 0 == ratioHeight)
            {
                SetMeasuredDimension(width, height);
            }
            else
            {
                // The commented out section allows this method to alter the height of this view if that is the smaller change.
                // In this sample we want to have a fixed height, so we're only allowing this method to change width
                /*
                if (width < (float)height * ratioWidth / ratioHeight)
                {
                    SetMeasuredDimension(width, width * ratioHeight / ratioWidth);
                }
                else
                {
                */
                    SetMeasuredDimension(height * ratioWidth / ratioHeight, height);
                //}
            }
        }
    }
}
{% endhighlight %}

> Note that I've commented out a section of the OnMeasure method. This class comes from the Xamarin (and Google) samples for Camera2, but it has functionality I don't want for this example. The real-world application I worked on required that the device always be in portrait mode and that the height of the preview be set in stone. Without commenting out code, the example AutoFitTextureView allows either height or width to change depending on which is the smaller adjustment. I left the full code in this sample for completeness, but in a real app I would recommend deleting anything you don't use.

After adding this code our view looks like this:

<div class="os-screenshots">
    <picture>
        <source type="image/webp" srcset="/assets/img/android-camera2-trials-and-tribulations/InitialLayoutView.webp">
        <img src="/assets/img/android-camera2-trials-and-tribulations/InitialLayoutView.png" >
    </picture>
</div>

#### Supporting Classes

Before we really get going with the camera, there are several supporting classes that we'll need to use. 

The Camera2 API is set up to use Java-style callbacks and listeners, so we need to create classes that implement the required interfaces. I think these are cleanest if they just provide an Action that the main class can use to tie into the callback events. We'll create 4 classes in this category: CameraStateCallback, CaptureStateSessionCallback, CameraCaptureCallback, and ImageAvailableListener. In addition to those we'll need one comparison class, which we'll call CompareSizesByArea.

##### CameraStateCallback
This callback is used during the camera activation phase of our code. We'll use this when we ask the Camera2 API to open our camera. The API will call one of 3 methods depending on the results of our open request: OnOpened, OnError, and OnDisconnected.

{% highlight csharp%}
using System;
using Android.Hardware.Camera2;
using Android.Runtime;

namespace AndroidCamera2Demo.Callbacks
{
    public class CameraStateCallback : CameraDevice.StateCallback
    {
        public Action<CameraDevice> Disconnected;
        public Action<CameraDevice, CameraError> Error;
        public Action<CameraDevice> Opened;

        public override void OnDisconnected(CameraDevice camera)
        {
            Disconnected?.Invoke(camera);
        }

        public override void OnError(CameraDevice camera, [GeneratedEnum] CameraError error)
        {
            Error?.Invoke(camera, error);
        }

        public override void OnOpened(CameraDevice camera)
        {
            Opened?.Invoke(camera);
        }
    }
}
{% endhighlight %}

##### CaptureStateSessionCallback
This callback is used during the Preview Configuration phase of our code. We'll use this after requesting a preview capture session. The API will then call either OnConfigured or OnConfigureFailed as needed.

{% highlight csharp%}
using System;
using Android.Hardware.Camera2;

namespace AndroidCamera2Demo.Callbacks
{
    public class CaptureStateSessionCallback : CameraCaptureSession.StateCallback
    {
        public Action<CameraCaptureSession> Failed;
        public Action<CameraCaptureSession> Configured;

        public override void OnConfigured(CameraCaptureSession session)
        {
            Configured?.Invoke(session);
        }

        public override void OnConfigureFailed(CameraCaptureSession session)
        {
            Failed?.Invoke(session);
        }
    }
}
{% endhighlight %}

##### CameraCaptureCallback
This callback is used during the Preview and Image Capture phases of our code. This will allow us to interact with the camera and image during focus, light balance (for flash), and image capture. We'll need this when we start our preview and when the user takes a photo. The API will call OnCaptureProgressed and OnCaptureCompleted as needed.
> We'll handle OnCaptureProgressed and OnCaptureCompleted the same way. I'm sure there are reasons to handle them differently, however this is one of the areas of Camera2 I don't yet fully understand.

{% highlight csharp%}
using System;
using Android.Hardware.Camera2;

namespace AndroidCamera2Demo.Callbacks
{
    public class CameraCaptureCallback : CameraCaptureSession.CaptureCallback
    {
        public Action<CameraCaptureSession, CaptureRequest, TotalCaptureResult> CaptureCompleted;

        public Action<CameraCaptureSession, CaptureRequest, CaptureResult> CaptureProgressed;

        public override void OnCaptureCompleted(CameraCaptureSession session, CaptureRequest request, TotalCaptureResult result)
        {
            CaptureCompleted?.Invoke(session, request, result);
        }

        public override void OnCaptureProgressed(CameraCaptureSession session, CaptureRequest request, CaptureResult partialResult)
        {
            CaptureProgressed?.Invoke(session, request, partialResult);
        }
    }
}
{% endhighlight %}

##### ImageAvailableListener
This listener is after the photo capture process is complete. We'll use it at the end of the Take Photo process is complete. The API will call OnImageAvailable when it has finished processing the image, and we will use the results to save our photo.

{% highlight csharp%}
using System;
using Android.Media;

namespace AndroidCamera2Demo.Callbacks
{
    public class ImageAvailableListener : Java.Lang.Object, ImageReader.IOnImageAvailableListener
    {
        public Action<ImageReader> ImageAvailable;

        public void OnImageAvailable(ImageReader reader)
        {
            ImageAvailable?.Invoke(reader);
        }
    }
}
{% endhighlight %}

#### CompareSizesByArea
This class will be used in several calculations to determine the correct image and view sizes for our screen and camera configurations. This was provided by both the Xamarin and Android sample applications.

{% highlight csharp %}
using Android.Util;
using Java.Lang;
using Java.Util;

namespace AndroidCamera2Demo
{
    public class CompareSizesByArea : Object, IComparator
    {
        public int Compare(Object lhs, Object rhs)
        {
            var lhsSize = (Size)lhs;
            var rhsSize = (Size)rhs;
            // We cast here to ensure the multiplications won't overflow
            return Long.Signum((long)lhsSize.Width * lhsSize.Height - (long)rhsSize.Width * rhsSize.Height);
        }
    }
}
{% endhighlight %}