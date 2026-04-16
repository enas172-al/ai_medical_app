/**
 * Labby – Cloud Functions
 *
 * Trigger: finalization of an object in the default Storage bucket under
 *   users/{userId}/analyses/{fileName}
 *
 * Flow: Vision API text detection → simple keyword + number parse →
 *       lookup reference range in Firestore (lab_tests, then test_definitions) →
 *       write document to `analyses` (same shape as Flutter AnalysisModel).
 */

import * as admin from "firebase-admin";
import {onObjectFinalized} from "firebase-functions/v2/storage";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {logger} from "firebase-functions";
import {ImageAnnotatorClient} from "@google-cloud/vision";

admin.initializeApp();

const vision = new ImageAnnotatorClient();

const LAB_COLLECTIONS = ["lab_tests", "test_definitions"] as const;

/** Matches seeded PDF catalog document ids in DatabaseService.seedPdfLabTests */
const KEYWORD_TO_DOC_ID: Record<string, string> = {
  "fasting glucose": "pdf_glucose_fasting",
  "blood glucose": "pdf_glucose_fasting",
  glucose: "pdf_glucose_fasting",
  fbs: "pdf_glucose_fasting",
  hemoglobin: "pdf_hemoglobin",
  hgb: "pdf_hemoglobin",
  hb: "pdf_hemoglobin",
  hematocrit: "pdf_hematocrit",
  hct: "pdf_hematocrit",
  wbc: "pdf_wbc",
  platelets: "pdf_platelets",
  plt: "pdf_platelets",
  rbc: "pdf_rbc",
  creatinine: "pdf_creatinine",
  urea: "pdf_urea",
  bun: "pdf_urea",
  calcium: "pdf_calcium",
  sodium: "pdf_sodium",
  potassium: "pdf_potassium",
  alt: "pdf_alt",
  sgpt: "pdf_alt",
  ast: "pdf_ast",
  sgot: "pdf_ast",
  alp: "pdf_alp",
  bilirubin: "pdf_bilirubin_total",
  tsh: "pdf_tsh",
  "free t4": "pdf_free_t4",
  ft4: "pdf_free_t4",
  cortisol: "pdf_cortisol",
  "vitamin d": "pdf_vitamin_d",
  "vitamin b12": "pdf_vitamin_b12",
  b12: "pdf_vitamin_b12",
  iron: "pdf_iron",
};

const SORTED_KEYWORDS = Object.entries(KEYWORD_TO_DOC_ID).sort(
  (a, b) => b[0].length - a[0].length,
);

interface LabDoc {
  normalMin?: number;
  normalMax?: number;
  unit?: string;
  nameEn?: string;
  nameAr?: string;
}

function parseUserIdFromPath(filePath: string): string | null {
  const m = filePath.match(/^users\/([^/]+)\/analyses\/[^/]+$/);
  return m ? m[1] : null;
}

async function buildDownloadUrl(bucketName: string, filePath: string): Promise<string | null> {
  const file = admin.storage().bucket(bucketName).file(filePath);
  const [meta] = await file.getMetadata();
  const token = meta.metadata?.firebaseStorageDownloadTokens;
  if (typeof token === "string" && token.length > 0) {
    const enc = encodeURIComponent(filePath);
    return `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${enc}?alt=media&token=${token}`;
  }
  return null;
}

async function fetchLabDoc(docId: string): Promise<{data: LabDoc} | null> {
  const db = admin.firestore();
  for (const col of LAB_COLLECTIONS) {
    const snap = await db.collection(col).doc(docId).get();
    if (snap.exists) {
      return {data: snap.data() as LabDoc};
    }
  }
  return null;
}

function computeStatus(value: number, min: number, max: number): string {
  const eps = 1e-9;
  if (value < min - eps) return "Low";
  if (value > max + eps) return "High";
  return "Normal";
}

function parseLastNumber(nums: string[]): number | null {
  for (let i = nums.length - 1; i >= 0; i--) {
    const v = parseFloat(nums[i]);
    if (!Number.isNaN(v)) return v;
  }
  return null;
}

function tryParseLine(line: string): {docId: string; value: number} | null {
  const lower = line.toLowerCase();
  for (const [kw, docId] of SORTED_KEYWORDS) {
    if (lower.includes(kw)) {
      const nums = line.match(/-?\d+(?:[.,]\d+)?/g);
      if (!nums || nums.length === 0) continue;
      const normalized = nums.map((n) => n.replace(",", "."));
      const value = parseLastNumber(normalized);
      if (value != null) return {docId, value};
    }
  }
  return null;
}

