---
layout: post
title:  "Trials and Tribulations with Android Camera2 API"
date:   2018-09-11 15:00:00 -0400
tags: Android Camera2 Xamarin 
excerpt_separator: "<!--more-->"
---

I recently had the opportunity to work with the Android Camera2 API on a Xamarin project for a client. I found the API tough to start using initially, so I decided to create a post about using it to help reinforce what I learned. I'm definitely not an expert in Camera2 yet, but this should help others (or future me) understand the basics and save a lot of ramp-up time.<!--more--> 

All code for this post is available on <a href="https://github.com/HofmaDresu/AndroidCamera2Sample" target="_blank" rel="noopener">GitHub</a>. I recommend downloading a copy to follow along on your own. I will include relevent code samples in this post, but I think it's helpful to see everything together as well.

> Disclaimer: I've tried to make this sample as complete and usable as possible, but I definitely could have missed edge cases. You should test against many devices, especially making sure to hit both Samsung and non-Samsung phones as there can be odd camera differences between them. If you find a case I missed I'd love to hear about it so I can update this post. Feel free to tweet me <a href="https://www.twitter.com/{{ site.twitter_username| cgi_escape | escape }}" target="_blank">@{{site.twitter_username}}</a>


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

The first two points add complications to the code that are tricky to figure out the first time around. The third point provides an easy way to test that we're capturing the photo/video correctly. I won't provide much explanation for the preview screens, but I feel the existing samples are harder to understand without them.

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
                // This code allows us to alter the height or width of the view to match our desired aspect ration         
                if (width < (float)height * ratioWidth / ratioHeight)
                {
                    SetMeasuredDimension(width, width * ratioHeight / ratioWidth);
                }
                else
                {
                    SetMeasuredDimension(height * ratioWidth / ratioHeight, height);
                }
            }
        }
    }
}
{% endhighlight %}

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
This callback is used during the Preview Configuration phase of both photo and video portions of our code (separate instances, of course). We'll use this after requesting a preview capture session. The API will then call either OnConfigured or OnConfigureFailed as needed.

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

#### The Boilerplate 

There are a lot of events and actions we need to handle in order to get our camera working. To get it out of the way, we'll add many of them now and arrange them as close as possible to the flow of the application. One thing you'll notice as we go through this app is that there is a *lot* of code to deal with. Because of that, we're going to split our MainActivity into partial classes to make our code a little easier to work with.

##### MainActivity.cs
Most of this is just normal initialization. The one interesting thing we're setting up for later use is our 'orientations' field. This will be used to help determine how our image and video captures are oriented (more on this later).

{% highlight csharp %}
using Android.App;
using Android.OS;
using Android.Support.V7.App;
using Android.Runtime;
using Android.Widget;
using AndroidCamera2Demo.Controls;
using Android.Content.PM;
using AndroidCamera2Demo.Callbacks;
using Android.Hardware.Camera2;
using Android.Views;
using Android.Util;
using System;

namespace AndroidCamera2Demo
{
    [Activity(Label = "@string/app_name", Theme = "@style/AppTheme", 
        MainLauncher = true, ScreenOrientation = ScreenOrientation.Portrait)]
    public partial class MainActivity : AppCompatActivity
    {
        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            SetContentView(Resource.Layout.activity_main);

            surfaceTextureView = FindViewById<AutoFitTextureView>(Resource.Id.surface);
            switchCameraButton = FindViewById<ImageButton>(Resource.Id.reverse_camera_button);
            takePictureButton = FindViewById<Button>(Resource.Id.take_picture_button);
            recordVideoButton = FindViewById<Button>(Resource.Id.record_video_button);
            
            cameraStateCallback = new CameraStateCallback
            {
                Opened = OnOpened,
                Disconnected = OnDisconnected,
                Error = OnError,
            };
            captureStateSessionCallback = new CaptureStateSessionCallback
            {
                Configured = OnPreviewSessionConfigured,
            };
            videoSessionStateCallback = new CaptureStateSessionCallback
            {
                Configured = OnVideoSessionConfigured,
            };
            cameraCaptureCallback = new CameraCaptureCallback
            {
                CaptureCompleted = (session, request, result) => ProcessImageCapture(result),
                CaptureProgressed = (session, request, result) => ProcessImageCapture(result),
            };
            manager = GetSystemService(CameraService) as CameraManager;
            windowManager = GetSystemService(WindowService).JavaCast<IWindowManager>();
            onImageAvailableListener = new ImageAvailableListener
            {
                ImageAvailable = HandleImageCaptured,
            };
            orientations.Append((int)SurfaceOrientation.Rotation0, 90);
            orientations.Append((int)SurfaceOrientation.Rotation90, 0);
            orientations.Append((int)SurfaceOrientation.Rotation180, 270);
            orientations.Append((int)SurfaceOrientation.Rotation270, 180);
        }

        private AutoFitTextureView surfaceTextureView;
        private ImageButton switchCameraButton;
        private Button takePictureButton;
        private Button recordVideoButton;
        private CameraStateCallback cameraStateCallback;
        private CaptureStateSessionCallback captureStateSessionCallback;
        private CaptureStateSessionCallback videoSessionStateCallback;
        private CameraCaptureCallback cameraCaptureCallback;
        private CameraManager manager;
        private IWindowManager windowManager;
        private ImageAvailableListener onImageAvailableListener;
        private SparseIntArray orientations = new SparseIntArray();

        protected override void OnResume()
        {
            base.OnResume();
            switchCameraButton.Click += SwitchCameraButton_Click;
            takePictureButton.Click += TakePictureButton_Click;
            recordVideoButton.Click += RecordVideoButton_Click;
        }

        private void SwitchCameraButton_Click(object sender, EventArgs e)
        {
            // TODO
        }

        protected override void OnPause()
        {
            base.OnPause();
            switchCameraButton.Click -= SwitchCameraButton_Click;
            takePictureButton.Click -= TakePictureButton_Click;
            recordVideoButton.Click -= RecordVideoButton_Click;
        }

        private void OnOpened(CameraDevice cameraDevice)
        {
            // TODO
        }

        private void OnDisconnected(CameraDevice cameraDevice)
        {
            // In a real application we may need to handle the user disconnecting external devices.
            // Here we're only worring about built-in cameras
        }

        private void OnError(CameraDevice cameraDevice, CameraError cameraError)
        {
            // In a real application we should handle errors gracefully
        }

        private void OnPreviewSessionConfigured(CameraCaptureSession session)
        {
            // TODO
        }
    }
}
{% endhighlight %}

##### MainActivity_PhotoCapture.cs
{% highlight csharp %}
using System;
using Android.Hardware.Camera2;
using Android.Media;

namespace AndroidCamera2Demo
{
    // Photo Capture specific code
    public partial class MainActivity
    {
        private void TakePictureButton_Click(object sender, EventArgs e)
        {
            // TODO
        }

        private void ProcessImageCapture(CaptureResult result)
        {
            // TODO
        }

        private void HandleImageCaptured(ImageReader imageReader)
        {
            // TODO
        }
    }
}
{% endhighlight %}

##### MainActivity_VideoCapture.cs
{% highlight csharp %}
using System;
using Android.Hardware.Camera2;

