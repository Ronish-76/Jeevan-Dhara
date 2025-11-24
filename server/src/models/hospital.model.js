import mongoose from 'mongoose';
import Location from './location.model.js';

const hospitalSchema = new mongoose.Schema(
  {
    departments: [{ type: String, trim: true }],
    capacity: { type: Number, min: 0 },
    emergencyServices: { type: Boolean, default: true },
  },
  { _id: false },
);

const Hospital = Location.discriminator('hospital', hospitalSchema);

export default Hospital;

