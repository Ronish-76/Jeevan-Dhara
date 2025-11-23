import mongoose from 'mongoose';

const { Schema } = mongoose;

const pointSchema = new Schema(
  {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point',
    },
    coordinates: {
      type: [Number],
      required: true,
    },
  },
  { _id: false },
);

const bloodRequestSchema = new Schema(
  {
    requesterRole: {
      type: String,
      enum: ['patient', 'donor', 'hospital', 'blood_bank'],
      required: true,
    },
    requesterName: {
      type: String,
      required: true,
      trim: true,
    },
    requesterContact: {
      type: String,
      required: true,
      trim: true,
    },
    bloodGroup: {
      type: String,
      required: true,
      match: /^(A|B|AB|O)[+-]$/,
      uppercase: true,
    },
    units: {
      type: Number,
      required: true,
      min: 1,
      max: 10,
    },
    status: {
      type: String,
      enum: ['pending', 'responded', 'fulfilled', 'cancelled'],
      default: 'pending',
    },
    notes: {
      type: String,
      trim: true,
    },
    lat: {
      type: Number,
      required: true,
      min: -90,
      max: 90,
    },
    lng: {
      type: Number,
      required: true,
      min: -180,
      max: 180,
    },
    location: {
      type: pointSchema,
      required: true,
    },
    responderRole: {
      type: String,
      enum: ['patient', 'donor', 'hospital', 'blood_bank'],
    },
    responderName: String,
    responderContact: String,
    responseNote: String,
    respondedAt: Date,
  },
  { timestamps: true },
);

bloodRequestSchema.index({ status: 1, createdAt: -1 });
bloodRequestSchema.index({ bloodGroup: 1, status: 1 });
bloodRequestSchema.index({ location: '2dsphere' });

bloodRequestSchema.pre('validate', function syncLocation(next) {
  if (typeof this.lat === 'number' && typeof this.lng === 'number') {
    this.location = { type: 'Point', coordinates: [this.lng, this.lat] };
  } else if (this.location?.coordinates?.length === 2) {
    const [lng, lat] = this.location.coordinates;
    this.lat = lat;
    this.lng = lng;
  }
  next();
});

export default mongoose.model('BloodRequest', bloodRequestSchema);
