# App-Updater
App updater using Firebase Config

# Firebase Remote config 
## _iOS App Updater_

[![FIREBASE](https://img.icons8.com/color/48/null/firebase.png) click here ](https://firebase.google.com/docs/remote-config/get-started?platform=ios) to how to config firebase in ios and documentation of firebase confing.

## Features

- We can give app update custom alert like this : -   
- **Application update type** can refer to different things depending on the context, but in general, it refers to the type or method of updating a software application.
Here are some common types of application updates:

    - **Major updates:** These updates typically introduce significant changes to the application, such as new features or a redesigned user interface. Major updates often require users to download and install a new version of the application.

    - **Minor updates:** These updates usually contain bug fixes, security patches, and small improvements to the application. Minor updates can be downloaded and installed automatically or manually.

    - **Patch updates:** These updates are small, targeted fixes for specific issues in the application. Patch updates are often downloaded and installed automatically.

    - **Hotfix updates:** These updates are similar to patch updates, but they are typically released more urgently to address critical issues or vulnerabilities.

    - **Version updates:** When an application updates from one major version to another (e.g., from version 1.0 to version 2.0), this is known as a version update. Version updates can introduce major changes to the application and may require users to purchase a new license or subscription.

The specific update types available for an application will depend on the software development and release strategy of the application's developers.
- Import and save files from GitHub

## Firebase console configureation 

- You need to configure as a key in firebase console inside remote configure section:- 
    - there one option to **Publish form a file** you just need to upload json here and you all paramater added and configure properly.

## Installation

Firebase configure requires [Cocoa Pods](https://cocoapods.org/pods/FirebaseRemoteConfig) to run.
```
pod 'Firebase/RemoteConfig' 
```

## Development

First you need to add **[AppUpdater.swit]** file inside your project.

First you need to configure **AppSeceneDelegate.swift** file into below method:

```sh
 func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("**** scene will enter in foreground *****")
        // App update checker
        var delay = 0.1
        if let topVC = UIApplication.topViewController() {
            delay = topVC.isKind(of: CustomLunchScreenViewController.self) ? 2.0 : 0.1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            AppUpdater.shared.checkAppUpdate()
        }
    }
```

## HAPPY CODING...!
