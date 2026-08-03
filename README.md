# Unreal Engine Launcher

## Why

Made without the permission of Epic Games, this project was born out of my frustration working with
the Epic Games Launcher's Unreal Engine Library, where it is currently impossible to see all the
projects
on your local machine, sort said projects by date (to determine when they were last worked on), and
filter by
arbitrary tags or categories.

## What

This application is an attempt to address the issues mentioned above. As of now, the application
boots (quite fast, I might add)
and allows users to select arbitrary directories to scan for Unreal Engine projects. Once the
directory is scanned, the project view
is populated, and the sorting and filtering options should help the user find what they're looking
for.

## Future

Some ideas for future development:

- [x] A "Recent Projects" side panel
- [x] Add custom tags to projects for better filtering
- [x] Cloning projects to a new directory
- [X] Installing and updating new engine versions
- [ ] A Fab Library window
- [ ] The ability to manage the local Asset Vault

## How to use

Builds have been uploaded to the release folder within the main directory. Select the version you
need and download it as a ZIP file.
After extracting the files, the application should run by selecting the .exe file.

## How to Add Features

If this project resonates with you, and you'd like to work on it and improve it, please do! The
licence is MIT Open Source, so you
may take this as a base for your own application, but I would appreciate it if this repo was kept
alive with any useful updates.

The project uses the Flutter framework. If you need any help setting yourself up for working with
flutter, or just if you want to
build from source (to another platform, for example), please visit https://flutter.dev/.

# Installation Guide for UE Launcher

Because this application is signed with a self-signed (test) certificate, you must manually trust
the certificate before Windows will allow the installation.

## Prerequisites

- The `.msix` installer file.
- The `.pfx` or `.cer` certificate file (if provided separately).

## Steps to Install

### 1. Trust the Certificate

If you only have the `.msix` file:

1. **Right-click** the `ue_launcher.msix` file and select **Properties**.
2. Go to the **Digital Signatures** tab.
3. Select the signature in the list and click **Details**.
4. Click **View Certificate**.
5. Click **Install Certificate...**.
6. Choose **Local Machine** and click Next.
7. Select **Place all certificates in the following store**.
8. Click **Browse** and select **Trusted Root Certification Authorities**.
9. Click OK, Next, and **Finish**.

### 2. Run the Installer

1. **Double-click** the `ue_launcher.msix` file.
2. Click **Install**.
3. If you see a Windows SmartScreen warning ("Windows protected your PC"), click **More info** and
   then **Run anyway**.

## Why is this necessary?

Official Windows apps are signed by certificates purchased from a Certificate Authority (CA). Since
this is an open-source/developer build, it uses a self-signed certificate. By following these steps,
you are telling Windows that you trust the developer of this specific package.