namespace AndroidCamera2Demo
{
    // Video Capture specific code
    public partial class MainActivity
    {
        private void RecordVideoButton_Click(object sender, EventArgs e)
        {
            // TODO
        }

        private void OnVideoSessionConfigured(CameraCaptureSession session)
        {
            // TODO
        }
    }
}
{% endhighlight %}

With all of that out of the way, we can finally get to the fun part!

#### The Camera Preview

Now it's time to create our camera preview. There is a *lot* of code in this section. Below you can see the MainActivity.cs file in its entirety, and we'll follow that up with descriptions of the interesting parts.

> Most of this code is taken from the Xamarin sample, though I've adapted some parts to fit my needs. I'll try to call out any functional changes while describing the code

{% highlight csharp %}
using Android.App;
using Android.OS;
using Android.Support.V7.App;
using Android.Runtime;
using Android.Widget;
using AndroidCamera2Demo.Controls;
using Android.Content.PM;
using AndroidCamera2Demo.Callbacks;
using Android.Hardware.Camera2;
using Android.Views;
using Android.Util;
using System;
using Android.Hardware.Camera2.Params;
using Java.Util;
using Android.Graphics;
using Android.Media;
using System.Collections.Generic;
using System.Linq;

namespace AndroidCamera2Demo
{
    [Activity(Label = "@string/app_name", Theme = "@style/AppTheme", MainLauncher = true, ScreenOrientation = ScreenOrientation.Portrait)]
    public partial class MainActivity : AppCompatActivity
    {
        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            // Set our view from the "main" layout resource
            SetContentView(Resource.Layout.activity_main);

            surfaceTextureView = FindViewById<AutoFitTextureView>(Resource.Id.surface);
            switchCameraButton = FindViewById<ImageButton>(Resource.Id.reverse_camera_button);
            takePictureButton = FindViewById<Button>(Resource.Id.take_picture_button);
            recordVideoButton = FindViewById<Button>(Resource.Id.record_video_button);
            
            cameraStateCallback = new CameraStateCallback
            {
                Opened = OnOpened,
                Disconnected = OnDisconnected,
                Error = OnError,
            };
            captureStateSessionCallback = new CaptureStateSessionCallback
            {
                Configured = OnPreviewSessionConfigured,
            };
            videoSessionStateCallback = new CaptureStateSessionCallback
            {
                Configured = OnVideoSessionConfigured,
            };
            cameraCaptureCallback = new CameraCaptureCallback
            {
                CaptureCompleted = (session, request, result) => ProcessImageCapture(result),
                CaptureProgressed = (session, request, result) => ProcessImageCapture(result),
            };
            manager = GetSystemService(CameraService) as CameraManager;
            windowManager = GetSystemService(WindowService).JavaCast<IWindowManager>();
            onImageAvailableListener = new ImageAvailableListener
            {
                ImageAvailable = HandleImageCaptured,
            };
            orientations.Append((int)SurfaceOrientation.Rotation0, 90);
            orientations.Append((int)SurfaceOrientation.Rotation90, 0);
            orientations.Append((int)SurfaceOrientation.Rotation180, 270);
            orientations.Append((int)SurfaceOrientation.Rotation270, 180);
        }

        private AutoFitTextureView surfaceTextureView;
        private ImageButton switchCameraButton;
        private Button takePictureButton;
        private Button recordVideoButton;
        private CameraStateCallback cameraStateCallback;
        private CaptureStateSessionCallback captureStateSessionCallback;
        private CaptureStateSessionCallback videoSessionStateCallback;
        private CameraCaptureCallback cameraCaptureCallback;
        private CameraManager manager;
        private IWindowManager windowManager;
        private ImageAvailableListener onImageAvailableListener;
        private SparseIntArray orientations = new SparseIntArray();
        private LensFacing currentLensFacing = LensFacing.Back;
        private CameraCharacteristics characteristics;
        private CameraDevice cameraDevice;
        private ImageReader imageReader;
        private int sensorOrientation;
        private Size previewSize;
        private HandlerThread backgroundThread;
        private Handler backgroundHandler;
        private bool flashSupported;
        private Surface previewSurface;
        private CameraCaptureSession captureSession;
        private CaptureRequest.Builder previewRequestBuilder;
        private CaptureRequest previewRequest;

        protected override void OnResume()
        {
            base.OnResume();
            switchCameraButton.Click += SwitchCameraButton_Click;
            takePictureButton.Click += TakePictureButton_Click;
            recordVideoButton.Click += RecordVideoButton_Click;

            StartBackgroundThread();

            if (surfaceTextureView.IsAvailable)
            {
                ForceResetLensFacing();
            }
            else
            {
                surfaceTextureView.SurfaceTextureAvailable += SurfaceTextureView_SurfaceTextureAvailable;
            }
        }

        private void SurfaceTextureView_SurfaceTextureAvailable(object sender, TextureView.SurfaceTextureAvailableEventArgs e)
        {
            ForceResetLensFacing();
        }

        private void StartBackgroundThread()
        {
            backgroundThread = new HandlerThread("CameraBackground");
            backgroundThread.Start();
            backgroundHandler = new Handler(backgroundThread.Looper);
        }

        private void SwitchCameraButton_Click(object sender, EventArgs e)
        {
            // TODO
        }

        protected override void OnPause()
        {
            base.OnPause();
            switchCameraButton.Click -= SwitchCameraButton_Click;
            takePictureButton.Click -= TakePictureButton_Click;
            recordVideoButton.Click -= RecordVideoButton_Click;
            surfaceTextureView.SurfaceTextureAvailable -= SurfaceTextureView_SurfaceTextureAvailable;

            StopBackgroundThread();
        }

        private void StopBackgroundThread()
        {
            if (backgroundThread == null) return;

            backgroundThread.QuitSafely();
            try
            {
                backgroundThread.Join();
                backgroundThread = null;
                backgroundHandler = null;
            }
            catch (Exception e)
            {
                System.Diagnostics.Debug.WriteLine($"{e.Message} {e.StackTrace}");
            }
        }

        /// <summary>
        /// This method forces our view to re-create the camera session by changing 'currentLensFacing' and requesting the original value
        /// </summary>
        private void ForceResetLensFacing()
        {
            var targetLensFacing = currentLensFacing;
            currentLensFacing = currentLensFacing == LensFacing.Back ? LensFacing.Front : LensFacing.Back;
            SetLensFacing(targetLensFacing);
        }

        private void SetLensFacing(LensFacing lenseFacing)
        {
            bool shouldRestartCamera = currentLensFacing != lenseFacing;
            currentLensFacing = lenseFacing;
            string cameraId = string.Empty;
            characteristics = null;

            foreach (var id in manager.GetCameraIdList())
            {
                cameraId = id;
                characteristics = manager.GetCameraCharacteristics(id);

                var face = (int)characteristics.Get(CameraCharacteristics.LensFacing);
                if (face == (int)currentLensFacing)
                {
                    break;
                }
            }

            if (characteristics == null) return;

            if (cameraDevice != null)
            {
                try
                {
                    if (!shouldRestartCamera)
                        return;
                    if (cameraDevice.Handle != IntPtr.Zero)
                    {
                        cameraDevice.Close();
                        cameraDevice.Dispose();
                        cameraDevice = null;
                    }
                }
                catch (Exception e)
                {
                    //Ignored
                    System.Diagnostics.Debug.WriteLine(e);
                }
            }

            SetUpCameraOutputs(cameraId);
            ConfigureTransform(surfaceTextureView.Width, surfaceTextureView.Height);
            manager.OpenCamera(cameraId, cameraStateCallback, null);
        }

