import mongoose from 'mongoose';

const { Schema } = mongoose;

const geoLocationSchema = new Schema(
  {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point',
    },
    coordinates: {
      type: [Number], // [lng, lat]
      required: true,
    },
  },
  { _id: false },
);

const userSchema = new Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
      index: true,
    },
    phone: {
      type: String,
      required: true,
    },
    password: {
      type: String,
      required: true,
    },
    role: {
      type: String,
      enum: ['patient', 'requester', 'donor', 'hospital', 'blood_bank'],
      required: true,
    },
    // For donors: blood type
    bloodType: {
      type: String,
      match: /^(A|B|AB|O)[+-]$/,
      uppercase: true,
    },
    // For donors: availability status
    isAvailable: {
      type: Boolean,
      default: true,
    },
    // For hospitals/blood banks: location reference
    facilityId: {
      type: Schema.Types.ObjectId,
      ref: 'Facility',
    },
    // User's current location (for donors and patients)
    geo: {
      type: geoLocationSchema,
    },
    address: {
      street: String,
      city: String,
      district: String,
    },
    // Additional metadata
    metadata: {
      lastDonationDate: Date,
      totalDonations: { type: Number, default: 0 },
      isVerified: { type: Boolean, default: false },
    },
  },
  {
    timestamps: true,
  },
);

// Indexes
userSchema.index({ role: 1 });
userSchema.index({ geo: '2dsphere' });
userSchema.index({ bloodType: 1, isAvailable: 1 });

export default mongoose.model('User', userSchema);