export const onAnalysisImageUploaded = onObjectFinalized(
  {
    region: "europe-west1",
    memory: "512MiB",
    timeoutSeconds: 120,
  },
  async (event) => {
    const bucket = event.data.bucket;
    const filePath = event.data.name;
    const contentType = event.data.contentType ?? "";

    if (!filePath) {
      logger.info("Skip: empty path");
      return;
    }
    if (!contentType.startsWith("image/")) {
      logger.info("Skip: not an image", {filePath, contentType});
      return;
    }

    const userId = parseUserIdFromPath(filePath);
    if (!userId) {
      logger.info("Skip: path not users/{uid}/analyses/", {filePath});
      return;
    }

    let imageUrl: string | null = null;
    try {
      imageUrl = await buildDownloadUrl(bucket, filePath);
    } catch (e) {
      logger.warn("Could not build download URL", {e, filePath});
    }

    try {
      const [visionResult] = await vision.textDetection({
        image: {source: {imageUri: `gs://${bucket}/${filePath}`}},
      });

      const fullText =
        visionResult.fullTextAnnotation?.text ??
        visionResult.textAnnotations?.[0]?.description ??
        "";
      let parsed: {docId: string; value: number} | null = null;
      for (const line of fullText.split(/\r?\n/)) {
        const t = tryParseLine(line.trim());
        if (t) {
          parsed = t;
          break;
        }
      }

      const db = admin.firestore();
      const baseFields = {
        userId,
        date: admin.firestore.FieldValue.serverTimestamp(),
        imageUrl: imageUrl ?? null,
        processingSource: "cloud_function_onAnalysisImageUploaded",
      };

      if (!parsed) {
        await db.collection("analyses").add({
          ...baseFields,
          testName: "Pending OCR parse",
          value: 0,
          unit: "",
          normalRange: {},
          status: "Unknown",
          simplifiedExplanation:
            "لم يتم التعرف على تحليل ورقم من الصورة تلقائياً. يمكنك إدخال النتيجة يدوياً من التطبيق.",
          rawOcrPreview: fullText.slice(0, 800),
        });
        logger.warn("No keyword/value parsed from OCR", {userId, filePath});
        return;
      }

      const lab = await fetchLabDoc(parsed.docId);
      const testName =
        lab?.data.nameEn || lab?.data.nameAr || parsed.docId;
      const unit = lab?.data.unit ?? "";

      if (
        lab?.data.normalMin == null ||
        lab?.data.normalMax == null ||
        Number.isNaN(lab.data.normalMin) ||
        Number.isNaN(lab.data.normalMax)
      ) {
        await db.collection("analyses").add({
          ...baseFields,
          testName,
          value: parsed.value,
          unit,
          normalRange: {},
          status: "Unknown",
          simplifiedExplanation:
            "تم قراءة قيمة من الصورة لكن المعدل الطبيعي غير متوفر في الكتالوج.",
          matchedCatalogId: parsed.docId,
          rawOcrPreview: fullText.slice(0, 400),
        });
        return;
      }

      const min = lab.data.normalMin as number;
      const max = lab.data.normalMax as number;
      const status = computeStatus(parsed.value, min, max);

      const simplifiedExplanation =
        status === "Low"
          ? `${testName} أقل من المعدل المعتاد (${min}–${max} ${unit}). القياس: ${parsed.value} ${unit}.`
          : status === "High"
            ? `${testName} أعلى من المعدل المعتاد (${min}–${max} ${unit}). القياس: ${parsed.value} ${unit}.`
            : `${testName} ضمن المعدل المعتاد (${min}–${max} ${unit}). القياس: ${parsed.value} ${unit}.`;

      await db.collection("analyses").add({
        ...baseFields,
        testName,
        value: parsed.value,
        unit,
        normalRange: {min, max},
        status,
        simplifiedExplanation,
        matchedCatalogId: parsed.docId,
      });

      logger.info("Analysis document created", {
        userId,
        filePath,
        testName,
        status,
      });
    } catch (err) {
      logger.error("onAnalysisImageUploaded failed", err as Error, {
        userId,
        filePath,
      });
      throw err;
    }
  },
);

/**
 * Push notification fanout: when the app writes a notification document to Firestore,
 * send an FCM push so it appears even if the app is closed.
 *
 * Collection: `notifications/{id}`
 * Expected fields: userId, title, body, data (optional)
 */
export const onNotificationCreated = onDocumentCreated(
  {
    region: "europe-west1",
    document: "notifications/{notificationId}",
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const notifId = snap.id;
    const n = snap.data() as Record<string, unknown>;

    const userId = (n.userId as string | undefined)?.trim();
    const title = (n.title as string | undefined)?.trim() || "Labby";
    const body = (n.body as string | undefined)?.trim() || "";
    const data = (n.data as Record<string, string> | undefined) ?? {};

    if (!userId || body.length === 0) {
      logger.info("Skip push: missing userId/body", {notifId});
      return;
    }

    // Prevent duplicates if this function is retried.
    if (n.fcmMessageId || n.sentAt) {
      logger.info("Skip push: already sent", {notifId});
      return;
    }

    try {
      const userSnap = await admin.firestore().collection("users").doc(userId).get();
      const token = (userSnap.data()?.fcmToken as string | undefined)?.trim();
      if (!token) {
        logger.info("Skip push: missing fcmToken", {notifId, userId});
        return;
      }

      const res = await admin.messaging().send({
        token,
        notification: {title, body},
        data: {
          notificationId: notifId,
          ...data,
        },
        android: {
          notification: {
            channelId: "labby_general",
          },
        },
      });

      await snap.ref.set(
        {
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          fcmMessageId: res,
        },
        {merge: true},
      );

      logger.info("Push sent", {notifId, userId});
    } catch (e) {
      logger.error("onNotificationCreated failed", e as Error, {notifId, userId});
      throw e;
    }
  },
);
