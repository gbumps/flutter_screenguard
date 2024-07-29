package com.screenguard.flutter_screenguard.model;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;

import com.screenguard.flutter_screenguard.enums.ScreenGuardActionEnum;
import com.screenguard.flutter_screenguard.enums.ScreenGuardImagePositionEnum;
import com.screenguard.flutter_screenguard.helper.ScreenGuardImagePosition;

public class ScreenGuardImageData extends ScreenGuardData implements Parcelable {

    public double width;

    public double height;

    public String imageUrl;

    public ScreenGuardImagePositionEnum position;


    public ScreenGuardImageData(
            String backgroundColor,
            String imageUrl,
            double width,
            double height,
            int alignmentIndex,
            int timeAfterResume
    ) {
        this.width = width;
        this.height = height;
        this.backgroundColor = backgroundColor;
        this.imageUrl = imageUrl;
        this.position = ScreenGuardImagePosition.getEnumFromNumber(alignmentIndex);
        this.timeAfterResume = timeAfterResume;
        this.action = ScreenGuardActionEnum.image;
    }

    protected ScreenGuardImageData(Parcel in) {
        width = in.readDouble();
        height = in.readDouble();
        backgroundColor = in.readString();
        imageUrl = in.readString();
        position = ScreenGuardImagePosition.getEnumFromNumber(in.readInt());
        timeAfterResume = in.readInt();
        action = ScreenGuardActionEnum.image;
    }

    public static final Creator<ScreenGuardImageData> CREATOR = new Creator<ScreenGuardImageData>() {
        @Override
        public ScreenGuardImageData createFromParcel(Parcel in) {
            return new ScreenGuardImageData(in);
        }

        @Override
        public ScreenGuardImageData[] newArray(int size) {
            return new ScreenGuardImageData[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(@NonNull Parcel parcel, int i) {
        int pos = 0;
        for (int idx = 0; idx < ScreenGuardImagePositionEnum.values().length; idx++) {
            if (position == ScreenGuardImagePosition.getEnumFromNumber(idx)) {
                pos = idx;
                break;
            }
        }
        parcel.writeDouble(width);
        parcel.writeDouble(height);
        parcel.writeString(backgroundColor);
        parcel.writeString(imageUrl);
        parcel.writeInt(pos);
        parcel.writeInt(timeAfterResume);
    }
}
