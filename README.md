# HS DEVS AUTH — Swift & iOS SDK

Official Swift client library for macOS and iOS apps.

## Usage

```swift
let auth = HSAuth(name: "AppName", ownerId: "OwnerID", secret: "Secret", version: "1.0")

Task {
    if await auth.license(key: "YOUR_KEY") {
        print("Success! Expires: \(auth.userData.expiresAt)")
    }
}
```
