{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.android-sdk;

in
{
  options.android-sdk = {
    enable = mkEnableOption "android SDK environment";

    path = mkOption {
      type = types.str;
      default = "${config.xdg.dataHome}/android";
      defaultText = "$XDG_DATA_HOME/android";
      description = ''
        Path to install the SDK environment, relative to
        <varname>home.homeDirectory</varname>.
      '';
    };

    packages = mkOption {
      default = self: [ self.cmdline-tools-latest ];
      type = hm.types.selectorFunction;
      defaultText = "sdk: [ sdk.cmdline-tools-latest ]";
      example = literalExample ''
        sdk: with sdk; [
          build-tools-30-0-2
          cmdline-tools-latest
          emulator
          platforms-android-30
          sources-android-30
        ]
      '';
    };

    finalPackage = mkOption {
      type = types.package;
      visible = false;
      readOnly = true;
      description = ''
        Final Android SDK environment.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    android-sdk.finalPackage = pkgs.androidSdkPackages.sdk cfg.packages;

    home = {
      file.${cfg.path}.source = "${cfg.finalPackage}/share/android-sdk";
      packages = [ cfg.finalPackage ];
      sessionVariables = {
        ANDROID_HOME = config.home.file.${cfg.path}.target;
        ANDROID_SDK_ROOT = config.home.file.${cfg.path}.target;
      };
    };
  };
}
