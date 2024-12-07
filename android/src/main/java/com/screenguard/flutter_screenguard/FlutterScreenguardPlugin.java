package com.screenguard.flutter_screenguard;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;

import androidx.annotation.NonNull;

import com.screenguard.flutter_screenguard.helper.ScreenGuardHelper;
import com.screenguard.flutter_screenguard.model.ScreenGuardBlurData;
import com.screenguard.flutter_screenguard.model.ScreenGuardColorData;
import com.screenguard.flutter_screenguard.model.ScreenGuardImageData;

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

  private ScreenGuardListener mScreenGuardScreenshotListener;
  private ScreenGuardListener mScreenGuardScreenRecordingListener;

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
  public static final String UNREGISTER_SCREEN_RECORDING_EVT = "unregisterScreenRecordingEventListener";
  public static final String ON_SCREENSHOT_EVT = "onScreenshotCaptured";
  public static final String UNREGISTER_SCREENSHOT_EVT = "unregisterScreenshotEventListener";

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
          final View currentView =
                  currentActivity.getWindow().getDecorView().getRootView();
          Bitmap bitmap = ScreenGuardHelper.captureView(currentView);

          String url = ScreenGuardHelper.saveBitmapToFile(currentContext, bitmap);

            ScreenGuardBlurData data = new ScreenGuardBlurData(
                    radius,
                    url,
                    timeAfterResume
            );
            activateShieldWithBlurView(data);
        });

        result.success(FlutterScreenguardPlugin.class + ":" + REGISTER_BLUR_VIEW + " success");
        break;
      case REGISTER_IMAGE_VIEW:
        timeAfterResume = Integer.parseInt(
                Objects.requireNonNull(ScreenGuardHelper.getData(call, "timeAfterResume")).toString());

        String uri = (String)
                ScreenGuardHelper.getData(call,"uri");
        color = (String)
                ScreenGuardHelper.getData(call,"color");
        double height = Double.parseDouble(
                Objects.requireNonNull(ScreenGuardHelper.getData(call, "height")).toString()
        );
        double width = Double.parseDouble(
                Objects.requireNonNull(ScreenGuardHelper.getData(call, "width")).toString()
        );

        int alignmentIndex = Integer.parseInt(
                Objects.requireNonNull(ScreenGuardHelper.getData(call, "alignment")).toString());

        currentActivity.runOnUiThread(() -> {
            ScreenGuardImageData  data = new ScreenGuardImageData(
                    color,
                    uri,
                    width,
                    height,
                    alignmentIndex,
                    timeAfterResume
            );
            activateShieldWithImage(data);
        });
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
      case UNREGISTER_SCREEN_RECORDING_EVT:
        if (mScreenGuardScreenRecordingListener != null) {
          mScreenGuardScreenRecordingListener.unregister();
          mScreenGuardScreenRecordingListener = null;
        }

        result.success("deactivate screen recording success");
        break;
      case REGISTER_SCREENSHOT_EVT:
        boolean isCaptureScreenshot =
                Boolean.parseBoolean(
                        Objects.requireNonNull(ScreenGuardHelper.getData(call,"getScreenshotData")).toString()
                );
        registerScreenShotEventListener(isCaptureScreenshot);
        result.success(FlutterScreenguardPlugin.class + ":" + REGISTER_SCREENSHOT_EVT + " success");
        break;
      case UNREGISTER_SCREENSHOT_EVT:
        if (mScreenGuardScreenshotListener != null) {
          mScreenGuardScreenshotListener.unregister();
          mScreenGuardScreenshotListener = null;
        }
        result.success("deactivate screenshot success");
        break;
    }
  }
  private void registerScreenRecordingEventListener() {
    if (mScreenGuardScreenRecordingListener == null) {
      mScreenGuardScreenRecordingListener  =
              new ScreenGuardListener(currentContext, false, currentActivity, map -> {
                screenRecordingChannel.invokeMethod(ON_SCREEN_RECORDING_EVT, map);
              });
    }
    mScreenGuardScreenRecordingListener.register();
  }

  private void registerScreenShotEventListener(boolean isCaptureScreenshotFile) {
    if (mScreenGuardScreenshotListener == null) {
      mScreenGuardScreenshotListener =
              new ScreenGuardListener(currentContext, isCaptureScreenshotFile, currentActivity, map -> {
                screenshotChannel.invokeMethod(ON_SCREENSHOT_EVT, map);
              });
    }
    mScreenGuardScreenshotListener.register();
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
      Log.e(REGISTER_BLUR_VIEW, e.getMessage());
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
      Log.e(REGISTER_WITHOUT_EFFECT, e.getMessage());
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
      Log.e(UNREGISTER, e.getMessage());
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
      Log.e(REGISTER, e.getMessage());
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
      Log.e(REGISTER_IMAGE_VIEW, e.getMessage());
    }
  }

  private void registerRecordingEvent() {
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
