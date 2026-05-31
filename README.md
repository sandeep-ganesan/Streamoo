# Streamoo

A modern Flutter-based application to keep track of your favorite streamers and know exactly when they go live.

Streamoo focuses on simplicity and real-time visibility by providing a clean interface and a home screen widget—no notifications, no clutter, just the information you need.

## Features

- **Live Status Widget**: Quickly see which of your favorite streamers are live directly from your home screen.
- **Multi-Platform Support**: Track streamers across Twitch and YouTube.
- **Streamer Registration**: Add and manage your favorite streamers.
- **Live Stream Cards**: Clean card-style UI displaying:
  - Stream thumbnail
  - Live duration
  - Direct button to watch the stream
- **Dark Mode**: Dark mode support for a comfortable viewing experience.
- **Account Sync**: Firebase-powered authentication and syncing across multiple devices.

## Technical Architecture

To ensure efficient and up-to-date stream tracking, Streamoo follows a polling-based architecture:

- **Polling**: The Flask backend queries Twitch and YouTube APIs every 15 minutes.
- **Change Detection**: When a streamer’s live status changes, the backend updates the database.
- **Storage**: Firestore stores:
  - User data
  - Streamer data
  - User-streamer relationships
- **Data Flow**:
  - App → Firestore → Backend → External APIs → Firestore → App
- **Widget Integration**: The home screen widget directly fetches live status data from Firestore for quick access.

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Flask (Python) with `requests`
- **Database**: Firebase Firestore
- **Authentication**: Firebase Authentication
- **APIs**: Twitch API, YouTube Data API
- **Hosting**: Render (backend deployment)
- **CI/CD**: GitHub Actions
