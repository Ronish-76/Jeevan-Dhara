import createError from 'http-errors';
import BloodRequest from '../models/bloodRequest.model.js';
import User from '../models/user.model.js';
import Donation from '../models/donation.model.js';
import Location from '../models/location.model.js';
import { respondRequestSchema } from '../utils/validators.js';

// Donor accepts a blood request
export const acceptRequest = async (req, res, next) => {
  try {
    // Validate request body
    const { error, value } = respondRequestSchema.validate(req.body);
    if (error) {
      throw createError(400, error.details[0].message);
    }

    const { requestId, donorId, locationId, notes } = value;

    // Check if request exists and is pending
    const bloodRequest = await BloodRequest.findById(requestId);

    if (!bloodRequest) {
      throw createError(404, 'Blood request not found');
    }

    if (bloodRequest.status !== 'pending') {
      throw createError(400, `Request is already ${bloodRequest.status}`);
    }

    // Check if donor exists
    const donor = await User.findById(donorId);

    if (!donor) {
      throw createError(404, 'Donor not found');
    }

    if (donor.role !== 'donor') {
      throw createError(400, 'User is not a donor');
    }

    // Verify blood type compatibility (basic check)
    if (donor.bloodType && donor.bloodType !== bloodRequest.bloodGroup) {
      // Basic compatibility - in reality, O- can donate to anyone, O+ to any positive, etc.
      // This is simplified
      const canDonate = isCompatibleDonor(donor.bloodType, bloodRequest.bloodGroup);
      if (!canDonate) {
        throw createError(400, `Blood type ${donor.bloodType} is not compatible with requested ${bloodRequest.bloodGroup}`);
      }
    }

    // Get location details
    let location = null;
    if (locationId) {
      location = await Location.findById(locationId);
      if (!location) {
        throw createError(404, 'Location not found');
      }
    }

    // Update blood request
    bloodRequest.status = 'accepted';
    bloodRequest.acceptedBy = donorId;
    bloodRequest.acceptedAt = new Date();
    if (location) {
      bloodRequest.facilityId = location._id;
      bloodRequest.facilityName = location.name;
    }
    await bloodRequest.save();

    // Create donation record
    const donation = new Donation({
      donorId,
      donorName: donor.name,
      bloodType: bloodRequest.bloodGroup,
      requestId,
      locationId: location ? location._id : null,
      locationName: location ? location.name : 'Unknown',
      quantity: bloodRequest.quantity,
      status: 'scheduled',
      notes,
    });

    await donation.save();

    // Update donor's donation count
    donor.metadata = donor.metadata || {};
    donor.metadata.totalDonations = (donor.metadata.totalDonations || 0) + 1;
    await donor.save();

    res.json({
      success: true,
      message: 'Request accepted successfully',
      data: {
        request: bloodRequest,
        donation,
      },
    });
  } catch (err) {
    next(err);
  }
};

// Helper function to check blood type compatibility
function isCompatibleDonor(donorType, recipientType) {
  // Universal donors
  if (donorType === 'O-') return true;

  // Exact match
  if (donorType === recipientType) return true;

  // O+ can donate to any positive
  if (donorType === 'O+' && recipientType.endsWith('+')) return true;

  // A- can donate to A+ and A-, AB+ and AB-
  if (donorType === 'A-') {
    return recipientType.startsWith('A') || recipientType.startsWith('AB');
  }

  // A+ can donate to A+ and AB+
  if (donorType === 'A+' && recipientType === 'A+') return true;
  if (donorType === 'A+' && recipientType === 'AB+') return true;

  // B- can donate to B+ and B-, AB+ and AB-
  if (donorType === 'B-') {
    return recipientType.startsWith('B') || recipientType.startsWith('AB');
  }

  // B+ can donate to B+ and AB+
  if (donorType === 'B+' && recipientType === 'B+') return true;
  if (donorType === 'B+' && recipientType === 'AB+') return true;

  // AB- can donate to AB+ and AB-
  if (donorType === 'AB-' && recipientType.startsWith('AB')) return true;

  // AB+ can only donate to AB+
  if (donorType === 'AB+' && recipientType === 'AB+') return true;

  return false;
}

