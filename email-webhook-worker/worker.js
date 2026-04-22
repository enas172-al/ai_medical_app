/**
 * Cloudflare Worker: POST /email
 * Body: { to, subject, text, userId?, data? }
 *
 * Secrets:
 * - SENDGRID_API_KEY
 * - SENDGRID_FROM_EMAIL
 * - SENDGRID_FROM_NAME (optional)
 */

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (request.method !== "POST" || url.pathname !== "/email") {
      return new Response("Not found", { status: 404 });
    }

    let payload;
    try {
      payload = await request.json();
    } catch {
      return new Response("Invalid JSON", { status: 400 });
    }

    const to = (payload?.to || "").toString().trim();
    const subject = (payload?.subject || "Labby").toString().trim();
    const text = (payload?.text || "").toString().trim();
    if (!to || !text) return new Response("Missing to/text", { status: 400 });

    const apiKey = (env.SENDGRID_API_KEY || "").toString().trim();
    const fromEmail = (env.SENDGRID_FROM_EMAIL || "").toString().trim();
    const fromName = (env.SENDGRID_FROM_NAME || "Labby").toString().trim();
    if (!apiKey || !fromEmail) return new Response("Missing SendGrid secrets", { status: 500 });

    const sgRes = await fetch("https://api.sendgrid.com/v3/mail/send", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        personalizations: [{ to: [{ email: to }] }],
        from: { email: fromEmail, name: fromName },
        subject,
        content: [{ type: "text/plain", value: text }],
      }),
    });

    if (!sgRes.ok) {
      const err = await sgRes.text().catch(() => "");
      return new Response(`SendGrid error: ${sgRes.status}\n${err}`, { status: 502 });
    }

    return new Response("OK", { status: 200 });
  },
};

