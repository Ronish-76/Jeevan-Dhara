import mongoose from 'mongoose';
import Location from './location.model.js';

const bloodBankSchema = new mongoose.Schema(
  {
    operatingHours: { type: String, trim: true },
    vehiclesAvailable: { type: Number, min: 0, default: 0 },
  },
  { _id: false },
);

const BloodBank = Location.discriminator('blood_bank', bloodBankSchema);

export default BloodBank;

