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
      validate(value) {
        return Array.isArray(value) && value.length === 2 && value.every((num) => typeof num === 'number');
      },
    },
  },
  { _id: false },
);

const facilitySchema = new Schema(
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
    },
    address: {
      type: String,
      required: true,
      trim: true,
    },
    contact: {
      type: String,
      required: true,
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
    services: [{ type: String, trim: true }],
    tags: [{ type: String, trim: true }],
  },
  { timestamps: true },
);

facilitySchema.index({ location: '2dsphere' });
facilitySchema.index({ type: 1 });

facilitySchema.pre('validate', function syncLocation(next) {
  if (typeof this.lat === 'number' && typeof this.lng === 'number') {
    this.location = { type: 'Point', coordinates: [this.lng, this.lat] };
  } else if (this.location?.coordinates?.length === 2) {
    const [lng, lat] = this.location.coordinates;
    this.lat = lat;
    this.lng = lng;
  }
  next();
});

export default mongoose.model('Facility', facilitySchema);
