package com.example.native_encryptor;

import android.util.Log;

public class PlugInUtility {
    static String TAG = "NativeEncryptor";

    public static void logError(String error,Throwable throwable){
        Log.e(TAG,error,throwable);
    }

    public static void logInfo(String message){
        Log.i(TAG,message);
    }
}
