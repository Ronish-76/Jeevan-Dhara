const mongoose = require('mongoose');

const distributionSchema = new mongoose.Schema({
  bloodBank: { type: mongoose.Schema.Types.ObjectId, ref: 'BloodBank', required: true },
  hospital: { type: mongoose.Schema.Types.ObjectId, ref: 'Hospital', required: true },
  hospitalName: { type: String }, // Snapshot
  bloodGroup: { type: String, required: true, enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'] },
  units: { type: Number, required: true, min: 1 },
  dispatchDate: { type: Date, default: Date.now },
  courierName: { type: String },
  vehicleNumber: { type: String },
  driverContact: { type: String },
  status: { type: String, enum: ['dispatched', 'delivered'], default: 'dispatched' }
}, { timestamps: true });

module.exports = mongoose.model('Distribution', distributionSchema);