package com.screenguard.flutter_screenguard;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.database.ContentObserver;
import android.os.Handler;
import android.os.HandlerThread;
import android.provider.MediaStore;

import java.util.Map;


public class ScreenGuardListener {

    private final ContentResolver mContentResolver;
    private final ContentObserver mContentObserver;

    public ScreenGuardListener(Context context, Boolean getScreenShot, Activity activity, Listener listener) {
        HandlerThread mHandlerThread = new HandlerThread("ScreenGuardListener");
        mHandlerThread.start();
        Handler mHandler = new Handler(mHandlerThread.getLooper());
        mContentResolver = context.getContentResolver();
        mContentObserver = new ScreenGuardObserver(
                context, activity, mHandler, listener, getScreenShot);
    }

    public void register() {
        mContentResolver.unregisterContentObserver(mContentObserver);
        mContentResolver.registerContentObserver(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                true,
                mContentObserver
        );
    }

    public void unregister() {
        mContentResolver.unregisterContentObserver(mContentObserver);
    }

    public interface Listener {
        void onSnap(Map<String, Object> map);
    }
}