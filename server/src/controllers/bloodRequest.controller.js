import createError from 'http-errors';
import BloodRequest from '../models/bloodRequest.model.js';
import Location from '../models/location.model.js';
import { createRequestSchema } from '../utils/validators.js';

// Create blood request from map
export const createRequestFromMap = async (req, res, next) => {
  try {
    // Validate request body
    const { error, value } = createRequestSchema.validate(req.body);
    if (error) {
      throw createError(400, error.details[0].message);
    }

    const {
      requesterId,
      requesterName,
      requesterPhone,
      bloodGroup,
      quantity,
      urgency = 'medium',
      locationId,
      latitude,
      longitude,
      address,
      reason,
      notes,
    } = value;

    // Build geo location if coordinates provided
    let geo = null;
    if (latitude && longitude) {
      geo = {
        type: 'Point',
        coordinates: [parseFloat(longitude), parseFloat(latitude)],
      };
    }

    // Get location details if locationId provided
    let locationName = null;
    let facilityId = null;
    let facilityName = null;

    if (locationId) {
      const location = await Location.findById(locationId);
      if (location) {
        locationName = location.name;
        facilityId = location._id;
        facilityName = location.name;
      }
    }

    // Create request
    const bloodRequest = new BloodRequest({
      requesterId,
      requesterName,
      requesterPhone,
      bloodGroup: bloodGroup.toUpperCase(),
      quantity: parseInt(quantity, 10),
      urgency,
      locationId,
      locationName,
      facilityId,
      facilityName,
      geo,
      address: address || {},
      reason,
      notes,
      status: 'pending',
    });

    await bloodRequest.save();

    res.status(201).json({
      success: true,
      message: 'Blood request created successfully',
      data: bloodRequest,
    });
  } catch (err) {
    next(err);
  }
};

// Get all blood requests (with filters)
export const getBloodRequests = async (req, res, next) => {
  try {
    const {
      status,
      bloodGroup,
      urgency,
      requesterId,
      facilityId,
      limit = 50,
      skip = 0,
    } = req.query;

    const query = {};

    if (status) query.status = status;
    if (bloodGroup) query.bloodGroup = bloodGroup.toUpperCase();
    if (urgency) query.urgency = urgency;
    if (requesterId) query.requesterId = requesterId;
    if (facilityId) query.facilityId = facilityId;

    const requests = await BloodRequest.find(query)
      .sort({ urgency: -1, createdAt: -1 })
      .limit(parseInt(limit, 10))
      .skip(parseInt(skip, 10))
      .populate('requesterId', 'name email phone')
      .populate('locationId', 'name address coordinates')
      .populate('acceptedBy', 'name phone bloodType');

    const total = await BloodRequest.countDocuments(query);

    res.json({
      success: true,
      count: requests.length,
      total,
      data: requests,
    });
  } catch (err) {
    next(err);
  }
};

// Get urgent requests for donors
export const getUrgentRequests = async (req, res, next) => {
  try {
    const { lat, lng, radius = 20, bloodGroup } = req.query;

    const query = {
      status: 'pending',
      urgency: { $in: ['high', 'critical'] },
    };

    if (bloodGroup) {
      query.bloodGroup = bloodGroup.toUpperCase();
    }

    let requests = await BloodRequest.find(query)
      .sort({ urgency: -1, createdAt: -1 })
      .limit(20)
      .populate('locationId', 'name address coordinates');

    // If coordinates provided, calculate distances and filter
    if (lat && lng) {
      const latNum = parseFloat(lat);
      const lngNum = parseFloat(lng);
      const radiusNum = parseFloat(radius);

      requests = requests
        .map((req) => {
          if (req.geo && req.geo.coordinates) {
            const [lng2, lat2] = req.geo.coordinates;
            const distance = calculateDistance(latNum, lngNum, lat2, lng2);
            return { ...req.toObject(), distance };
          }
          return req.toObject();
        })
        .filter((req) => !req.distance || req.distance <= radiusNum)
        .sort((a, b) => (a.distance || 999) - (b.distance || 999));
    }

    res.json({
      success: true,
      count: requests.length,
      data: requests,
    });
  } catch (err) {
    next(err);
  }
};

// Helper function to calculate distance between two points (Haversine formula)
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in km
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
    Math.cos((lat2 * Math.PI) / 180) *
    Math.sin(dLon / 2) *
    Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