        private void SetUpCameraOutputs(string selectedCameraId)
        {
            var map = (StreamConfigurationMap)characteristics.Get(CameraCharacteristics.ScalerStreamConfigurationMap);
            if (map == null)
            {
                return;
            }

            // For still image captures, we use the largest available size.
            Size largest = (Size)Collections.Max(Arrays.AsList(map.GetOutputSizes((int)ImageFormatType.Jpeg)),
                new CompareSizesByArea());

            if (imageReader == null)
            {
                imageReader = ImageReader.NewInstance(largest.Width, largest.Height, ImageFormatType.Jpeg, maxImages: 1);
                imageReader.SetOnImageAvailableListener(onImageAvailableListener, backgroundHandler);
            }

            // Find out if we need to swap dimension to get the preview size relative to sensor
            // coordinate.
            var displayRotation = windowManager.DefaultDisplay.Rotation;
            sensorOrientation = (int)characteristics.Get(CameraCharacteristics.SensorOrientation);
            bool swappedDimensions = false;
            switch (displayRotation)
            {
                case SurfaceOrientation.Rotation0:
                case SurfaceOrientation.Rotation180:
                    if (sensorOrientation == 90 || sensorOrientation == 270)
                    {
                        swappedDimensions = true;
                    }
                    break;
                case SurfaceOrientation.Rotation90:
                case SurfaceOrientation.Rotation270:
                    if (sensorOrientation == 0 || sensorOrientation == 180)
                    {
                        swappedDimensions = true;
                    }
                    break;
                default:
                    System.Diagnostics.Debug.WriteLine($"Display rotation is invalid: {displayRotation}");
                    break;
            }

            Point displaySize = new Point();
            windowManager.DefaultDisplay.GetSize(displaySize);
            var rotatedPreviewWidth = surfaceTextureView.Width;
            var rotatedPreviewHeight = surfaceTextureView.Height;
            var maxPreviewWidth = displaySize.X;
            var maxPreviewHeight = displaySize.Y;

            if (swappedDimensions)
            {
                rotatedPreviewWidth = surfaceTextureView.Height;
                rotatedPreviewHeight = surfaceTextureView.Width;
                maxPreviewWidth = displaySize.Y;
                maxPreviewHeight = displaySize.X;
            }

            // Danger, W.R.! Attempting to use too large a preview size could  exceed the camera
            // bus' bandwidth limitation, resulting in gorgeous previews but the storage of
            // garbage capture data.
            previewSize = ChooseOptimalSize(map.GetOutputSizes(Java.Lang.Class.FromType(typeof(SurfaceTexture))),
                rotatedPreviewWidth, rotatedPreviewHeight, maxPreviewWidth,
                maxPreviewHeight, largest);

            // We fit the aspect ratio of TextureView to the size of preview we picked.
            // The commented code handles landscape layouts. This app is portrait only, so this is not needed
            /*
            var orientation = Application.Context.Resources.Configuration.Orientation;
            if (orientation == global::Android.Content.Res.Orientation.Landscape)
            {
                surfaceTextureView.SetAspectRatio(previewSize.Width, previewSize.Height);
            }
            else
            {*/
                surfaceTextureView.SetAspectRatio(previewSize.Height, previewSize.Width);
            /*}*/

            // Check if the flash is supported.
            var available = (bool?)characteristics.Get(CameraCharacteristics.FlashInfoAvailable);
            if (available == null)
            {
                flashSupported = false;
            }
            else
            {
                flashSupported = (bool)available;
            }
            return;
        }

        // Configures the necessary matrix
        // transformation to `surfaceTextureView`.
        // This method should be called after the camera preview size is determined in
        // setUpCameraOutputs and also the size of `surfaceTextureView` is fixed.
        public void ConfigureTransform(int viewWidth, int viewHeight)
        {
            if (null == surfaceTextureView || null == previewSize)
            {
                return;
            }
            var rotation = (int)WindowManager.DefaultDisplay.Rotation;
            Matrix matrix = new Matrix();
            RectF viewRect = new RectF(0, 0, viewWidth, viewHeight);
            RectF bufferRect = new RectF(0, 0, previewSize.Height, previewSize.Width);
            float centerX = viewRect.CenterX();
            float centerY = viewRect.CenterY();
            if ((int)SurfaceOrientation.Rotation90 == rotation || (int)SurfaceOrientation.Rotation270 == rotation)
            {
                bufferRect.Offset(centerX - bufferRect.CenterX(), centerY - bufferRect.CenterY());
                matrix.SetRectToRect(viewRect, bufferRect, Matrix.ScaleToFit.Fill);
                float scale = Math.Max((float)viewHeight / previewSize.Height, (float)viewWidth / previewSize.Width);
                matrix.PostScale(scale, scale, centerX, centerY);
                matrix.PostRotate(90 * (rotation - 2), centerX, centerY);
            }
            else if ((int)SurfaceOrientation.Rotation180 == rotation)
            {
                matrix.PostRotate(180, centerX, centerY);
            }
            surfaceTextureView.SetTransform(matrix);
        }

        private static Size ChooseOptimalSize(Size[] choices, int textureViewWidth,
            int textureViewHeight, int maxWidth, int maxHeight, Size aspectRatio)
        {
            // Collect the supported resolutions that are at least as big as the preview Surface
            var bigEnough = new List<Size>();
            // Collect the supported resolutions that are smaller than the preview Surface
            var notBigEnough = new List<Size>();
            int w = aspectRatio.Width;
            int h = aspectRatio.Height;

            for (var i = 0; i < choices.Length; i++)
            {
                Size option = choices[i];
                if (option.Height == option.Width * h / w)
                {
                    if (option.Width >= textureViewWidth &&
                        option.Height >= textureViewHeight)
                    {
                        bigEnough.Add(option);
                    }
                    else if ((option.Width <= maxWidth) && (option.Height <= maxHeight))
                    {
                        notBigEnough.Add(option);
                    }
                }
            }

            // Pick the smallest of those big enough. If there is no one big enough, pick the
            // largest of those not big enough.
            if (bigEnough.Count > 0)
            {
                return (Size)Collections.Min(bigEnough, new CompareSizesByArea());
            }
            else if (notBigEnough.Count > 0)
            {
                return (Size)Collections.Max(notBigEnough, new CompareSizesByArea());
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("Couldn't find any suitable preview size");
                return choices[0];
            }
        }

        private void OnOpened(CameraDevice cameraDevice)
        {
            this.cameraDevice = cameraDevice;
            surfaceTextureView.SurfaceTexture.SetDefaultBufferSize(previewSize.Width, previewSize.Height);
            previewSurface = new Surface(surfaceTextureView.SurfaceTexture);

            this.cameraDevice.CreateCaptureSession(new List<Surface> { previewSurface, imageReader.Surface }, captureStateSessionCallback, backgroundHandler);
        }

