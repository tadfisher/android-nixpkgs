# Android Nixpkgs

All packages from the Android SDK repository, packaged with [Nix](https://nixos.org/nix/).

## Installation

### Requirements

Currently we support Linux on `x86_64` platforms only. MacOS (and possibly `aarch64` support) is a
possibility, but I do not own such a machine. Contributions are welcome.

You should have `nix` installed, either because your're awesome and run NixOS, or you have installed
it from [nixos.org](https://nixos.org/download.html).

### Channel

If you're using stable Nix (2.3 or earlier), a Nix channel is provided which contains `stable`,
`beta`, `preview`, and `canary` releases of the Android SDK package set.

```sh
nix-channel --add android https://tadfisher.github.io/android-nixpkgs
nix-channel --update android
```

The `sdk` function is provided to easily compose a selection of packages into a usable Android SDK
installation.

```nix
{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  androidSdkPackages = callPackage <android> { };

in
  # Replace `stable' with `beta', `preview', or `canary' to select from a different package set.
  androidSdkPackages.sdk (apkgs: with apkgs.stable; [
    cmdline-tools-latest
    build-tools-30-0-3
    platform-tools
    platforms.android-30
    emulator
  ])
```

If you save this in something like `sdk.nix`, you can get a dev environment with `nix-shell`. This
will result in `ANDROID_HOME` and `ANDROID_SDK_ROOT` being set in your environment.

```sh
nix-shell sdk.nix
```

Here's an example `shell.nix` which includes Android Studio from Nixpkgs and a working SDK.

```nix
{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  androidSdkPackages = callPackage <android> { };

  androidSdk = androidSdkPackages.sdk (apkgs: with apkgs.stable; [
    cmdline-tools-latest
    build-tools-30-0-2
    platform-tools
    platforms.android-30
    emulator
  ]);

in
mkShell {
  buildInputs = [
    android-studio
    androidSdk
  ];
}
```

### Flake

If you live on the bleeding edge, you may be using [Nix Flakes](https://nixos.wiki/wiki/Flakes).
This project can be used as an input to your project's `flake.nix` to provide an immutable SDK for
building Android apps.

```nix
{
  description = "My Android app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, android-nixpkgs }: {
    packages.x86_64-linux.android-sdk = android-nixpkgs.lib.sdk (
  };
}
```

# Troubleshooting

**Android Studio is using the wrong SDK installation directory.**

Unfortunately, Android Studio persists the configuration for `android.sdk.path` in several
locations:

- In `local.properties` within the project. This is regenerated whenever syncing with the build
  system. A possible way to prevent this (and avoid the following steps) is to remove the `sdk.dir`
  property and set the file read-only with `chmod -w local.properties`.
- In `~/.config/Google/AndroidStudio{Version}/options/jdk.table.xml`. Search for the string "Android
  SDK" and remove the entire surrounding `<jdk>` element.
- In the workspace configuration, which may live in `.idea/workspace.xml` in the project, or in
  `~/.config/Google/AndroidStudio{Version}/workspace/{hash}.xml`. Search for the string
  "android.sdk.path" and remove the element.

A method to configure Android Studio (and IntelliJ IDEA) via Nix would be cool, but also a tedious
endeavor.

**The SDK Manager complains about a read-only SDK directory.**

This is fine; you cannot install packages via the SDK Manager to a Nix-built SDK, because the point
of this project is to make your build dependencies immutable. Either update your Nix expression to
include the additional packages, or switch to using a standard Android SDK install. Note that on
NixOS, you may have to run `patchelf` to set the ELF interpreter for binaries referencing standard
paths for the system linker.

## License

Licensed under the MIT open-source license. See [COPYING](./COPYING) for details.
