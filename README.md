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

## Building & Tinkering

This fork can be built with Xcode 15.4 and the iOS 17.5 SDK. The deployment target is iOS 14.8. GitHub Actions builds Release and Debug configurations without signing, then packages the Release app as an IPA.

### Build on GitHub Actions

1. Push changes to your fork. **Build iOS** runs on pushes and pull requests.
2. Open **Actions**, choose **Build iOS**, then open the successful run.
3. Download the **Filos-unsigned** artifact and extract `Filos-unsigned.ipa` from the downloaded ZIP.
4. Sign/install the IPA with your chosen installation tool. This artifact is unsigned and does not have the privileged entitlements from `entitlements.plist`; ordinary sideloading retains iOS sandbox restrictions.

Manual runs become available after the workflow file is on the default branch. See GitHub's documentation for [manual runs](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow) and [downloading artifacts](https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow).

The workflow pins `macos-14` and `/Applications/Xcode_15.4.app`, verified against GitHub's [runner inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-14-Readme.md) and Apple's [Xcode support table](https://developer.apple.com/support/xcode/). **GitHub retires this runner on November 2, 2026**, with temporary outages beforehand. A replacement toolchain must be verified for iOS 14 support before changing the runner. See the [official retirement announcement](https://github.com/actions/runner-images/issues/13518).

### iOS 14.8 compatibility

- Search uses Apple's `UISearchBar` on iOS 14 and SwiftUI search on iOS 15 and later.
- Choose **Refresh** in the **Actions** menu on iOS 14. Newer versions retain pull-to-refresh.
- Long-press a file for actions such as favorite and delete on iOS 14. Swipe actions remain on iOS 15 and later.
- Text and logs remain selectable using `UITextView` on iOS 14.
- Import uses Apple's iOS 14 document-picker initializer with `asCopy: true`, replacing the global initializer swizzle.
- Newer styling APIs are checked for availability. iOS 26 glass effects additionally require a build with the iOS 26 SDK; the Xcode 15.4 build uses the compatible appearance.

The compatibility adapters are in `Filos/Helpers/ViewExtensions.swift`. API availability was checked against Apple's official documentation and Xcode 15.4's SDK declarations. Key references: [document picker](https://developer.apple.com/documentation/uikit/uidocumentpickerviewcontroller/init(foropeningcontenttypes:ascopy:)), [UIKit integration](https://developer.apple.com/documentation/swiftui/uiviewrepresentable), [search](https://developer.apple.com/documentation/uikit/uisearchbar), [selectable text](https://developer.apple.com/documentation/uikit/uitextview/isselectable), and [Swift concurrency back deployment](https://developer.apple.com/documentation/xcode-release-notes/xcode-13_2-release-notes).

CI checks the packaged app's declared and executable minimum iOS versions, embedded Swift concurrency runtime, and iPhone icon. A successful build does not establish that the app has been tested on a physical iOS 14.8 device. Device validation should cover launch, folder navigation, search, refresh, importing/cancelling, closing viewers, selecting text, and saving/deleting plist entries in a writable folder.

For local macOS builds, `ipabuild.sh` builds an IPA (`--debug` for Debug, `--ts` for the existing TrollStore signing route with `ldid`). `debbuild.sh` still packages for a rootless jailbreak under `/var/jb`, with its existing iOS 15 minimum. The `.deb` packaging has not been adapted for an iOS 14 jailbreak; use the IPA workflow for this backport.

## Credits
- [lunginspector](https://github.com/lunginspector): Primary developer and maintainer.
- [skadz108](https://github.com/skadz108): SBX-related stuff and some file browser components.
- [rooootdev](https://github.com/rooootdev): Archive utilities.
