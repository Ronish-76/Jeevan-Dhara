import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import mongoose from 'mongoose';
import Facility from '../src/models/facility.model.js';

const mongoUri = process.env.MONGO_URI;

if (!mongoUri) {
  console.error('Missing MONGO_URI environment variable');
  process.exit(1);
}

const dataPath = path.resolve(process.cwd(), '../data/kathmandu_facilities.json');

const seed = async () => {
  try {
    await mongoose.connect(mongoUri, { autoIndex: true });

    const raw = fs.readFileSync(dataPath, 'utf-8');
    const facilities = JSON.parse(raw);

    await Facility.deleteMany({});
    const docs = facilities.map((facility) => ({
      ...facility,
      location: {
        type: 'Point',
        coordinates: [facility.lng, facility.lat],
      },
    }));

    await Facility.insertMany(docs);
    console.log(`Seeded ${docs.length} Kathmandu facilities`);
  } catch (error) {
    console.error('Failed to seed facilities:', error);
    process.exitCode = 1;
  } finally {
    await mongoose.disconnect();
  }
};

seed();
