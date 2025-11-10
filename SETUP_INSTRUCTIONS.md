# Voice Generator App - Setup Instructions

## Prerequisites
- Flutter SDK installed
- Deepgram API key (get it from https://deepgram.com/)

## Setup Steps

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Deepgram API Key
1. Create a `.env` file in the root directory (same level as `pubspec.yaml`)
2. Add your Deepgram API key:
```
DEEPGRAM_API_KEY=your_actual_api_key_here
```

**Note:** Replace `your_actual_api_key_here` with your actual Deepgram API key.

### 3. Run the App
```bash
flutter run
```

## Features

### Voice Generation
- **12 Deepgram Aura voices available:**
  - aura-asteria-en (Female)
  - aura-luna-en (Female)
  - aura-stella-en (Female)
  - aura-athena-en (Female)
  - aura-hera-en (Female)
  - aura-orion-en (Male)
  - aura-arcas-en (Male)
  - aura-perseus-en (Male)
  - aura-angus-en (Male)
  - aura-orpheus-en (Male)
  - aura-helios-en (Male)
  - aura-zeus-en (Male)

### How to Use
1. **Open the app** - You'll see the home screen with a list of generated audios
2. **Tap the "Generate Audio" button** - Opens the audio generator screen
3. **Enter text** - Type or paste the text you want to convert to speech
4. **Select a voice** - Choose from the dropdown list of available voices
5. **Generate** - Tap "Generate Audio" button
6. **Listen** - Return to home screen and tap the play button to listen to your generated audio

### Database
- All generated audios are saved locally using SQLite
- Audio files are stored in the app's documents directory
- Metadata (text, voice, file path, creation date) is stored in the database

## Troubleshooting

### "Deepgram API key missing" error
- Make sure you created the `.env` file in the root directory
- Verify the API key is correctly formatted: `DEEPGRAM_API_KEY=your_key`
- Restart the app after creating/modifying the `.env` file

### "Failed to generate audio" error
- Check your internet connection
- Verify your Deepgram API key is valid and has credits
- Check the console for detailed error messages

### Voices not showing in dropdown
- Make sure you have internet connection when the app starts
- Check that `initDeepgram()` and `fetchVoices()` are called in the AudioGeneratorScreen

## Technical Details

### Architecture
- **Provider Pattern** for state management
- **SQLite** for local database storage
- **HTTP requests** to Deepgram TTS API
- **AudioPlayers** package for audio playback

### API Endpoint
```
POST https://api.deepgram.com/v1/speak?model={voice_model}
Headers:
  - Authorization: Token {your_api_key}
  - Content-Type: application/json
Body:
  {
    "text": "Your text here"
  }
```

## Support
For issues with Deepgram API, visit: https://developers.deepgram.com/
