<div align="center">
  <br>
  <a href="https://jailbreak.party/discord"><img src="https://github.com/jailbreakdotparty/Filos/blob/main/PreviewIcon.png?raw=true" alt="App Icon" width="150"></a>
  <br>
  <h1>Filos</h1>
  <p>Modern and open-source file manager for iDevices. This fork targets iOS 14.8 and later.</p>
  <a href="https://github.com/jailbreakdotparty/Filos/releases/latest"><img alt="GitHub Downloads (all assets, all releases)" src="https://img.shields.io/github/downloads/jailbreakdotparty/Filos/total?style=flat-square&color=CF7D46"></a>
  <a href="https://github.com/jailbreakdotparty/Filos/stargazers"> <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/jailbreakdotparty/filos?style=flat-square&color=%23FFD300"></a>
  <a href="https://jailbreak.party/discord"><img alt="Discord" src="https://img.shields.io/discord/1349128546072793218?style=flat-square&logo=discord&logoColor=FFFFFF&color=5865F2"></a>
  <a href="https://jailbreak.party"><img alt="Static Badge" src="https://img.shields.io/badge/jailbreak.party-blue?style=flat-square&label=%20&color=3868DB"></a>
</div>

## Important Information
- Filos is a modern and open-source file manager that's primarily designed for developers. This fork targets iOS 14.8 and later, so it supports a wide range of iOS versions and is great for tinkering or basic file management on jailbroken devices. There's no FTP, package management, or other tools that would be found in file managers like Filza. Filos has all the basic file operations you'd expect, a plist/text editor, and a permissions viewer.
- **Filos does NOT use any exploits or sandbox escapes.** If you're thinking that this project will give you full r/w on iOS 27.x, think again. This file manager has been designed with developers and jailbreakers in mind.
- Since Filos relies on entitlements in order to function, it will be inherently more limited on jailbroken devices than any file manager with a root helper would. I may look into adding one in the future, but no promises.

## Building

This fork is maintained for **iOS 14.8 on a rootful jailbreak**, including iPhone 11. It uses one iOS 14 implementation, without branches for newer iOS controls or styling.

GitHub Actions builds Release and Debug with Xcode 15.4, checks the app's minimum iOS version, icon, and bundled Swift runtime, and packages the Release app as a signed rootful `.deb`.

1. Push changes to the fork and open **Actions > Build iOS**.
2. Open the successful run and download **Filos-rootful**.
3. Extract the `.deb` from the downloaded ZIP and transfer it to your phone.
4. Install it with your jailbreak's package installer while jailbroken.

The package installs to `/Applications/Filos.app`, declares `Architecture: iphoneos-arm`, and depends on iOS 14.8 or later and `uikittools`. Signing uses the existing `entitlements.plist`. The rootful architecture convention is documented by [Theos](https://theos.dev/docs/packaging); signing options are documented by [Procursus ldid](https://github.com/ProcursusTeam/ldid/blob/master/docs/ldid.1).

For local macOS builds, install `ldid` and `dpkg`, then run `bash debbuild.sh`. To package an already-built app, run `bash debbuild.sh /path/to/Filos.app`. Packages are written to `build/packages`.

The workflow pins `macos-14` and Xcode 15.4, verified against GitHub's [runner inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-14-Readme.md) and Apple's [Xcode support table](https://developer.apple.com/support/xcode/). **GitHub retires this runner on November 2, 2026**, with temporary outages beforehand. Verify iOS 14 support before choosing a replacement. [Official retirement announcement](https://github.com/actions/runner-images/issues/13518)

## Source structure

- `App`: settings, favorites, and logs.
- `Browser`: folder/file browsing, search, and document import.
- `Viewers`: file information, text, and property-list editing.
- `UI`: shared display components, selectable text, and list styling.
- `Helpers`: file operations and application services.

Search uses `UISearchBar`; text and logs use a selectable `UITextView`; import uses `UIDocumentPickerViewController(forOpeningContentTypes:asCopy:)`. These are documented Apple APIs supported on iOS 14.8. [Search](https://developer.apple.com/documentation/uikit/uisearchbar), [selectable text](https://developer.apple.com/documentation/uikit/uitextview/isselectable), [document picker](https://developer.apple.com/documentation/uikit/uidocumentpickerviewcontroller/init(foropeningcontenttypes:ascopy:))

Choose **Refresh** in the **Actions** menu to reload a folder. Long-press files to access their actions. The original iOS 14.8 package was confirmed working on the user's phone; updated builds still need a device check after changes.

## Credits
- [lunginspector](https://github.com/lunginspector): Primary developer and maintainer.
- [skadz108](https://github.com/skadz108): SBX-related stuff and some file browser components.
- [rooootdev](https://github.com/rooootdev): Archive utilities.
