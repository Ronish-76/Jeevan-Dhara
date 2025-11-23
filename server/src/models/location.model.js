import mongoose from 'mongoose';

const { Schema } = mongoose;

const availabilitySchema = new Schema(
  {
    inventoryLevel: {
      type: String,
      enum: ['low', 'medium', 'high'],
      default: 'medium',
    },
    acceptingDonations: {
      type: Boolean,
      default: true,
    },
    donorsNeeded: {
      type: Boolean,
      default: false,
    },
  },
  { _id: false },
);

const locationSchema = new Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    type: {
      type: String,
      enum: ['hospital', 'blood_bank'],
      required: true,
      default: 'hospital',
    },
    roleAccess: [
      {
        type: String,
        enum: ['patient', 'donor', 'hospital', 'blood_bank'],
      },
    ],
    address: {
      street: { type: String, required: true },
      city: { type: String, default: 'Kathmandu' },
      district: { type: String, default: 'Kathmandu' },
    },
    contactNumber: {
      type: String,
      required: true,
    },
    email: {
      type: String,
    },
    bloodTypesAvailable: [
      {
        type: String,
        uppercase: true,
        match: /^(A|B|AB|O)[+-]$/,
      },
    ],
    services: [{ type: String }],
    availability: {
      type: availabilitySchema,
      default: () => ({}),
    },
    metadata: {
      lastInventorySync: Date,
      notes: String,
    },
    geo: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number], // [lng, lat]
        required: true,
        validate: {
          validator(value) {
            const [lng, lat] = value;
            return (
              Array.isArray(value) &&
              value.length === 2 &&
              lat >= -90 &&
              lat <= 90 &&
              lng >= -180 &&
              lng <= 180
            );
          },
          message: 'Invalid coordinates supplied',
        },
      },
    },
    // Keep legacy coordinates field for backward compatibility
    coordinates: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number], // [lng, lat]
        required: false,
        validate: {
          validator(value) {
            if (!value) return true;
            const [lng, lat] = value;
            return (
              Array.isArray(value) &&
              value.length === 2 &&
              lat >= -90 &&
              lat <= 90 &&
              lng >= -180 &&
              lng <= 180
            );
          },
          message: 'Invalid coordinates supplied',
        },
      },
    },
    // Inventory structure: { "A+": 10, "B+": 5, ... }
    inventory: {
      type: Map,
      of: Number,
      default: () => ({}),
    },
  },
  {
    timestamps: true,
    discriminatorKey: 'type',
  },
);

// Create 2dsphere indexes for geospatial queries
locationSchema.index({ geo: '2dsphere' });
locationSchema.index({ coordinates: '2dsphere' });

const Location = mongoose.model('Location', locationSchema);

export default Location;

