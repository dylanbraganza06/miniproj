const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

exports.sendSOSAlert = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { userId, driverId, latitude, longitude, timestamp } = req.body;

    if (!userId || !driverId || latitude == null || longitude == null || !timestamp) {
      res.status(400).json({ error: 'Missing required fields' });
      return;
    }

    const alertData = {
      userId,
      driverId,
      latitude,
      longitude,
      timestamp,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'ACTIVE',
    };

    await db.collection('sos_alerts').add(alertData);

    const userDoc = await db.collection('users').doc(userId).get();
    const driverDoc = await db.collection('drivers').doc(driverId).get();

    const emergencyContactPhone = userDoc.exists
      ? userDoc.data().emergencyContactPhone || null
      : null;

    const payload = {
      notification: {
        title: 'SafeRide SOS Alert',
        body: `Emergency reported for driver ${driverDoc.exists ? driverDoc.data().driverName : driverId}`,
      },
      data: {
        type: 'SOS_ALERT',
        userId,
        driverId,
        latitude: String(latitude),
        longitude: String(longitude),
      },
      topic: 'sos_alerts',
    };

    await admin.messaging().send(payload);

    // Placeholder for future Twilio SMS/WhatsApp integration using emergencyContactPhone.
    res.status(200).json({ success: true, emergencyContactPhone });
  } catch (error) {
    console.error('sendSOSAlert error', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

exports.analyzeDriverReview = functions.firestore
  .document('reviews/{reviewId}')
  .onCreate(async (snapshot) => {
    try {
      const review = snapshot.data();
      const reviewText = review.reviewText || '';
      const driverId = review.driverId;

      if (!driverId) {
        console.error('Missing driverId in review');
        return;
      }

      const prompt =
        'Analyze this driver review and assign safety score from 0-100 and risk level LOW, MEDIUM, HIGH. Return ONLY JSON with keys safetyScore and riskLevel. Review: ' +
        reviewText;

      const apiKey = functions.config().openai && functions.config().openai.key;
      if (!apiKey) {
        console.error('Missing OpenAI API key. Set with: firebase functions:config:set openai.key="YOUR_KEY"');
        return;
      }

      const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: 'gpt-4o',
          messages: [
            {
              role: 'system',
              content:
                'You are a strict safety auditor. Output only valid JSON, no markdown.',
            },
            { role: 'user', content: prompt },
          ],
          temperature: 0.2,
        }),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`OpenAI API failure: ${response.status} ${errorText}`);
      }

      const completion = await response.json();
      const content = completion.choices?.[0]?.message?.content;
      const parsed = JSON.parse(content);

      const safetyScore = Math.max(0, Math.min(100, Number(parsed.safetyScore) || 50));
      const riskLevel = ['LOW', 'MEDIUM', 'HIGH'].includes(String(parsed.riskLevel).toUpperCase())
        ? String(parsed.riskLevel).toUpperCase()
        : 'MEDIUM';

      await db.collection('drivers').doc(driverId).set(
        {
          safetyScore,
          riskLevel,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    } catch (error) {
      console.error('analyzeDriverReview error', error);
    }
  });
