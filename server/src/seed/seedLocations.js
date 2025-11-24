import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { connectDB, disconnectDB } from '../config/db.js';
import Location from '../models/location.model.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const seedLocations = async () => {
  try {
    await connectDB();
    const dataPath = path.join(__dirname, 'locations.json');
    const raw = fs.readFileSync(dataPath, 'utf-8');
    const locations = JSON.parse(raw);

    await Location.deleteMany({});

    // Ensure geo field is set from coordinates
    const processedLocations = locations.map((loc) => {
      if (loc.coordinates && !loc.geo) {
        loc.geo = loc.coordinates;
      }
      // Ensure inventory exists if bloodTypesAvailable is provided
      if (loc.bloodTypesAvailable && !loc.inventory) {
        const inv = {};
        loc.bloodTypesAvailable.forEach((bt) => {
          inv[bt] = Math.floor(Math.random() * 50) + 10; // Random inventory 10-60 units
        });
        loc.inventory = inv;
      }
      return loc;
    });

    await Location.insertMany(processedLocations);

    console.log(`Seeded ${locations.length} locations`);
  } catch (error) {
    console.error('Seeding failed:', error);
  } finally {
    await disconnectDB();
    process.exit(0);
  }
};

seedLocations();

