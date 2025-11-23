const mongoose = require('mongoose');

const donationSchema = new mongoose.Schema({
  bloodBank: { type: mongoose.Schema.Types.ObjectId, ref: 'BloodBank', required: true },
  donor: { type: mongoose.Schema.Types.ObjectId, ref: 'Donor' }, // Optional if guest donor, but we prefer registered
  donorName: { type: String }, // Snapshot in case donor is deleted or guest
  bloodGroup: { type: String, required: true, enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'] },
  units: { type: Number, required: true, min: 1 },
  donationDate: { type: Date, default: Date.now },
  contactNumber: { type: String },
  address: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Donation', donationSchema);