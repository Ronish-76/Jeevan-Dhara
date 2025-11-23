import mongoose from 'mongoose';

const { Schema } = mongoose;

const donationSchema = new Schema(
  {
    donorId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    donorName: {
      type: String,
      required: true,
    },
    bloodType: {
      type: String,
      required: true,
      match: /^(A|B|AB|O)[+-]$/,
      uppercase: true,
    },
    requestId: {
      type: Schema.Types.ObjectId,
      ref: 'BloodRequest',
    },
    facilityId: {
      type: Schema.Types.ObjectId,
      ref: 'Facility',
      required: true,
    },
    facilityName: {
      type: String,
      required: true,
    },
    quantity: {
      type: Number,
      default: 1,
      min: 1,
    },
    donationDate: {
      type: Date,
      default: Date.now,
    },
    status: {
      type: String,
      enum: ['scheduled', 'completed', 'cancelled'],
      default: 'scheduled',
    },
    notes: String,
  },
  { timestamps: true },
);

donationSchema.index({ donorId: 1 });
donationSchema.index({ requestId: 1 });
donationSchema.index({ facilityId: 1 });
donationSchema.index({ donationDate: -1 });
donationSchema.index({ status: 1 });

export default mongoose.model('Donation', donationSchema);
