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

import android.annotation.SuppressLint;

import androidx.annotation.NonNull;

import com.screenguard.flutter_screenguard.helper.ScreenGuardHelper;
import com.screenguard.flutter_screenguard.model.ScreenGuardBlurData;
import com.screenguard.flutter_screenguard.model.ScreenGuardColorData;
import com.screenguard.flutter_screenguard.model.ScreenGuardImageData;

import android.content.SharedPreferences;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
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

  private ScreenGuardListener mScreenGuardScreenshotListener;

  private FlutterPluginBinding binding;
  private Activity currentActivity;

  private Context currentContext;
  private static Handler mHandlerBlockScreenShot = new Handler(Looper.getMainLooper());

  public static final String ACTIVATE_SHIELD = "activateShield";
  public static final String ACTIVATE_SHIELD_BLUR = "activateShieldWithBlurView";
  public static final String ACTIVATE_SHIELD_IMAGE = "activateShieldWithImage";
  public static final String ACTIVATE_SHIELD_NO_EFFECT = "activateShieldWithoutEffect";
  public static final String REGISTER_SCREENSHOT_EVT = "registerScreenshotEventListener";
  public static final String REGISTER_SCREEN_RECORD_EVT = "registerScreenRecordingEventListener";
  public static final String DEACTIVATE_SHIELD = "deactivateShield";
  public static final String ON_SCREEN_RECORDING_EVT = "onScreenRecordingCaptured";
  public static final String UNREGISTER_SCREEN_RECORDING_EVT = "unregisterScreenRecordingEventListener";
  public static final String ON_SCREENSHOT_EVT = "onScreenshotCaptured";
  public static final String UNREGISTER_SCREENSHOT_EVT = "unregisterScreenshotEventListener";
  public static final String GET_SCREENGUARD_LOGS = "getScreenGuardLogs";
  public static final String INIT_SETTINGS = "initSettings";

  private Map<String, Object> mConfigs;
  private int mCurrentScreenshotCount = 0;

  private static final String PREFS_NAME = "screenguard_prefs";
  private static final String PREF_LOGS = "screenguard_logs";

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
      public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
      }

      @Override
      public void onActivityStarted(Activity activity) {
        currentActivity = activity;
      }

      @Override
      public void onActivityResumed(Activity activity) {
        currentActivity = activity;
      }

      @Override
      public void onActivityPaused(Activity activity) {
        // Show overlay when app goes to background
        ScreenGuardOverlay.getInstance().showPendingOverlay();
      }

      @Override
      public void onActivityStopped(Activity activity) {
      }

      @Override
      public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
      }

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
    switch (method) {
      case ACTIVATE_SHIELD:
        String color = (String) ScreenGuardHelper.getData(call, "color");
        int timeAfterResume = getTimeAfterResume();
        if (color != null) {
          currentActivity.runOnUiThread(() -> {
            ScreenGuardColorData data = new ScreenGuardColorData(
                color,
                timeAfterResume);
            activateShield(data);
          });
        }
        result.success(FlutterScreenguardPlugin.class + ":" + ACTIVATE_SHIELD + " success");
        break;
      case ACTIVATE_SHIELD_BLUR:
        int radius = Integer.parseInt(Objects.requireNonNull(ScreenGuardHelper.getData(call, "radius")).toString());
        int blurTimeAfterResume = getTimeAfterResume();
        currentActivity.runOnUiThread(() -> {
          String localPath = Objects.requireNonNull(ScreenGuardHelper.getData(call, "localImagePath")).toString();
          ScreenGuardBlurData data = new ScreenGuardBlurData(
              radius,
              localPath,
              blurTimeAfterResume);
          activateShieldWithBlurView(data);
        });
        result.success(FlutterScreenguardPlugin.class + ":" + ACTIVATE_SHIELD_BLUR + " success");
        break;
      case ACTIVATE_SHIELD_IMAGE:
        int imageTimeAfterResume = getTimeAfterResume();
        String uri = (String) ScreenGuardHelper.getData(call, "uri");
        color = (String) ScreenGuardHelper.getData(call, "color");
        double height = Double.parseDouble(
            Objects.requireNonNull(ScreenGuardHelper.getData(call, "height")).toString());
        double width = Double.parseDouble(
            Objects.requireNonNull(ScreenGuardHelper.getData(call, "width")).toString());
        int alignmentIndex = Integer.parseInt(
            Objects.requireNonNull(ScreenGuardHelper.getData(call, "alignment")).toString());
        currentActivity.runOnUiThread(() -> {
          ScreenGuardImageData data = new ScreenGuardImageData(
              color,
              uri,
              width,
              height,
              alignmentIndex,
              imageTimeAfterResume);
          activateShieldWithImage(data);
        });
        result.success(FlutterScreenguardPlugin.class + ":" + ACTIVATE_SHIELD_IMAGE + " success");
        break;
      case ACTIVATE_SHIELD_NO_EFFECT:
        activateShieldWithoutEffect();
        result.success(FlutterScreenguardPlugin.class + ":" + ACTIVATE_SHIELD_NO_EFFECT + " success");
        break;
      case DEACTIVATE_SHIELD:
        deactivateShield();
        result.success(FlutterScreenguardPlugin.class + ":" + DEACTIVATE_SHIELD + " success");
        break;
      case UNREGISTER_SCREENSHOT_EVT:
        if (mScreenGuardScreenshotListener != null) {
          mScreenGuardScreenshotListener.unregister();
          mScreenGuardScreenshotListener = null;
        }
        result.success("deactivate screenshot success");
        break;
      case GET_SCREENGUARD_LOGS:
        double maxCount = Double.parseDouble(
            Objects.requireNonNull(ScreenGuardHelper.getData(call, "maxCount")).toString());
        getScreenGuardLogs(maxCount, result);
        break;
      case INIT_SETTINGS:
        initSettings(call.arguments(), result);
        break;
    }
  }

  private int getTimeAfterResume() {
    if (mConfigs != null && mConfigs.containsKey("timeAfterResume")) {
      return ((Number) mConfigs.get("timeAfterResume")).intValue();
    }
    return 1000; // default
  }

  private void initSettings(Object arguments, Result result) {
    if (!(arguments instanceof Map)) {
      result.error("INVALID_ARGUMENTS", "Arguments must be a Map", null);
      return;
    }
    mConfigs = (Map<String, Object>) arguments;

    if (currentActivity != null) {
      boolean enableCapture = mConfigs.containsKey("enableCapture") && (boolean) mConfigs.get("enableCapture");
      boolean enableRecord = mConfigs.containsKey("enableRecord") && (boolean) mConfigs.get("enableRecord");
      boolean getScreenshotPath = mConfigs.containsKey("getScreenshotPath")
          && (boolean) mConfigs.get("getScreenshotPath");

      boolean displayScreenguardOverlayAndroid = true;
      if (mConfigs.containsKey("displayScreenguardOverlayAndroid")) {
        displayScreenguardOverlayAndroid = (boolean) mConfigs.get("displayScreenguardOverlayAndroid");
      }
      ScreenGuardOverlay.getInstance().setEnabled(displayScreenguardOverlayAndroid);

      currentActivity.runOnUiThread(() -> {
        if (enableCapture || enableRecord) {
          currentActivity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
        } else {
          currentActivity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SECURE);
        }
      });

      registerScreenShotEventListener(getScreenshotPath);

      if (Build.VERSION.SDK_INT >= 35) {
        registerScreenRecordingCallback();
      }
    }
    logAction("init", false);
    result.success(null);
  }

  private void registerScreenRecordingCallback() {
    if (Build.VERSION.SDK_INT >= 35) {
      if (currentActivity != null) {
        currentActivity.getWindowManager().addScreenRecordingCallback(currentActivity
            .getMainExecutor(), state -> {
              boolean isRecording = state > 0;
              Map<String, Object> map = new HashMap<>();
              map.put("isRecording", isRecording);
              Map<String, Object> activationStatus = new HashMap<>();
              activationStatus.put("method", getCurrentMethod());
              activationStatus.put("isActivated", ScreenGuardOverlay.getInstance().isActivated());
              map.put("activationStatus", activationStatus);
              screenRecordingChannel.invokeMethod(ON_SCREEN_RECORDING_EVT, map);
              logAction(isRecording ? "recording_start" : "recording_stop", true);
            });
      }
    }
  }

  private void logAction(String action, boolean isProtected) {
    if (mConfigs != null && mConfigs.containsKey("trackingLog") && !((boolean) mConfigs.get("trackingLog"))) {
      return;
    }

    try {
      SharedPreferences shardPref = currentContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
      String logsStr = shardPref.getString(PREF_LOGS, "[]");
      JSONArray logs = new JSONArray(logsStr);

      JSONObject logEntry = new JSONObject();
      logEntry.put("timestamp", System.currentTimeMillis());
      logEntry.put("action", action);
      logEntry.put("isProtected", isProtected);
      logEntry.put("method", "");

      logs.put(logEntry);

      // Limit to last 1000 logs
      if (logs.length() > 1000) {
        JSONArray newLogs = new JSONArray();
        for (int i = logs.length() - 1000; i < logs.length(); i++) {
          newLogs.put(logs.get(i));
        }
        logs = newLogs;
      }

      shardPref.edit().putString(PREF_LOGS, logs.toString()).apply();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  public void getScreenGuardLogs(double maxCount, Result result) {
    try {
      SharedPreferences shardPref = currentContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
      String logsStr = shardPref.getString(PREF_LOGS, "[]");
      JSONArray logs = new JSONArray(logsStr);

      int count = (int) maxCount;
      if (count > logs.length()) {
        count = logs.length();
      }

      List<Map<String, Object>> resultList = new ArrayList<>();
      int startIndex = Math.max(0, logs.length() - count);

      for (int i = startIndex; i < logs.length(); i++) {
        JSONObject log = logs.getJSONObject(i);
        Map<String, Object> map = new HashMap<>();
        if (log.has("timestamp"))
          map.put("timestamp", log.getDouble("timestamp"));
        if (log.has("action"))
          map.put("action", log.getString("action"));
        if (log.has("isProtected"))
          map.put("isProtected", log.getBoolean("isProtected"));
        if (log.has("method"))
          map.put("method", log.getString("method"));
        resultList.add(map);
      }
      result.success(resultList);
    } catch (Exception e) {
      result.error("GET_LOGS_ERROR", e.getMessage(), null);
    }
  }

  private String getCurrentMethod() {
    ScreenGuardOverlay.OverlayType type = ScreenGuardOverlay.getInstance().getPendingType();
    switch (type) {
      case BLUR:
        return "blur";
      case IMAGE:
        return "image";
      case COLOR:
        return "color";
      default:
        return "";
    }
  }

  private void registerScreenShotEventListener(boolean isCaptureScreenshotFile) {
    if (mScreenGuardScreenshotListener == null) {
      mScreenGuardScreenshotListener = new ScreenGuardListener(currentContext, isCaptureScreenshotFile, currentActivity,
          map -> {
            int limitCount = 0;
            if (mConfigs != null && mConfigs.containsKey("limitCaptureEvtCount")) {
              limitCount = ((Number) mConfigs.get("limitCaptureEvtCount")).intValue();
            }

            if (limitCount > 0 && mCurrentScreenshotCount >= limitCount) {
              return;
            }

            mCurrentScreenshotCount++;
            logAction("screenshot_taken", true);

            Map<String, Object> activationStatus = new HashMap<>();
            activationStatus.put("method", getCurrentMethod());
            activationStatus.put("isActivated", ScreenGuardOverlay.getInstance().isActivated());
            map.put("activationStatus", activationStatus);

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
      if (currentActivity == null) {
        return;
      }

      ScreenGuardOverlay.getInstance().hide();

      mHandlerBlockScreenShot.post(() -> currentActivity.getWindow().setFlags(
          WindowManager.LayoutParams.FLAG_SECURE,
          WindowManager.LayoutParams.FLAG_SECURE));

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        Bitmap bitmap = ScreenGuardHelper.loadBitmapFromPath(data.bitmapPath);
        ScreenGuardOverlay.getInstance().prepareBlur(
            currentActivity,
            bitmap,
            data.radius,
            data.timeAfterResume);
        logAction("activate_blur", true);
      }
    } catch (Exception e) {
      Log.e("activateShieldWithView", e.getMessage() != null ? e.getMessage() : "Unknown error");
    }
  }

  private void activateShieldWithoutEffect() {
    try {
      if (mHandlerBlockScreenShot == null) {
        mHandlerBlockScreenShot = new Handler(Looper.getMainLooper());
      }
      mHandlerBlockScreenShot.post(() -> currentActivity.getWindow().setFlags(
          WindowManager.LayoutParams.FLAG_SECURE,
          WindowManager.LayoutParams.FLAG_SECURE));
      logAction("activate_no_effect", true);
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

      // Hide overlay
      ScreenGuardOverlay.getInstance().hide();

      mHandlerBlockScreenShot.postDelayed(() -> currentActivity
          .getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SECURE), 400);

      mHandlerBlockScreenShot = null;
      logAction("deactivate", false);
    } catch (Exception e) {
      Log.e("deactivateShield", e.getMessage() != null ? e.getMessage() : "Unknown error");
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
          ScreenGuardOverlay.getInstance().prepareColor(
              currentActivity,
              data.backgroundColor,
              data.timeAfterResume);
          logAction("activate_color", true);
        }
      });
    } catch (Exception e) {
      Log.e("activateShield", e.getMessage() != null ? e.getMessage() : "Unknown error");
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

      ScreenGuardOverlay.getInstance().hide();

      mHandlerBlockScreenShot.post(() -> currentActivity.getWindow().setFlags(
          WindowManager.LayoutParams.FLAG_SECURE,
          WindowManager.LayoutParams.FLAG_SECURE));

      currentActivity.runOnUiThread(() -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          int alignmentIndex = 4; // center default
          if (data.position != null) {
            alignmentIndex = data.position.ordinal();
          }
          ScreenGuardOverlay.getInstance().prepareImage(
              currentActivity,
              data.imageUrl,
              data.width,
              data.height,
              alignmentIndex,
              data.backgroundColor,
              data.timeAfterResume);
          logAction("activate_image", true);
        }
      });
    } catch (Exception e) {
      Log.e("activateShieldWithImage", e.getMessage() != null ? e.getMessage() : "Unknown error");
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