        private void OnDisconnected(CameraDevice cameraDevice)
        {
            // In a real application we may need to handle the user disconnecting external devices.
            // Here we're only worrying about built-in cameras
        }

        private void OnError(CameraDevice cameraDevice, CameraError cameraError)
        {
            // In a real application we should handle errors gracefully
        }

        private void OnPreviewSessionConfigured(CameraCaptureSession session)
        {
            captureSession = session;

            previewRequestBuilder = cameraDevice.CreateCaptureRequest(CameraTemplate.Preview);
            previewRequestBuilder.AddTarget(previewSurface);

            var availableAutoFocusModes = (int[])characteristics.Get(CameraCharacteristics.ControlAfAvailableModes);
            if (availableAutoFocusModes.Any(afMode => afMode == (int)ControlAFMode.ContinuousPicture))
            {
                previewRequestBuilder.Set(CaptureRequest.ControlAfMode, (int)ControlAFMode.ContinuousPicture);
            }
            SetAutoFlash(previewRequestBuilder);

            previewRequest = previewRequestBuilder.Build();

            captureSession.SetRepeatingRequest(previewRequest, cameraCaptureCallback, backgroundHandler);
        }

        public void SetAutoFlash(CaptureRequest.Builder requestBuilder)
        {
            if (flashSupported)
            {
                requestBuilder.Set(CaptureRequest.ControlAeMode, (int)ControlAEMode.OnAutoFlash);
            }
        }
    }
}
{% endhighlight %}

There's a lot to unpack here, so let's get started!

##### OnResume
This is where everything gets started. Every time the user opens or restores our activity, we want to start up our camera preview. To do this we need to do 2 things: start a background thread and initialize the preview. For the background thread we just call our StartBackgroundThread method, which we'll look at in the next section. Before we initialize the preview we need to make sure everything is ready for it. Our camera will need access to the TextureView's SurfaceTexture. It can take a little time for that to become available, especially on first run, so we check if it's available. If it is we can just continue our process, otherwise we add a listener to the SurfaceTextureAvailable event

{% highlight csharp%}
protected override void OnResume()
{
    base.OnResume();
    switchCameraButton.Click += SwitchCameraButton_Click;
    takePictureButton.Click += TakePictureButton_Click;
    recordVideoButton.Click += RecordVideoButton_Click;

    StartBackgroundThread();

    if (surfaceTextureView.IsAvailable)
    {
        ForceResetLensFacing();
    }
    else
    {
        surfaceTextureView.SurfaceTextureAvailable += SurfaceTextureView_SurfaceTextureAvailable;
    }
}

private void SurfaceTextureView_SurfaceTextureAvailable(object sender, TextureView.SurfaceTextureAvailableEventArgs e)
{
    ForceResetLensFacing();
}
{% endhighlight %}

##### Start / Stop Background Thread
These are a couple of straightforward methods that start and stop an Android background thread. The Camera2 API allows use to pass a thread handler into many of our methods and we want to take advantage of that. This allows the camera actions to run without interfering with the user's actions. I don't think it's strictly necessary to use the camera, but that it improves the user's experience. Start is called in OnResume and Stop is called in OnPause.

> This code is taken directly from the Xamarin sample without alteration

{% highlight csharp %}
private void StartBackgroundThread()
{
    backgroundThread = new HandlerThread("CameraBackground");
    backgroundThread.Start();
    backgroundHandler = new Handler(backgroundThread.Looper);
}

private void StopBackgroundThread()
{
    if (backgroundThread == null) return;

    backgroundThread.QuitSafely();
    try
    {
        backgroundThread.Join();
        backgroundThread = null;
        backgroundHandler = null;
    }
    catch (Exception e)
    {
        System.Diagnostics.Debug.WriteLine($"{e.Message} {e.StackTrace}");
    }
}
{% endhighlight %}

##### [ForceRe]SetLensFacing

These methods are where our real preview code starts. SetLenseFacing handles a few important things for us. The first thing it does is retrieve the cameraId and characteristics for our desired LensFacing (Back vs. Front). Both of these will be used during other steps of the process, so it's good to store these into a class field. Next it checks if we already have a preview running for the requested LensFacing. If so nothing needs to be done. If we changed LensFacing or there isn't an existing preview, it stops any existing preview then configures and opens a camera session. 

{% highlight csharp %}
private void SetLensFacing(LensFacing lenseFacing)
{
    bool shouldRestartCamera = currentLensFacing != lenseFacing;
    currentLensFacing = lenseFacing;
    string cameraId = string.Empty;
    characteristics = null;

    foreach (var id in manager.GetCameraIdList())
    {
        cameraId = id;
        characteristics = manager.GetCameraCharacteristics(id);

        var face = (int)characteristics.Get(CameraCharacteristics.LensFacing);
        if (face == (int)currentLensFacing)
        {
            break;
        }
    }

    if (characteristics == null) return;

    if (cameraDevice != null)
    {
        try
        {
            if (!shouldRestartCamera)
                return;
            if (cameraDevice.Handle != IntPtr.Zero)
            {
                cameraDevice.Close();
                cameraDevice.Dispose();
                cameraDevice = null;
            }
        }
        catch (Exception e)
        {
            //Ignored
            System.Diagnostics.Debug.WriteLine(e);
        }
    }

    SetUpCameraOutputs(cameraId);
    ConfigureTransform(surfaceTextureView.Width, surfaceTextureView.Height);
    manager.OpenCamera(cameraId, cameraStateCallback, null);
}
{% endhighlight %}

ForceResetLensFacing is used when we need to restart our preview with the same settings it already had. It switches the currentLensFacing field and calls SetLensFacing with the initial value. This may not always be necessary, but it's good protection in case the situation comes up.

{% highlight csharp %}
/// <summary>
/// This method forces our view to re-create the camera session by changing 'currentLensFacing' and requesting the original value
/// </summary>
private void ForceResetLensFacing()
{
    var targetLensFacing = currentLensFacing;
    currentLensFacing = currentLensFacing == LensFacing.Back ? LensFacing.Front : LensFacing.Back;
    SetLensFacing(targetLensFacing);
}
{% endhighlight %}

##### SetUpCameraOutputs

SetUpCameraOutputs is responsible for configuring our image and preview dimensions as-well-as determining if our requested camera supports flash. There's a lot going on in this method, so we're going to break it into smaller pieces.

> All of the code in this method are adapted from the Xamarin example. Most changes I made were just stylistic, however I allow the front camera whereas their sample does not

The first thing we do is initialize our ImageReader to the correct size. This is what we will use to actually capture the photo. It's not realy a part of the preview process, but I found this to be a good place to make sure it's properly initialized. We create it by finding the largest available JPEG size on the device and create a new instance using those dimensions. We also set the maxImages parameter to 1. This controls how many images the reader can keep active in memory at one time. Since we're planning to save each image to disk immediately we can save memory by only holding one in memory at a time. ImageReader will throw an exception if we try to take a second picture, so we'll need to clear out our image after saving to disk.

{% highlight csharp %}
var map = (StreamConfigurationMap)characteristics.Get(CameraCharacteristics.ScalerStreamConfigurationMap);
if (map == null)
{
    return;
}

