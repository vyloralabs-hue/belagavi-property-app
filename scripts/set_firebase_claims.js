/**
 * Server-side Firebase Admin script to assign { role: "authenticated" } 
 * custom claims to all Firebase Auth users for Supabase Third-Party Auth integration.
 *
 * Uses modern modular Firebase Admin SDK APIs (firebase-admin/app and firebase-admin/auth).
 *
 * Usage:
 * 1. Set GOOGLE_APPLICATION_CREDENTIALS to your service account JSON file path.
 * 2. node scripts/set_firebase_claims.js
 */

const fs = require('fs');
const path = require('path');
const { initializeApp, applicationDefault, getApps } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

async function main() {
  console.log('--- FIREBASE CUSTOM CLAIMS ASSIGNMENT SCRIPT (MODULAR SDK) ---');

  // 1. Validate GOOGLE_APPLICATION_CREDENTIALS environment variable
  const credPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (!credPath) {
    console.error('ERROR: GOOGLE_APPLICATION_CREDENTIALS is not configured in the environment.');
    console.error('Please set GOOGLE_APPLICATION_CREDENTIALS to the path of your serviceAccountKey.json file.');
    console.error('Example (PowerShell): $env:GOOGLE_APPLICATION_CREDENTIALS="C:\\path\\to\\serviceAccountKey.json"');
    process.exitCode = 1;
    return;
  }

  const resolvedPath = path.resolve(credPath);
  if (!fs.existsSync(resolvedPath)) {
    console.error(`ERROR: Service account key file not found at: ${resolvedPath}`);
    process.exitCode = 1;
    return;
  }

  // 2. Modular Firebase Admin Initialization
  try {
    if (getApps().length === 0) {
      initializeApp({
        credential: applicationDefault(),
        projectId: 'belagavi-property',
      });
      console.log('Firebase Admin modular SDK initialized successfully for project: belagavi-property');
    }
  } catch (initErr) {
    console.error(`ERROR: Failed to initialize Firebase Admin: ${initErr.message}`);
    process.exitCode = 1;
    return;
  }

  const auth = getAuth();

  // 3. Process Users and Assign Custom Claims
  let totalProcessed = 0;
  let totalUpdated = 0;
  let totalAlreadyCorrect = 0;
  let totalFailures = 0;
  let roleCollisionDetected = false;
  let nextPageToken = undefined;

  try {
    do {
      let listUsersResult;
      try {
        listUsersResult = await auth.listUsers(1000, nextPageToken);
      } catch (listErr) {
        console.error(`ERROR: Failed to list Firebase users: ${listErr.message}`);
        totalFailures++;
        break;
      }

      const users = (listUsersResult && Array.isArray(listUsersResult.users)) ? listUsersResult.users : [];
      totalProcessed += users.length;

      for (const userRecord of users) {
        if (!userRecord || !userRecord.uid) continue;

        try {
          const existingClaims = (userRecord.customClaims && typeof userRecord.customClaims === 'object') 
            ? userRecord.customClaims 
            : {};

          // Check for role claim collisions with business roles (e.g. founder, admin, seller)
          if (existingClaims.role && existingClaims.role !== 'authenticated') {
            roleCollisionDetected = true;
            console.warn(`NOTICE: User UID prefix ${userRecord.uid.substring(0, 6)}... has existing business role '${existingClaims.role}'. Preserving as business_role.`);
            
            const newClaims = {
              ...existingClaims,
              business_role: existingClaims.role,
              role: 'authenticated',
            };
            await auth.setCustomUserClaims(userRecord.uid, newClaims);
            totalUpdated++;
          } else if (existingClaims.role === 'authenticated') {
            totalAlreadyCorrect++;
          } else {
            const newClaims = {
              ...existingClaims,
              role: 'authenticated',
            };
            await auth.setCustomUserClaims(userRecord.uid, newClaims);
            totalUpdated++;
          }
        } catch (claimErr) {
          totalFailures++;
          console.error(`Failed to set claims for user UID prefix ${userRecord.uid.substring(0, 6)}...: ${claimErr.message}`);
        }
      }

      nextPageToken = listUsersResult ? listUsersResult.pageToken : undefined;
    } while (nextPageToken);

    console.log('--- EXECUTION SUMMARY ---');
    console.log(`ROLE CLAIM COLLISION: ${roleCollisionDetected ? 'YES (Handled / Preserved)' : 'NO'}`);
    console.log(`USERS PROCESSED: ${totalProcessed}`);
    console.log(`USERS UPDATED: ${totalUpdated}`);
    console.log(`USERS ALREADY CORRECT: ${totalAlreadyCorrect}`);
    console.log(`FAILURES: ${totalFailures}`);
  } catch (loopErr) {
    console.error(`ERROR: Unexpected error during claim assignment: ${loopErr.message}`);
    process.exitCode = 1;
  }
}

main().catch((err) => {
  console.error(`Fatal error: ${err.message}`);
  process.exitCode = 1;
});
