package com.screenguard.flutter_screenguard;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;

import com.screenguard.flutter_screenguard.helper.ScreenGuardHelper;
import com.screenguard.flutter_screenguard.model.ScreenGuardBlurData;
import com.screenguard.flutter_screenguard.model.ScreenGuardColorData;
import com.screenguard.flutter_screenguard.model.ScreenGuardImageData;

import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterScreenguardPlugin */
public class FlutterScreenguardPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity

  private MethodChannel channel;
  private MethodChannel screenshotChannel;
  private MethodChannel screenRecordingChannel;

  private WindowManager windowManager;
  private View overlayView;

  private FlutterPluginBinding binding;
  private Activity currentActivity;

  private Context currentContext;
  private static Handler mHandlerBlockScreenShot = new Handler(Looper.getMainLooper());

  public static final String REGISTER = "register";
  public static final String REGISTER_BLUR_VIEW = "registerWithBlurView";
  public static final String REGISTER_IMAGE_VIEW = "registerWithImage";
  public static final String REGISTER_WITHOUT_EFFECT = "registerWithoutEffect";
  public static final String REGISTER_SCREENSHOT_EVT = "registerScreenshotEventListener";
  public static final String REGISTER_SCREEN_RECORD_EVT = "registerScreenRecordingEventListener";
  public static final String UNREGISTER = "unregister";
  public static final String ON_SCREEN_RECORDING_EVT = "onScreenRecordingCaptured";
  public static final String DEACTIVATE_SCREEN_RECORDING_EVT = "deactivateScreenRecordingEventListener";
  public static final String ON_SCREENSHOT_EVT = "onScreenshotCaptured";
  public static final String DEACTIVATE_SCREENSHOT_EVT = "deactivateScreenshotEventListener";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_screenguard");
    channel.setMethodCallHandler(this);

    screenshotChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(),
            "flutter_screenguard_screenshot_event");
    screenshotChannel.setMethodCallHandler(this);

    screenRecordingChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(),
            "flutter_screenguard_screen_recording_event");
    screenRecordingChannel.setMethodCallHandler(this);
    binding = flutterPluginBinding;

    currentContext = flutterPluginBinding.getApplicationContext();

    Application application = (Application) flutterPluginBinding.getApplicationContext();

    application.registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
      @Override
      public void onActivityCreated(Activity activity, Bundle savedInstanceState) { }

      @Override
      public void onActivityStarted(Activity activity) {
        currentActivity = activity;
      }

      @Override
      public void onActivityResumed(Activity activity) {
        currentActivity = activity;
      }

      @Override
      public void onActivityPaused(Activity activity) { }

      @Override
      public void onActivityStopped(Activity activity) { }

      @Override
      public void onActivitySaveInstanceState(Activity activity, Bundle outState) { }

      @Override
      public void onActivityDestroyed(Activity activity) {
        if (currentActivity == activity) {
          currentActivity = null;
        }
      }
    });
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    String method = call.method;
    int timeAfterResume;
    switch (method) {
      case REGISTER:
        String color = (String)
                ScreenGuardHelper.getData(call,"color");
        timeAfterResume = Integer.parseInt(
                Objects.requireNonNull(ScreenGuardHelper.getData(call, "timeAfterResume")).toString());
        if (color != null) {
          currentActivity.runOnUiThread(() -> {
            ScreenGuardColorData data = new ScreenGuardColorData(
                    color,
                    timeAfterResume
            );
            activateShield(data);
          });
        }
        result.success(FlutterScreenguardPlugin.class + ":" + REGISTER + " success");
        break;
      case REGISTER_BLUR_VIEW:
        int radius = Integer.parseInt(Objects.requireNonNull(ScreenGuardHelper.getData(call, "radius")).toString());
        timeAfterResume = Integer.parseInt(
                Objects.requireNonNull(ScreenGuardHelper.getData(call, "timeAfterResume")).toString());
        currentActivity.runOnUiThread(() -> {
            String localPath = Objects.requireNonNull(ScreenGuardHelper.getData(call, "url")).toString();
            ScreenGuardBlurData data = new ScreenGuardBlurData(
                    radius,
                    localPath,
                    timeAfterResume
            );
            activateShieldWithBlurView(data);
        });

        result.success(FlutterScreenguardPlugin.class + ":" + REGISTER_BLUR_VIEW + " success");
        break;
      case REGISTER_IMAGE_VIEW:
        result.success(FlutterScreenguardPlugin.class + ":" + REGISTER_IMAGE_VIEW + " success");
        break;
      case REGISTER_WITHOUT_EFFECT:
        activateShieldWithoutEffect();
        result.success(FlutterScreenguardPlugin.class + ":" + REGISTER_WITHOUT_EFFECT + " success");
        break;
      case REGISTER_SCREEN_RECORD_EVT:
        result.success(FlutterScreenguardPlugin.class + ":" + REGISTER_SCREEN_RECORD_EVT + " success");
        break;
      case UNREGISTER:
        deactivateShield();
        result.success(FlutterScreenguardPlugin.class + ":" + UNREGISTER + " success");
        break;
      case DEACTIVATE_SCREEN_RECORDING_EVT:
        result.success("deactivate screen recording success");
        break;
      case REGISTER_SCREENSHOT_EVT:
        result.success(FlutterScreenguardPlugin.class + ":" + REGISTER_SCREENSHOT_EVT + " success");
        break;
      case DEACTIVATE_SCREENSHOT_EVT:
        result.success("deactivate screenshot success");
        break;
    }
  }


  private void activateShieldWithBlurView(ScreenGuardBlurData data) {
    try {
      if (mHandlerBlockScreenShot == null) {
        mHandlerBlockScreenShot = new Handler(Looper.getMainLooper());
      }
      if (currentContext == null) {
        currentContext = binding.getApplicationContext();
      }

      if (currentActivity.getClass() == ScreenGuardColorActivity.class) {
        deactivateShield();
      }
      if (mHandlerBlockScreenShot != null) {
        mHandlerBlockScreenShot.post(() -> currentActivity.getWindow().setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE));
      }
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        Intent intent = new Intent(
            currentActivity,
            ScreenGuardColorActivity.class);
        intent.putExtra(ScreenGuardBlurData.class.getName(), data);
        currentActivity.startActivity(intent);

      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  private void activateShieldWithoutEffect() {
    try {
      if (mHandlerBlockScreenShot == null) {
        mHandlerBlockScreenShot = new Handler(Looper.getMainLooper());
      }
      if (currentActivity != null) {
        mHandlerBlockScreenShot.post(() -> currentActivity.getWindow().setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE));
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  private void deactivateShield() {
    try {
      if (mHandlerBlockScreenShot == null) {
        mHandlerBlockScreenShot = new Handler(Looper.getMainLooper());
      }
      if (currentActivity == null) {
          throw new NullPointerException("Current Activity is null!");
      }
      if (Build.VERSION.SDK_INT >= 33) {
        if (currentActivity.getLocalClassName().equals(ScreenGuardColorActivity.class.getName())) {
          currentActivity.finish();
        }
      } else {
        currentContext.sendBroadcast(
          new Intent(ScreenGuardColorActivity.SCREENGUARD_COLOR_ACTIVITY_CLOSE));
      }
      mHandlerBlockScreenShot.post(() -> currentActivity
          .getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SECURE));
      mHandlerBlockScreenShot = null;
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  private void activateShield(ScreenGuardColorData data) {
    try {
      if (mHandlerBlockScreenShot == null) {
        mHandlerBlockScreenShot = new Handler(Looper.getMainLooper());
      }
      if (currentActivity == null) {
        return;
      }
      mHandlerBlockScreenShot.post(() -> currentActivity.getWindow().setFlags(
          WindowManager.LayoutParams.FLAG_SECURE,
          WindowManager.LayoutParams.FLAG_SECURE));
      currentActivity.runOnUiThread(() -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          Intent intent = new Intent(
              currentActivity,
              ScreenGuardColorActivity.class);
          intent.putExtra(ScreenGuardColorData.class.getName(), data);

          intent.setFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);

          currentActivity.startActivity(intent);
        }
      });
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  private void activateShieldWithImage(ScreenGuardImageData data) {
    try {
      if (mHandlerBlockScreenShot == null) {
        mHandlerBlockScreenShot = new Handler(Looper.getMainLooper());
      }

      if (currentActivity == null) {
        return;
      }
      if (currentActivity.getClass() == ScreenGuardColorActivity.class) {
        deactivateShield();
      }
      if (mHandlerBlockScreenShot != null) {
        mHandlerBlockScreenShot.post(() -> currentActivity.getWindow().setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE));
      }
      currentActivity.runOnUiThread(() -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          Intent intent = new Intent(
              currentActivity,
              ScreenGuardColorActivity.class);

          intent.putExtra(ScreenGuardImageData.class.getName(), data);
          currentActivity.startActivity(intent);
        }
      });
    } catch (Exception e) {
//      e.printStackTrace();
    }
  }

  private void registerRecordingEvent() {
    // if (mScreenGuard == null) {
    // mScreenGuard = new ScreenGuard(
    // currentReactContext,
    // (url) -> currentReactContext.getJSModule(
    // DeviceEventManagerModule.RCTDeviceEventEmitter.class
    // ).emit(eventName, url)
    // );
    // }
    // mScreenGuard.register();
  }

  private void registerScreenshotEvent() {
    // if (mScreenGuard == null) {
    // mScreenGuard = new ScreenGuard(
    // currentReactContext,
    // (url) -> currentReactContext.getJSModule(
    // DeviceEventManagerModule.RCTDeviceEventEmitter.class
    // ).emit(eventName, url)
    // );
    // }
    // mScreenGuard.register();
    // Keep: Required for RN built in Event Emitter Calls.
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    currentActivity = null;
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    currentActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    currentActivity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    currentActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    currentActivity = null;
  }

}
