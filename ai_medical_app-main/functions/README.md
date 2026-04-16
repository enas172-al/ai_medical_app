# Labby – Firebase Cloud Functions

## What runs here

- **`onAnalysisImageUploaded`**: When a user uploads an image to Storage at  
  `users/{userId}/analyses/{fileName}`, the function:
1. Calls **Google Cloud Vision** (text detection) on the file in GCS.
  2. Tries to match a known lab keyword and a numeric value (same catalog ids as the app’s PDF seed, e.g. `pdf_glucose_fasting`).
  3. Loads reference **min/max** from Firestore (`lab_tests`, then `test_definitions`).
  4. Writes a document to the **`analyses`** collection (fields aligned with `AnalysisModel` in Flutter).

## Prerequisites

1. **Blaze (pay-as-you-go)** on the Firebase project (Vision API + Cloud Functions).
2. Enable **Cloud Vision API** in Google Cloud Console for project `labby-31347`.
3. Deploy **Firestore rules** that allow your app’s catalog and user data (already in repo under `firebase/firestore.rules`).
4. Default Storage bucket must be the one Firebase provisions (same bucket the app uses for `putFile`).

## Local setup

```bash
cd functions
npm install
npm run build
```

## Deploy

From the repository root:

```bash
firebase deploy --only functions
```

First deploy may take several minutes.

## Emulator (optional)

```bash
cd functions
npm run serve
```

## Notes

- If OCR cannot find a known test + number, a row is still created with `status: Unknown` and a short OCR preview for debugging.
- The Flutter app may **also** save analyses locally after OCR; you can later deduplicate or disable client writes for the same upload if needed.
