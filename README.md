# Android Nixpkgs

All packages from the Android SDK repository, packaged with [Nix](https://nixos.org/nix/).

Updated daily from Google's Android SDK repositories.

## Install

### Requirements

Currently we support Linux and macOS on `x86_64` platforms only.

You should have `nix` installed, either because your're awesome and run NixOS, or you have installed
it from [nixos.org](https://nixos.org/download.html).

### Channel

If you're not using flakes, Nix channel is provided which contains `stable`,
`beta`, `preview`, and `canary` releases of the Android SDK package set.

```sh
nix-channel --add https://tadfisher.github.io/android-nixpkgs android-nixpkgs
nix-channel --update android-nixpkgs
```

The `sdk` function is provided to easily compose a selection of packages into a usable Android SDK
installation.

```nix
{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  android-nixpkgs = callPackage <android-nixpkgs> {
    # Default; can also choose "beta", "preview", or "canary".
    channel = "stable";
  };

in
android-nixpkgs.sdk (sdkPkgs: with sdkPkgs; [
  cmdline-tools-latest
  build-tools-32-0-0
  platform-tools
  platforms-android-31
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
  android-nixpkgs = callPackage <android> { };

  android-sdk = android-nixpkgs.sdk (sdkPkgs: with sdkPkgs; [
    cmdline-tools-latest
    build-tools-32-0-0
    platform-tools
    platforms-android-31
    emulator
  ]);

in
mkShell {
  buildInputs = [
    android-studio
    android-sdk
  ];
}
```

### Ad-hoc

If you don't want to set up a channel, and you don't use Nix flakes, you can import
`android-nixpkgs` using `builtins.fetchGit`:

``` nix
{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  android-nixpkgs = callPackage (import (builtins.fetchGit {
    url = "https://github.com/tadfisher/android-nixpkgs.git";
    ref = "main";  # Or "stable", "beta", "preview", "canary"
  })) { };

in
android-nixpkgs.sdk (sdkPkgs: with sdkPkgs; [
  cmdline-tools-latest
  build-tools-32-0-0
  platform-tools
  platforms-android-31
  emulator
])
```

### Flake

If you live on the bleeding edge, you may be using [Nix Flakes](https://nixos.wiki/wiki/Flakes).
This repository can be used as an input to your project's `flake.nix` to provide an immutable SDK
for building Android apps or libraries.

```nix
{
  description = "My Android app";

  inputs = {
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";

      # The main branch follows the "canary" channel of the Android SDK
      # repository. Use another android-nixpkgs branch to explicitly
      # track an SDK release channel.
      #
      # url = "github:tadfisher/android-nixpkgs/stable";
      # url = "github:tadfisher/android-nixpkgs/beta";
      # url = "github:tadfisher/android-nixpkgs/preview";
      # url = "github:tadfisher/android-nixpkgs/canary";

      # If you have nixpkgs as an input, this will replace the "nixpkgs" input
      # for the "android" flake.
      #
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, android-nixpkgs }: {
    packages.x86_64-linux.android-sdk = android-nixpkgs.sdk (sdkPkgs: with sdkPkgs; [
      cmdline-tools-latest
      build-tools-32-0-0
      platform-tools
      platforms-android-31
      emulator
    ]);
  };
}
```

A project template is provided via `templates.android`. This also provides a `devShell` with Android
Studio and a configured Android SDK.

```
nix flake init github:tadfisher/android-nixpkgs
nix develop
android-studio
```

See `flake.nix` in the generated project to customize the SDK and Android Studio version.


### Home Manager

A [Home Manager](https://github.com/nix-community/home-manager) module is provided to manage an
Android SDK installation for the user profile. Usage depends on whether you are using Home Manager
via flakes.

#### Normal

In `home.nix`:

```nix
{ config, pkgs, ... }:

let
  androidSdkModule = import ((builtins.fetchGit {
    url = "https://github.com/tadfisher/android-nixpkgs.git";
    ref = "main";  # Or "stable", "beta", "preview", "canary"
  }) + "/hm-module.nix");

in
{
  imports = [ androidSdkModule ];

  android-sdk.enable = true;

  # Optional; default path is "~/.local/share/android".
  android-sdk.path = "${config.home.homeDirectory}/.android/sdk";

  android-sdk.packages = sdkPkgs: with sdkPkgs; [
    build-tools-32-0-0
    cmdline-tools-latest
    emulator
    platforms-android-31
    sources-android-31
  ];
}
```

#### Flake

An example `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, android-nixpkgs }: {

    nixosConfigurations.x86_64-linux.myhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager

        {
          home-manager.users.myusername = { config, lib, pkgs, ... }: {
            imports = [
              android-nixpkgs.hmModule

              {
                android-sdk.enable = true;

                # Optional; default path is "~/.local/share/android".
                android-sdk.path = "${config.home.homeDirectory}/.android/sdk";

                android-sdk.packages = sdk: with sdk; [
                  build-tools-32-0-0
                  cmdline-tools-latest
                  emulator
                  platforms-android-31
                  sources-android-31
                ];
              }
            ];
          };
        }
      ];
    };
  };
}
```

## List SDK packages

### Channel

Unfortunately, this is a little rough using stable Nix, but here's a one-liner.

```
nix-instantiate --eval -E "with (import <android> { }); builtins.attrNames packages.stable" --json | jq '.[]'
```

### Flake

```
nix flake show github:tadfisher/android-nixpkgs
```

## Troubleshooting

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
include the additional packages, or switch to using a standard Android SDK install.

When using a standard installation downloaded from the Android Developers site, if you're running
NixOS then you may have to run `patchelf` to set the ELF interpreter for binaries referencing
standard paths for the system linker. The binaries may work inside Android Studio built from
nixpkgs, as it runs in a FHS-compliant chroot.

## License

Licensed under the MIT open-source license. See [COPYING](./COPYING) for details.
