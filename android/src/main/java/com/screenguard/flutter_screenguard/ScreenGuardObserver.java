package com.screenguard.flutter_screenguard;

import android.app.Activity;
import android.content.Context;
import android.database.ContentObserver;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.view.View;

import com.screenguard.flutter_screenguard.helper.ScreenGuardHelper;

import java.util.Collections;
import java.util.Map;


public class ScreenGuardObserver extends ContentObserver {

    private final Context mContext;
    private final Activity mCurrentActivity;
    private final Handler mCurrentHandler;
    private final ScreenGuardListener.Listener mListener;
    private final Boolean getScreenShotPath;

    public ScreenGuardObserver(
            Context context,
            Activity activity,
            Handler handler,
            ScreenGuardListener.Listener listener,
            Boolean isGetScreenShotPath
    ) {
        super(handler);
        mContext = context;
        mListener = listener;
        mCurrentActivity = activity;
        mCurrentHandler = handler;
        getScreenShotPath = isGetScreenShotPath;
    }

    @Override
    public boolean deliverSelfNotifications() {
        return super.deliverSelfNotifications();
    }

    @Override
    public void onChange(boolean selfChange) {
        super.onChange(selfChange);
    }

    @Override
    public void onChange(boolean selfChange, Uri uri) {
        super.onChange(selfChange, uri);
        try {
            Map<String, Object> map = Collections.emptyMap();
            if (mCurrentActivity!= null && getScreenShotPath) {
                final View currentView =
                        mCurrentActivity.getWindow().getDecorView().getRootView();
                Bitmap bitmap = ScreenGuardHelper.captureView(currentView);

                String url = ScreenGuardHelper.saveBitmapToFile(mContext, bitmap);

                if (url != null && !url.isEmpty()) {
                    String fileType = url.substring(url.lastIndexOf(".") + 1);
                    String name = url.substring(url.lastIndexOf("/") + 1);
                    map.put("type", fileType);
                    map.put("name", name);
                }
                map.put("path", url);
            }
            new Handler(Looper.getMainLooper()).post(() -> mListener.onSnap(map));
        } catch (Exception e) {
            e.printStackTrace();
        }

    }
}
