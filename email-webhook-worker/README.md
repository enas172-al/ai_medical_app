# Email webhook worker (free alternative to Firebase Functions)

This worker receives a POST request and sends an email using SendGrid.

## Why
Firebase Cloud Functions require the Blaze plan (billing). This worker is a free alternative
that keeps your SendGrid API key on the server side (not inside the Flutter app).

## Deploy (Cloudflare Workers)
1. Install Wrangler
2. Create a Worker project in this folder
3. Set secrets
4. Deploy

Example commands (run inside `email-webhook-worker/`):

```bash
npm i -g wrangler
wrangler login
wrangler deploy

wrangler secret put SENDGRID_API_KEY
wrangler secret put SENDGRID_FROM_EMAIL
wrangler secret put SENDGRID_FROM_NAME
```

## Flutter app config
Build the app with:

```bash
flutter run --dart-define=EMAIL_WEBHOOK_URL=https://<your-worker>.workers.dev/email
```

The app will send email when:
- `Email notifications` toggle is enabled
- It creates a notification document for the user (Firestore `notifications` collection)

