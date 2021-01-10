addAndroidSdkVars() {
  export ANDROID_SDK_ROOT="@sdk@/share/android-sdk"
}

if [ -z "''${dontSetAndroidSdkRoot:-}" ]; then
  addEnvHooks "$hostOffset" addAndroidSdkVars
fi
