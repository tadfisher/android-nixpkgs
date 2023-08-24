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
          build-tools-32-0-0
          cmdline-tools-latest
          emulator
          platforms-android-31
          sources-android-31
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
    android-sdk.finalPackage = pkgs.androidSdk cfg.packages;

    home = {
      file.${cfg.path}.source = "${cfg.finalPackage}/share/android-sdk";
      packages = [ cfg.finalPackage ];
      sessionVariables = {
        ANDROID_HOME = cfg.path;
        ANDROID_SDK_ROOT = cfg.path;
      };
    };
  };
}
