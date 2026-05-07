# Mobile App

This directory contains the Flutter mobile application for Meu Projeto Edu.
The architecture is offline-first with local persistence, connectivity-aware sync, and Riverpod state management.

## Features

- Local SQLite storage using `sqflite`
- Offline-first persistence for new courses
- Sync Manager with `connectivity_plus` to upload pending data when connectivity returns
- State management using `flutter_riverpod`
- Clean separation between API client, repository, and UI

## Setup

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Run `flutter pub get`
3. Update `lib/services/api_client.dart` with the backend base URL
4. Run `flutter run`
