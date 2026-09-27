# Smart Connect

Smart Connect is a Flutter prototype for meeting and chatting with people around the world. It includes an onboarding flow, account screens, a searchable country picker, community rules and policy pages, theme settings, and camera, microphone, and speaker checks.

## Run the app

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install), connect an Android phone with USB debugging enabled (or start an Android emulator), then run these commands from the project directory:

```sh
flutter pub get
flutter run
```

To run the automated checks:

```sh
flutter analyze
flutter test
```

## Current prototype scope

Authentication is stored locally in memory and resets when the app restarts. Live random matching, messaging, and video chat between users require a backend service and are not connected in this prototype. Contact Us opens a pre-filled email draft addressed to `Sultangeeafridi@gmail.com`; the user reviews and sends it through their email app.

Camera and microphone access is requested by the device-check screens. Android permissions are declared in the project; iOS usage descriptions are included for builds on Apple platforms.
