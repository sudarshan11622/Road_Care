# RoadCare Flutter

A clean, structured Flutter implementation of the supplied RoadCare UI.

## Included flows

### Citizen
- Welcome / landing page
- Report a road problem
- Add photo from camera/gallery
- Select problem type
- Confirm location
- Review and submit
- Submission success
- Track reports
- Phone + OTP demo login
- My Reports
- Notifications
- Profile and settings

### Admin
- Admin login
- Operations overview
- Report management
- Report detail
- Citizen directory
- Administration settings

## Demo credentials

Citizen OTP:
- Any 10+ digit phone number
- OTP: `1234`

Admin:
- Email: `admin@roadcare.app`
- Password: `admin123`

## Run

```bash
flutter pub get
flutter run
```

For Android:

```bash
flutter run -d android
```

## Production integration

This project intentionally keeps the backend boundary clean. Replace:
- `AppState` demo repository logic with a REST/Firebase repository
- Demo OTP with Firebase Phone Auth or your SMS provider
- Demo location with `geolocator` or a maps SDK
- Local report persistence with your backend/database
- Demo admin login with real authentication and role-based access control

The UI and navigation do not need to be rewritten when those services are connected.
