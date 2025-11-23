import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import mongoose from 'mongoose';
import Location from '../src/models/location.model.js';
import Hospital from '../src/models/hospital.model.js';
import BloodBank from '../src/models/bloodBank.model.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const uri = process.env.MONGO_URI || process.env.MONGODB_URI;

if (!uri) {
  console.error('Missing MONGO_URI or MONGODB_URI environment variable');
  process.exit(1);
}

const seedLocations = async () => {
  try {
    await mongoose.connect(uri, {
      autoIndex: true,
    });

    // Read from data/kathmandu_locations.json (at project root)
    const dataPath = path.join(__dirname, '../../data/kathmandu_locations.json');
    const raw = fs.readFileSync(dataPath, 'utf-8');
    const locations = JSON.parse(raw);

    // Delete existing locations
    await Location.deleteMany({});

    // Ensure geo field is set from coordinates
    const processedLocations = locations.map((loc) => {
      if (loc.coordinates && !loc.geo) {
        loc.geo = loc.coordinates;
      }
      // Ensure inventory exists if bloodTypesAvailable is provided (for blood banks)
      if (loc.type === 'blood_bank' && loc.bloodTypesAvailable && !loc.inventory) {
        const inv = {};
        loc.bloodTypesAvailable.forEach((bt) => {
          inv[bt] = Math.floor(Math.random() * 50) + 10; // Random inventory 10-60 units
        });
        loc.inventory = inv;
      }
      return loc;
    });

    const hospitals = processedLocations.filter((loc) => loc.type === 'hospital');
    const bloodBanks = processedLocations.filter((loc) => loc.type === 'blood_bank');
    const others = processedLocations.filter(
      (loc) => !['hospital', 'blood_bank'].includes(loc.type),
    );

    if (hospitals.length) {
      await Hospital.insertMany(hospitals);
      console.log(`✓ Seeded ${hospitals.length} hospitals`);
    }
    if (bloodBanks.length) {
      await BloodBank.insertMany(bloodBanks);
      console.log(`✓ Seeded ${bloodBanks.length} blood banks`);
    }
    if (others.length) {
      await Location.insertMany(others);
      console.log(`✓ Seeded ${others.length} other locations`);
    }

    console.log(`\n✅ Successfully seeded ${processedLocations.length} locations`);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exitCode = 1;
  } finally {
    await mongoose.disconnect();
    process.exit(0);
  }
};

seedLocations();