// For still image captures, we use the largest available size.
Size largest = (Size)Collections.Max(Arrays.AsList(map.GetOutputSizes((int)ImageFormatType.Jpeg)),
    new CompareSizesByArea());

if (imageReader == null)
{
    imageReader = ImageReader.NewInstance(largest.Width, largest.Height, ImageFormatType.Jpeg, maxImages: 1);
    imageReader.SetOnImageAvailableListener(onImageAvailableListener, backgroundHandler);
}
{% endhighlight %}

Next we need to determine our preview size and set its aspect ratio. Android has a strange setup with its cameras which makes this more complicated than it would seem at first glance: the camera lens can be rotated differently relative to the phone on different devices. For example: the camera could be rotated 90° on a Nexus 5 and 270° on a Samsung Galaxy S7 (those are just made up examples, I don't actually know the orientation of various devices).

{% highlight csharp %}
// Find out if we need to swap dimension to get the preview size relative to sensor
// coordinate.
var displayRotation = windowManager.DefaultDisplay.Rotation;
sensorOrientation = (int)characteristics.Get(CameraCharacteristics.SensorOrientation);
bool swappedDimensions = false;
switch (displayRotation)
{
    case SurfaceOrientation.Rotation0:
    case SurfaceOrientation.Rotation180:
        if (sensorOrientation == 90 || sensorOrientation == 270)
        {
            swappedDimensions = true;
        }
        break;
    case SurfaceOrientation.Rotation90:
    case SurfaceOrientation.Rotation270:
        if (sensorOrientation == 0 || sensorOrientation == 180)
        {
            swappedDimensions = true;
        }
        break;
    default:
        System.Diagnostics.Debug.WriteLine($"Display rotation is invalid: {displayRotation}");
        break;
}

Point displaySize = new Point();
windowManager.DefaultDisplay.GetSize(displaySize);
var rotatedPreviewWidth = surfaceTextureView.Width;
var rotatedPreviewHeight = surfaceTextureView.Height;
var maxPreviewWidth = displaySize.X;
var maxPreviewHeight = displaySize.Y;

if (swappedDimensions)
{
    rotatedPreviewWidth = surfaceTextureView.Height;
    rotatedPreviewHeight = surfaceTextureView.Width;
    maxPreviewWidth = displaySize.Y;
    maxPreviewHeight = displaySize.X;
}

// Danger, W.R.! Attempting to use too large a preview size could  exceed the camera
// bus' bandwidth limitation, resulting in gorgeous previews but the storage of
// garbage capture data.
previewSize = ChooseOptimalSize(map.GetOutputSizes(Java.Lang.Class.FromType(typeof(SurfaceTexture))),
    rotatedPreviewWidth, rotatedPreviewHeight, maxPreviewWidth,
    maxPreviewHeight, largest);

// We fit the aspect ratio of TextureView to the size of preview we picked.
// The commented code handles landscape layouts. This app is portrait only, so this is not needed
/*
var orientation = Application.Context.Resources.Configuration.Orientation;
if (orientation == global::Android.Content.Res.Orientation.Landscape)
{
    surfaceTextureView.SetAspectRatio(previewSize.Width, previewSize.Height);
}
else
{*/
    surfaceTextureView.SetAspectRatio(previewSize.Height, previewSize.Width);
/*}*/
{% endhighlight %}

The last thing we do in this method is check if our camera supports flash. Fortunately, Android provides characteristics for each camera that we can query to check for things like this.

{% highlight csharp %}
// Check if the flash is supported.
var available = (bool?)characteristics.Get(CameraCharacteristics.FlashInfoAvailable);
if (available == null)
{
    flashSupported = false;
}
else
{
    flashSupported = (bool)available;
}
{% endhighlight %}

##### ConfigureTransform
This method is completely pulled from the Xamarin/Google sample code, and is one of the areas I don't fully understand. It's used to set our TextureView's transform, so I believe it works along-side the aspect ratio to make sure our preview appears without stretching or squashing. Fortunately this code is given to us, so we don't need to figure it out every time we want to use the camera.

{% highlight csharp %}
// Configures the necessary matrix
// transformation to `surfaceTextureView`.
// This method should be called after the camera preview size is determined in
// setUpCameraOutputs and also the size of `surfaceTextureView` is fixed.
public void ConfigureTransform(int viewWidth, int viewHeight)
{
    if (null == surfaceTextureView || null == previewSize)
    {
        return;
    }
    var rotation = (int)WindowManager.DefaultDisplay.Rotation;
    Matrix matrix = new Matrix();
    RectF viewRect = new RectF(0, 0, viewWidth, viewHeight);
    RectF bufferRect = new RectF(0, 0, previewSize.Height, previewSize.Width);
    float centerX = viewRect.CenterX();
    float centerY = viewRect.CenterY();
    if ((int)SurfaceOrientation.Rotation90 == rotation || (int)SurfaceOrientation.Rotation270 == rotation)
    {
        bufferRect.Offset(centerX - bufferRect.CenterX(), centerY - bufferRect.CenterY());
        matrix.SetRectToRect(viewRect, bufferRect, Matrix.ScaleToFit.Fill);
        float scale = Math.Max((float)viewHeight / previewSize.Height, (float)viewWidth / previewSize.Width);
        matrix.PostScale(scale, scale, centerX, centerY);
        matrix.PostRotate(90 * (rotation - 2), centerX, centerY);
    }
    else if ((int)SurfaceOrientation.Rotation180 == rotation)
    {
        matrix.PostRotate(180, centerX, centerY);
    }
    surfaceTextureView.SetTransform(matrix);
}
{% endhighlight %}

##### OnOpened

OnOpened is called as the 'success' callback of manager.OpenCamera() and gives us access to the CameraDevice. We take this opportunity to set our TextureView's SurfaceTexture buffer size to match our preview size. Then we start a capture session that will be used for both preview and image capture. The capture session needs access to any surface that will be used, so we pass in our TextureView and ImageReader's respective surfaces.

{% highlight csharp %}
private void OnOpened(CameraDevice cameraDevice)
{
    this.cameraDevice = cameraDevice;
    surfaceTextureView.SurfaceTexture.SetDefaultBufferSize(previewSize.Width, previewSize.Height);
    previewSurface = new Surface(surfaceTextureView.SurfaceTexture);

    this.cameraDevice.CreateCaptureSession(new List<Surface> { previewSurface, imageReader.Surface }, captureStateSessionCallback, backgroundHandler);
}
{% endhighlight %}

##### OnPreviewSessionConfigured

This is the final step for displaying our preview. It's called as the 'success' callback of CreateCaptureSession(). Here we handle the last setup actions needed like activating auto-focus (if available), activating flash (if available) and starting a repeating capture request. The repeating request tells Android to continuously read from the camera and display the results on our preview surface.

> You may ask "Why do we need flash on our preview?", and my answer to that is "I don't really know". It doesn't actually turn the flash on during preview, but for some reason it needs to be set here for flash to work when we take the photo.

{% highlight csharp %}
private void OnPreviewSessionConfigured(CameraCaptureSession session)
{
    captureSession = session;

    previewRequestBuilder = cameraDevice.CreateCaptureRequest(CameraTemplate.Preview);
    previewRequestBuilder.AddTarget(previewSurface);

    var availableAutoFocusModes = (int[])characteristics.Get(CameraCharacteristics.ControlAfAvailableModes);
    if (availableAutoFocusModes.Any(afMode => afMode == (int)ControlAFMode.ContinuousPicture))
    {
        previewRequestBuilder.Set(CaptureRequest.ControlAfMode, (int)ControlAFMode.ContinuousPicture);
    }
    SetAutoFlash(previewRequestBuilder);

    previewRequest = previewRequestBuilder.Build();

    captureSession.SetRepeatingRequest(previewRequest, cameraCaptureCallback, backgroundHandler);
}
{% endhighlight %}

> Note that we're using the cameraCaptureCallback for this request. This seemed weird to me when I first started using the API, as we'll use that same callback for taking our picture. From what I've discovered, this is used here to work with auto-focus and auto-flash as those happen prior to actually taking a picture.

Whew! That was a lot to get through, but we now have a working preview using our device's rear camera! If we run the application with all of this in place we'll see something like this: 

<div class="os-screenshots">
    <picture>
        <source type="image/webp" srcset="/assets/img/android-camera2-trials-and-tribulations/PreviewView.webp">
        <img src="/assets/img/android-camera2-trials-and-tribulations/PreviewView.png" >
    </picture>
</div>

#### The Front Camera

Now that we have the preview working for our back camera, we should get implement our switch camera button to activate the front 'selfie' camera. Fortunately for us, all of our work on the back camera translates to the front and makes this addition very easy.

{% highlight csharp %}
private void SwitchCameraButton_Click(object sender, EventArgs e)
{
    SetLensFacing(currentLensFacing == LensFacing.Back ? LensFacing.Front : LensFacing.Back);
}
{% endhighlight %}

> Seems almost too easy, doesn't it? This is one of those nice areas where prior hard work pays off and makes our life easy. Don't worry, we get into heavy code again while taking the picture 😎

#### The Cleanup

Before we get to taking and especially displaying a photo, we should probably handle cleaning up our state on pause. If we run the app as-is with Logcat attached, we'll notice that the log goes haywire when we background the app. This is because we've left our camera session running and is not meant to run in the background. To fix this we'll update our OnPause method to call a new CloseCamera method.

{% highlight csharp %}
protected override void OnPause()
{
    base.OnPause();
    switchCameraButton.Click -= SwitchCameraButton_Click;
    takePictureButton.Click -= TakePictureButton_Click;
    recordVideoButton.Click -= RecordVideoButton_Click;
    surfaceTextureView.SurfaceTextureAvailable -= SurfaceTextureView_SurfaceTextureAvailable;

    CloseCamera();
    StopBackgroundThread();
}

void CloseCamera()
{
    try
    {
        if (null != captureSession)
        {
            captureSession.Close();
            captureSession = null;
        }
        if (null != cameraDevice)
        {
            cameraDevice.Close();
            cameraDevice = null;
        }
        if (null != imageReader)
        {
            imageReader.Close();
            imageReader = null;
        }
    }
    catch (Exception e)
    {
        System.Diagnostics.Debug.WriteLine($"{e.Message} {e.StackTrace}");
    }
}
{% endhighlight %}

#### Taking a Photo

Now it's time to turn our preview into an actual photo! To start with we're going to add a supporting field and method to our activity, then we'll get into the real code.

In MainActivity_PhotoCapture we'll add an enum and field to track the state of our capture process. We'll use this to deal with the auto focus and auto flash period of photo capture.

{% highlight csharp %}
private MediaCaptorState state = MediaCaptorState.Preview;

enum MediaCaptorState
{
    Preview,
    WaitingLock,
    WaitingPrecapture,
    WaitingNonPrecapture,
    PictureTaken,
}
{% endhighlight %}

We need to deal with sensor orientation when saving our photo (and later when capturing videos), so we'll create a helper method in MainActivity.

{% highlight csharp %}
/// <summary>
/// Sensor orientation is 90 for most devices, or 270 for some devices (eg. Nexus 5X)
/// We have to take that into account and rotate image properly.
/// For devices with orientation of 90, we simply return our mapping from orientations.
/// For devices with orientation of 270, we need to rotate 180 degrees. 
/// </summary>
int GetOrientation(int rotation) => 
            (orientations.Get(rotation) + sensorOrientation + 270) % 360;
{% endhighlight %}

Now it's time to start taking our picture. All of our work for this portion will be in MainActivity_PhotoCapture since it's all photo-specific. 

We'll begin by adding a LockFocus method and calling it from our TakePictureButton_Click method. Here we check to see if our camera supports auto-focus. If it does we'll set an auto-focus trigger to our request and start a new capture, using our cameraCaptureCallback to subscribe to the results. If the camera doesn't support auto-focus, we can just take the picture.

{% highlight csharp %}
private void TakePictureButton_Click(object sender, EventArgs e)
{
    LockFocus();
}

// Lock the focus as the first step for a still image capture.
private void LockFocus()
{
    try
    {
        var availableAutoFocusModes = (int[])characteristics.Get(CameraCharacteristics.ControlAfAvailableModes);

        // Set autofocus if supported
        if (availableAutoFocusModes.Any(afMode => afMode != (int)ControlAFMode.Off))
        {
            previewRequestBuilder.Set(CaptureRequest.ControlAfTrigger, (int)ControlAFTrigger.Start);
            state = MediaCaptorState.WaitingLock;
            // Tell cameraCaptureCallback to wait for the lock.
            captureSession.Capture(previewRequestBuilder.Build(), cameraCaptureCallback,
                    backgroundHandler);
        }
        else
        {
            // If autofocus is not enabled, just capture the image
            CaptureStillPicture();
        }
    }
    catch (CameraAccessException e)
    {
        e.PrintStackTrace();
    }
}
{% endhighlight %}

Next we'll take care of our auto-focus process by implementing ProcessImageCapture. This is called many times during the capture process, and we need to take different actions based on our state. 

The first state we'll handle is WaitingLock. This is the first state we set in LockFocus, and we use it as a first opportunity to check auto-focus. If the auto-focus state is null then everything's ready to go and we can call CaptureStillPicture. Otherwise we want to see if the state is FocusLocked or FocusNotLocked. In those cases we're ready to look at auto-exposure (for flash) as well. If the camera doesn't support auto exposure or if the state is already converged (ready) we can call CaptureStillPicture(). Otherwise we want to call RunPrecaptureSequence() to tell the device to adjust focus and exposure.

{% highlight csharp %}
private void ProcessImageCapture(CaptureResult result)
{
    switch (state)
    {
        case MediaCaptorState.WaitingLock:
            {
                var afState = (int?)result.Get(CaptureResult.ControlAfState);
                if (afState == null)
                {
                    CaptureStillPicture();
                }
                else if ((((int)ControlAFState.FocusedLocked) == afState.Value) ||
                            (((int)ControlAFState.NotFocusedLocked) == afState.Value))
                {
                    // ControlAeState can be null on some devices
                    var aeState = (int?)result.Get(CaptureResult.ControlAeState);
                    if (aeState == null || aeState.Value == ((int)ControlAEState.Converged))
                    {
                        state = MediaCaptorState.PictureTaken;
                        CaptureStillPicture();
                    }
                    else
                    {
                        RunPrecaptureSequence();
                    }
                }
                break;
            }
        ...
    }
}
{% endhighlight %}

Next we'll handle the WaitingPrecapture state. Here we're just waiting until the auto-exposure state is either Precapture or FlashRequired, with a null check just in case. Once that condition is met we just change our state WaitingNonPrecapture to move to the next step.

{% highlight csharp %}
private void ProcessImageCapture(CaptureResult result)
{
    switch (state)
    {
       ...
        case MediaCaptorState.WaitingPrecapture:
            {
                // ControlAeState can be null on some devices
                var aeState = (int?)result.Get(CaptureResult.ControlAeState);
                if (aeState == null ||
                        aeState.Value == ((int)ControlAEState.Precapture) ||
                        aeState.Value == ((int)ControlAEState.FlashRequired))
                {
                    state = MediaCaptorState.WaitingNonPrecapture;
                }
                break;
            }
        ...
    }
}
{% endhighlight %}

Last we'll handle the WaitingNonPrecapture. Here we wait until our auto-exposure state is not Precapture. This means that the device has finished focusing and light balancing and we're ready to call CaptureStillPicture.

{% highlight csharp %}
private void ProcessImageCapture(CaptureResult result)
{
    switch (state)
    {
       ...
        case MediaCaptorState.WaitingNonPrecapture:
            {
                // ControlAeState can be null on some devices
                var aeState = (int?)result.Get(CaptureResult.ControlAeState);
                if (aeState == null || aeState.Value != ((int)ControlAEState.Precapture))
                {
                    state = MediaCaptorState.PictureTaken;
                    CaptureStillPicture();
                }
                break;
            }
    }
}
{% endhighlight %}

Now we want to implement the RunPrecaptureSequence method we called in ProcessImageCapture. This is a short method that sets an auto-exposure trigger and starts a new capture. Without this trigger our auto-flash would not work.

{% highlight csharp %}
public void RunPrecaptureSequence()
{
    try
    {
        // This is how to tell the camera to trigger.
        previewRequestBuilder.Set(CaptureRequest.ControlAePrecaptureTrigger, (int)ControlAEPrecaptureTrigger.Start);
        // Tell captureCallback to wait for the precapture sequence to be set.
        state = MediaCaptorState.WaitingPrecapture;
        captureSession.Capture(previewRequestBuilder.Build(), cameraCaptureCallback, backgroundHandler);
    }
    catch (CameraAccessException e)
    {
        e.PrintStackTrace();
    }
}
{% endhighlight %}

Now we're ready to capture the still image in CaptureStillPicture(). Here we'll create a new capture request using the StillCapture template and add our ImageReader surface as a target. Then we'll set flash and auto-focus to the same settings we used in the preview. Since this is a new request, we also need to deal with orientation again. It's a little different this time but we can use the GetOrientation method we created earlier to help us. Finally we stop and abort the preview captures and start a new one with our stillCaptureBuilder. 

> I've also added code to make a shutter click sound at this point. It's not needed for functionality, but it's something most users will expect

{% highlight csharp %}
public void CaptureStillPicture()
{
    try
    {
        if (null == cameraDevice)
        {
            return;
        }

        // This is the CaptureRequest.Builder that we use to take a picture.
        var stillCaptureBuilder = cameraDevice.CreateCaptureRequest(CameraTemplate.StillCapture);

        stillCaptureBuilder.AddTarget(imageReader.Surface);

        // Use the same AE and AF modes as the preview.
        stillCaptureBuilder.Set(CaptureRequest.ControlAfMode, (int)ControlAFMode.ContinuousPicture);
        SetAutoFlash(stillCaptureBuilder);

        // Orientation
        int rotation = (int)WindowManager.DefaultDisplay.Rotation;
        int orientation = GetOrientation(rotation);
        stillCaptureBuilder.Set(CaptureRequest.JpegOrientation, orientation);

        captureSession.StopRepeating();
        captureSession.AbortCaptures();
        captureSession.Capture(stillCaptureBuilder.Build(), cameraCaptureCallback, null);

        // Play shutter sound to alert user that image was captured
        var am = (AudioManager)GetSystemService(AudioService);
        if (am != null && am.RingerMode == RingerMode.Normal)
        {
            var cameraSound = new MediaActionSound();
            cameraSound.Load(MediaActionSoundType.ShutterClick);
            cameraSound.Play(MediaActionSoundType.ShutterClick);
        }
    }
    catch (CameraAccessException e)
    {
        e.PrintStackTrace();
    }
}
{% endhighlight %}

At this point we've done everything needed to capture an image from the camera and store it in memory. The last things to do are save the image to disk and show it to the user. We'll do both by implementing HandleImageCapture. There isn't a lot special going on here, we're just saving the image to disk. There are a couple things worth calling out, though:

* We need to make sure we call Close on our image. If we don't the ImageReader never frees up resources and will throw an exception if the user attempts a second photo (remember that we set maxImages to 1)
* We need to call UnlockFocus to restore the preview session. This should be done on the UI thread

> We're going to cheat a little showing the image by just asking Android to open the default photo view application with our file.

{% highlight csharp %}
private void HandleImageCaptured(ImageReader imageReader)
{
    Java.IO.FileOutputStream fos = null;
    Java.IO.File imageFile = null;
    var photoSaved = false;
    try
    {
        var image = imageReader.AcquireLatestImage();
        var buffer = image.GetPlanes()[0].Buffer;
        var data = new byte[buffer.Remaining()];
        buffer.Get(data);
        var bitmap = BitmapFactory.DecodeByteArray(data, 0, data.Length);
        var widthGreaterThanHeight = bitmap.Width > bitmap.Height;
        image.Close();

        string imageFileName = Guid.NewGuid().ToString();
        var storageDir = Android.OS.Environment.GetExternalStoragePublicDirectory(Android.OS.Environment.DirectoryPictures);

        var storageFilePath = storageDir + Java.IO.File.Separator + "AndroidCamera2Demo" + Java.IO.File.Separator + "Photos";
        var folder = new Java.IO.File(storageFilePath);
        if (!folder.Exists())
        {
            folder.Mkdirs();
        }

        imageFile = new Java.IO.File(storageFilePath + Java.IO.File.Separator + imageFileName + ".jpg");
        if (imageFile.Exists())
        {
            imageFile.Delete();
        }
        if (imageFile.CreateNewFile())
        {
            fos = new Java.IO.FileOutputStream(imageFile);
            using (var stream = new MemoryStream())
            {
                if (bitmap.Compress(Bitmap.CompressFormat.Jpeg, 100, stream))
                {
                    //We set the data array to the rotated bitmap. 
                    data = stream.ToArray();
                    fos.Write(data);
                }
                else
                {
                    //something went wrong, let's just save the bitmap without rotation.
                    fos.Write(data);
                }
                stream.Close();
                photoSaved = true;
            }
        }
    }
    catch (Exception)
    {
        // In a real application we would handle this gracefully, likely alerting the user to the error
    }
    finally
    {
        if (fos != null) fos.Close();
        RunOnUiThread(UnlockFocus);
    }

    // Request that Android display our image if we successfully saved it
    if (imageFile != null && photoSaved)
    {
        var intent = new Intent(Intent.ActionView);
        var imageUri = Android.Net.Uri.Parse("file://" + imageFile.AbsolutePath);
        intent.SetDataAndType(imageUri, "image/*");
        StartActivity(intent);
    }
}
{% endhighlight %}

Finally we're going to add an UnlockFocus method. This restarts our preview session and the repeating request. After this is complete the user can again see the camera preview.

{% highlight csharp %}
void UnlockFocus()
{
    try
    {
        // Reset the auto-focus trigger
        previewRequestBuilder.Set(CaptureRequest.ControlAfTrigger, (int)ControlAFTrigger.Cancel);
        SetAutoFlash(previewRequestBuilder);
        captureSession.Capture(previewRequestBuilder.Build(), cameraCaptureCallback,
                backgroundHandler);
        // After this, the camera will go back to the normal state of preview.
        state = MediaCaptorState.Preview;
        captureSession.SetRepeatingRequest(previewRequest, cameraCaptureCallback,
                backgroundHandler);
    }
    catch (CameraAccessException e)
    {
        e.PrintStackTrace();
    }
}
{% endhighlight %}

And that's that last thing we need to do for image capture! If you're not looking for video capture you can stop here and ignore the rest of the post. If you're sticking around until the end, lets move on to recording a video.

#### Recording a Video

Recording a video is a much simpler process than taking a picture. We're going to create a MediaRecorder instance tied to our preview surface and tell Android to use that for the video source.

To start with we'll create a few class fields and a helper method for our video's size. The method comes directly from Xamarin's video sample.

{% highlight csharp %}
private MediaRecorder mediaRecorder;
private bool isRecording;
private string videoFileName;

...

Size ChooseVideoSize(Size[] choices)
{
    foreach (Size size in choices)
    {
        if (size.Width == size.Height * 4 / 3 && size.Width <= 1000)
            return size;
    }
    System.Diagnostics.Debug.WriteLine("Couldn't find any suitable video size");
    return choices[choices.Length - 1];
}
{% endhighlight %}

Next we're going to implement the RecordVideoButton_Click method. We want this to start recording if there isn't already an ongoing recording and stop if there is one. Most of the work is done in another method called PrepareMediaRecorder and in the videoSessionStateCallback, but there are a couple interesting things here too:

* We create a new capture session for the recording using both the previewSurface and mediaRecorder.Surface. This is similar to how we set up the preview session using the imageReader.Surface
* mediaRecorder.Stop() can throw an exception if the user records a 0 length video. We don't deal with that here, but it should be handled in a real app
* We always reset the mediaRecorder and close the captureSession when finishing a recording

{% highlight csharp %}
private void RecordVideoButton_Click(object sender, EventArgs e)
{
    if (!isRecording)
    {
        recordVideoButton.Text = "Stop Recording";
        PrepareMediaRecorder();
        cameraDevice.CreateCaptureSession(new List<Surface> { previewSurface, mediaRecorder.Surface }, videoSessionStateCallback, backgroundHandler);
    }
    else
    {
        recordVideoButton.Text = "Record Video";
        isRecording = false;
        if (mediaRecorder != null)
        {
            try
            {
                mediaRecorder.Stop();
                var intent = new Intent(Intent.ActionView);
                intent.AddFlags(ActivityFlags.NewTask);
                intent.SetDataAndType(Android.Net.Uri.Parse(videoFileName), "video/mp4");
                StartActivity(intent);
            }
            catch (Exception)
            {
                // Stop can throw an exception if the user records a 0 length video.This should be handled by deleting the empty file
            }
            finally
            {
                mediaRecorder.Reset();
                captureSession.Close();
            }
        }
    }
}
{% endhighlight %}

Now we need to implement PrepareMediaRecorder. This is where we apply all our settings for our video. This is a fairly straightforward process. I think the only interesting portion is that we're using GetOrientation again to deal with camera rotation.

{% highlight csharp %}
void PrepareMediaRecorder()
{
    if (mediaRecorder == null)
    {
        mediaRecorder = new MediaRecorder();
    }
    else
    {
        mediaRecorder.Reset();
    }

    var map = (StreamConfigurationMap)characteristics.Get(CameraCharacteristics.ScalerStreamConfigurationMap);
    if (map == null)
    {
        return;
    }

    videoFileName = Guid.NewGuid().ToString();

    var storageDir = Android.OS.Environment.GetExternalStoragePublicDirectory(Android.OS.Environment.DirectoryMovies);
    var storageFilePath = storageDir + Java.IO.File.Separator + "AndroidCamera2Demo" + Java.IO.File.Separator + "Videos" + Java.IO.File.Separator;
    videoFileName = storageFilePath + videoFileName;

    var file = new Java.IO.File(storageFilePath);
    if (!file.Exists())
    {
        file.Mkdirs();
    }

    mediaRecorder.SetAudioSource(AudioSource.Mic);
    mediaRecorder.SetVideoSource(VideoSource.Surface);
    mediaRecorder.SetOutputFormat(OutputFormat.Mpeg4);
    mediaRecorder.SetOutputFile(videoFileName);
    mediaRecorder.SetVideoEncodingBitRate(10000000);
    mediaRecorder.SetVideoFrameRate(30);
    var videoSize = ChooseVideoSize(map.GetOutputSizes(Java.Lang.Class.FromType(typeof(MediaRecorder))));
    mediaRecorder.SetVideoEncoder(VideoEncoder.H264);
    mediaRecorder.SetAudioEncoder(AudioEncoder.Aac);
    mediaRecorder.SetVideoSize(videoSize.Width, videoSize.Height);
    int rotation = (int)WindowManager.DefaultDisplay.Rotation;
    mediaRecorder.SetOrientationHint(GetOrientation(rotation));
    mediaRecorder.Prepare();
}
{% endhighlight %}

Finally we'll implement the OnVideoSessionConfigured method. Here we create a new Preview capture request and set the auto-focus to ContinuousVideo (if available). We then start a repeating request for our new request then tell the mediaRecorder to start recording.

{% highlight csharp %}
private void OnVideoSessionConfigured(CameraCaptureSession session)
{
    var recordRequestBuilder = cameraDevice.CreateCaptureRequest(CameraTemplate.Preview);
    recordRequestBuilder.AddTarget(previewSurface);
    recordRequestBuilder.AddTarget(mediaRecorder.Surface);

    var availableAutoFocusModes = (int[])characteristics.Get(CameraCharacteristics.ControlAfAvailableModes);
    if (availableAutoFocusModes.Any(afMode => afMode == (int)ControlAFMode.ContinuousVideo))
    {
        previewRequestBuilder.Set(CaptureRequest.ControlAfMode, (int)ControlAFMode.ContinuousVideo);
    }

    captureSession.Close();
    captureSession = session;
    captureSession.SetRepeatingRequest(recordRequestBuilder.Build(), null, null);

    mediaRecorder.Start();
    isRecording = true;
}
{% endhighlight %}

### Conclusion

If you made it this far, congratulations! We're finally done creating a basic app that uses the Android Camera2 API! Hopefully you leave this post with a greater understanding than when you started. There's still plenty more to learn about Camera2 if you're interested in going into more depth or playing with other features, but I think this is enough to get started with (and this post is long enough as it is 😄).