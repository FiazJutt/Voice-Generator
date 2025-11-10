# Voice Generator - Features Guide

## 🎵 Audio Playback Features

### Play/Pause Control
- **Play Audio**: Tap the play button (▶️) on any audio item
- **Pause Audio**: While playing, tap the pause button (⏸️) to pause
- **Resume Audio**: Tap play again to resume from where you paused
- **Visual Indicator**: Currently playing audio shows an animated equalizer icon (📊)
- **Auto-stop**: Playing a different audio automatically stops the current one

### Audio Controls Location
- Each audio item in the list has two buttons:
  - **Play/Pause button**: Left button that toggles between play and pause
  - **More options button**: Right button (⋮) for additional actions

## 📤 Share Functionality

### How to Share
1. Tap the **more options button (⋮)** on any audio item
2. Select **"Share"** from the bottom sheet menu
3. Choose your preferred sharing method (WhatsApp, Email, etc.)
4. The audio file will be shared along with the text content

### What Gets Shared
- The MP3 audio file
- A message: "Generated audio: [your text]"

## 💾 Save to Device Storage

### How to Save
1. Tap the **more options button (⋮)** on any audio item
2. Select **"Save to Device"** from the bottom sheet menu
3. Grant storage permission if prompted
4. Audio will be saved to your Downloads folder

### Save Details
- **Location**: `/storage/emulated/0/Download/` (Android)
- **Filename Format**: `voice_[timestamp].mp3`
- **Example**: `voice_1699363200000.mp3`
- **Success Message**: Shows the filename after successful save

## 📋 Additional Features

### Audio Details
1. Tap the **more options button (⋮)**
2. Select **"Details"**
3. View complete information:
   - Full text content
   - Voice model used
   - Creation date and time
   - File path

### Pull to Refresh
- Swipe down on the audio list to refresh and reload all audios from database

### Visual Feedback
- **Playing Audio**: Shows animated equalizer icon with primary color
- **Paused/Stopped**: Shows static audio track icon
- **Loading**: Shows circular progress indicator

## 🎨 UI Elements

### Audio List Item Components
```
┌─────────────────────────────────────────┐
│ 🎵  Audio Title (truncated)             │
│     Voice: aura-luna-en                 │
│     Nov 7, 2025 3:42 PM                 │
│                            ▶️  ⋮         │
└─────────────────────────────────────────┘
```

### Bottom Sheet Menu
```
┌─────────────────────────────────────────┐
│  📤 Share                                │
│  💾 Save to Device                       │
│  ℹ️  Details                             │
└─────────────────────────────────────────┘
```

## 🔐 Permissions Required

### Android Permissions
- **INTERNET**: For Deepgram API calls
- **WRITE_EXTERNAL_STORAGE**: For saving files (Android 12 and below)
- **READ_EXTERNAL_STORAGE**: For reading files (Android 12 and below)
- **READ_MEDIA_AUDIO**: For accessing audio files (Android 13+)

### Permission Handling
- Permissions are requested automatically when you try to save a file
- If denied, you'll see a message: "Storage permission denied"
- You can grant permissions later from device settings

## 🎯 Usage Tips

### Best Practices
1. **Test Playback**: Always test audio before sharing
2. **Organize Files**: Saved files include timestamps for easy identification
3. **Storage Space**: Monitor device storage when saving multiple files
4. **Permission Access**: Grant storage permissions for full functionality

### Troubleshooting

#### Audio Not Playing
- Check if file exists (Details → File path)
- Ensure audio was generated successfully
- Try regenerating the audio

#### Share Not Working
- Ensure the audio file exists
- Check if you have sharing apps installed
- Try saving to device first

#### Save to Device Failed
- Grant storage permissions
- Check available storage space
- Ensure Downloads folder is accessible
- Try again after granting permissions

#### Permission Denied
- Go to: Settings → Apps → Voice Generator → Permissions
- Enable Storage/Files and media permissions
- Return to app and try again

## 🚀 Quick Actions

| Action | Steps |
|--------|-------|
| Play Audio | Tap ▶️ button |
| Pause Audio | Tap ⏸️ button (while playing) |
| Share Audio | Tap ⋮ → Share |
| Save Audio | Tap ⋮ → Save to Device |
| View Details | Tap ⋮ → Details |
| Refresh List | Pull down on list |
| Generate New | Tap "Generate Audio" button |

## 📱 Platform Support

### Android
- ✅ Play/Pause audio
- ✅ Share via system share sheet
- ✅ Save to Downloads folder
- ✅ Storage permissions handling

### iOS (Future Support)
- ✅ Play/Pause audio
- ✅ Share via system share sheet
- ⚠️ Save to Files app (requires additional setup)

## 🎉 Feature Highlights

1. **Seamless Playback**: Play, pause, and resume without interruption
2. **Easy Sharing**: Share with any app installed on your device
3. **Persistent Storage**: Save files permanently to device storage
4. **User-Friendly**: Intuitive UI with clear visual feedback
5. **Permission Management**: Automatic permission requests with clear messaging
