const admin = require('firebase-admin');

// Initialize Firebase Admin
// Make sure to either set GOOGLE_APPLICATION_CREDENTIALS environment variable
// or pass credentials directly if needed. 
// For basic ID token verification, often initializing with the matching project ID is enough,
// but full verification requires credentials.
try {
  if (!admin.apps.length) {
    // If you have a service account JSON, you can load it here.
    // For now we initialize the default app which uses GOOGLE_APPLICATION_CREDENTIALS
    // or we can pass projectId from env if available.
    admin.initializeApp({
      projectId: process.env.FIREBASE_PROJECT_ID || 'ankata-firebase-project',
    });
    console.log('Firebase Admin initialized');
  }
} catch (error) {
  console.error('Firebase Admin initialization error:', error);
}

module.exports = admin;
