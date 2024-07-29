package com.screenguard.flutter_screenguard.model;

import com.screenguard.flutter_screenguard.enums.ScreenGuardActionEnum;

abstract class ScreenGuardData {
    public String backgroundColor;
    public int timeAfterResume;
    public ScreenGuardActionEnum action;
}

