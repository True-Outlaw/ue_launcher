# Installation Guide for UE Launcher

Because this application is signed with a self-signed (test) certificate, you must manually trust the certificate before Windows will allow the installation.

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
3. If you see a Windows SmartScreen warning ("Windows protected your PC"), click **More info** and then **Run anyway**.

## Why is this necessary?
Official Windows apps are signed by certificates purchased from a Certificate Authority (CA). Since this is an open-source/developer build, it uses a self-signed certificate. By following these steps, you are telling Windows that you trust the developer of this specific package.
