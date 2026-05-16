# Society Member App

Society Member App is a Flutter-based mobile application built for society maintenance management. It helps an admin manage members, maintenance bills, notices, and payment records, while members can log in to view notices, check maintenance dues, and see their payment history.

The project uses **Flutter** for the frontend and **Supabase** for authentication and database management. It supports role-based access for **Admin** and **Member** users.

## Project Description

This application is designed to simplify common society management tasks in a single app.

### Admin can:
- Add and manage member profiles
- Generate maintenance bills
- Post society notices
- View payment records

### Member can:
- Sign up using an admin-added email
- Log in to the app
- View notices
- Check maintenance dues
- View payment history

The app uses Supabase Auth for login and signup, and stores user and app data in Supabase database tables such as `members`, `maintenance_bills`, `payments`, and `notices`.

## How to Run the Project

### Prerequisites

Make sure the following are installed:

- Flutter SDK
- Android Studio or VS Code
- Android Emulator or physical Android device
- A Supabase project

### Setup

1. Clone the project.
2. Open the project in Android Studio or VS Code.
3. Run the following command to install dependencies:

```bash
flutter pub get
```

4. Add your Supabase project credentials in `main.dart`:
- Supabase URL
- Supabase anon key

5. Make sure your Supabase database tables and RLS policies are created properly.

### Run the App

```bash
flutter run
```

### Useful Commands

```bash
flutter pub get
flutter clean
flutter run
flutter build apk
```
