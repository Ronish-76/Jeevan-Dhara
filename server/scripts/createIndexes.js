import 'dotenv/config';
import mongoose from 'mongoose';
import Facility from '../src/models/facility.model.js';
import BloodRequest from '../src/models/bloodRequest.model.js';
import Donation from '../src/models/donation.model.js';
import User from '../src/models/user.model.js';

const mongoUri = process.env.MONGO_URI;

if (!mongoUri) {
  console.error('Missing MONGO_URI environment variable');
  process.exit(1);
}

const createIndexes = async () => {
  try {
    await mongoose.connect(mongoUri, { autoIndex: true });

    await Promise.all([
      Facility.syncIndexes(),
      BloodRequest.syncIndexes(),
      Donation.syncIndexes(),
      User.syncIndexes(),
    ]);

    console.log('MongoDB indexes synchronized');
  } catch (error) {
    console.error('Failed to create indexes:', error);
    process.exitCode = 1;
  } finally {
    await mongoose.disconnect();
  }
};

createIndexes();
