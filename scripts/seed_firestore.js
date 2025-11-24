const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin SDK
// Ensure you have your service account key in a file pointed to by GOOGLE_APPLICATION_CREDENTIALS
// or initialize with specific credential file:
// const serviceAccount = require('./path/to/serviceAccountKey.json');
// admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();
const LOCATIONS_FILE = path.join(__dirname, '../server/src/seed/locations.json');

async function seedLocations() {
  try {
    console.log('Reading locations from:', LOCATIONS_FILE);
    const rawData = fs.readFileSync(LOCATIONS_FILE);
    const locations = JSON.parse(rawData);

    console.log(`Found ${locations.length} locations to seed.`);

    const batchLimit = 500;
    let batch = db.batch();
    let count = 0;

    for (const loc of locations) {
      // Create a reference for the new document
      const docRef = db.collection('locations').doc(); // Auto-ID or use loc.id if available

      // Transform data to match Firestore schema
      const firestoreData = {
        name: loc.name,
        type: loc.type, // 'hospital' or 'blood_bank'
        roleAccess: loc.roleAccess || [],
        address: loc.address ? `${loc.address.street}, ${loc.address.city}, ${loc.address.district}` : '',
        contactNumber: loc.contactNumber,
        email: loc.email,
        bloodTypesAvailable: loc.bloodTypesAvailable || [],
        services: loc.services || [],
        availability: loc.availability || {},
        // Convert GeoJSON Point to Firestore GeoPoint
        coordinates: new admin.firestore.GeoPoint(
          loc.coordinates.coordinates[1], // Latitude
          loc.coordinates.coordinates[0]  // Longitude
        ),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      batch.set(docRef, firestoreData);
      count++;

      if (count % batchLimit === 0) {
        console.log(`Committing batch of ${batchLimit} documents...`);
        await batch.commit();
        batch = db.batch();
      }
    }

    if (count % batchLimit !== 0) {
      console.log(`Committing final batch of ${count % batchLimit} documents...`);
      await batch.commit();
    }

    console.log('Seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding locations:', error);
    process.exit(1);
  }
}

seedLocations();
