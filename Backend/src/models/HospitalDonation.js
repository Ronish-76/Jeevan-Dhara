const mongoose = require('mongoose');

const hospitalDonationSchema = new mongoose.Schema({
  hospital: { type: mongoose.Schema.Types.ObjectId, ref: 'Hospital', required: true },
  donorName: { type: String, required: true },
  donorId: { type: String }, // Optional: link to registered donor if available
  bloodGroup: { type: String, required: true, enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'] },
  units: { type: Number, required: true, min: 1 },
  donationDate: { type: Date, default: Date.now },
  expiryDate: { type: Date }, // When the blood expires
  contactNumber: { type: String },
  address: { type: String },
  status: { type: String, enum: ['stocked', 'used', 'discarded'], default: 'stocked' }
}, { timestamps: true });

module.exports = mongoose.model('HospitalDonation', hospitalDonationSchema);