package com.screenguard.flutter_screenguard.model;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;

import com.screenguard.flutter_screenguard.enums.ScreenGuardActionEnum;

public class ScreenGuardColorData extends ScreenGuardData implements Parcelable {

    public ScreenGuardColorData(String color, int timeAfterResume) {
       this.backgroundColor = color;
       this.timeAfterResume = timeAfterResume;
       this.action = ScreenGuardActionEnum.color;
    }

    protected ScreenGuardColorData(Parcel in) {
        backgroundColor = in.readString();
        timeAfterResume = in.readInt();
        action = ScreenGuardActionEnum.color;
    }

    public static final Creator<ScreenGuardColorData> CREATOR = new Creator<ScreenGuardColorData>() {
        @Override
        public ScreenGuardColorData createFromParcel(Parcel in) {
            return new ScreenGuardColorData(in);
        }

        @Override
        public ScreenGuardColorData[] newArray(int size) {
            return new ScreenGuardColorData[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(@NonNull Parcel parcel, int i) {
        parcel.writeString(backgroundColor);
        parcel.writeInt(timeAfterResume);
    }
}
