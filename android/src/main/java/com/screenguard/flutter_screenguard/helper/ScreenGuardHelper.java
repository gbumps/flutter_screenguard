package com.screenguard.flutter_screenguard.helper;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.view.View;

import java.io.File;
import java.io.FileOutputStream;
import java.util.Calendar;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;

public class ScreenGuardHelper {
    public static String saveBitmapToFile(Context context, Bitmap bitmap) {
        try {
            File imagePath = new File(
                    context.getCacheDir(), "save_bitmap_images");
            if (!imagePath.exists()) {
                imagePath.mkdirs();
            }
            Calendar calendar = Calendar.getInstance();
            long time = calendar.getTimeInMillis();

            File imageFile = new File(imagePath, "bitmap_" + time + ".png");

            FileOutputStream fos = new FileOutputStream(imageFile);
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, fos);
            fos.flush();
            fos.close();

            return imageFile.getAbsolutePath();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static Bitmap captureView(View view) {
        Bitmap bitmap = Bitmap.createBitmap(
                view.getWidth(), view.getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);

        view.draw(canvas);
        return bitmap;
    }

    public static Object getData(MethodCall call, String key) {
        if (call.hasArgument(key)) {
            return call.argument(key);
        }
        return null;
    }

}
