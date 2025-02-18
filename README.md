# ubiqus_app

A new Flutter project for ubiqus app.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Instalation

- Run `flutter pub get` to install dependencies and generate .dart_tool directory

## Dependencies

Gradle: 8.0
Kotlin: 1.8.10
Groovy: 3.0.13
Ant: Apache Ant(TM) version 1.10.11 compiled on July 10 2021
JVM: 17.0.11 (Red Hat, Inc. 17.0.11+9)

## To generate .apk file

Run the next commands:
- flutter clean
- flutter pub get
- cd android/
- ./gradlew clean
- ..cd
- flutter build apk --release