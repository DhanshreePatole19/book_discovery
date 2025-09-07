Step 1: Create a Firebase Project
- Go to firebase cosole 
- Click Add Project → give it a name (example: book-discovery).
- Finish the setup.

Step 2:Add Your Android App
-In Firebase Console → click Add App → select Android.
-Enter the app package name (find it in android/app/build.gradle under applicationId).
-Download the google-services.json file.
-Place it inside your Flutter project:(android/app/google-services.json)

Step 3: Connect Firebase to Android Project
-In android/build.gradle (Project level), add: dependencies {classpath 'com.google.gms:google-services:4.4.2'}
- In android/app/build.gradle, add at the very bottom:apply plugin: 'com.google.gms.google-services'

Step 4: Add Firebase Packages in Flutter
-dependencies:
  firebase_core: ^3.4.0
  cloud_firestore: ^5.4.0
  firebase_auth: ^5.2.0
  firebase_storage: ^12.2.0

Step 5: Initialize Firebase in Flutter (main.dart)
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

Step 6: Enable Firestore and Storage
- Go to Firebase Console → Build → Firestore Database → click Create Database.
- Go to Build → Storage → click Enable.
- Start with Test Mode (easy for development), later update with secure rules before release.
