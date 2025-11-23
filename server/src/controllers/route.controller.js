import createError from 'http-errors';
import Location from '../models/location.model.js';
import BloodRequest from '../models/bloodRequest.model.js';
import { getDirections } from '../utils/googleMaps.js';
import { supplyRoutesQuerySchema } from '../utils/validators.js';

// Get supply routes for hospitals/blood banks
export const getSupplyRoutes = async (req, res, next) => {
  try {
    // Validate query parameters
    const { error, value } = supplyRoutesQuerySchema.validate(req.query);
    if (error) {
      throw createError(400, error.details[0].message);
    }

    const {
      facilityId,
      fromId,
      toId,
      facilityType,
      destinationId,
      status = 'pending',
      optimize = false,
    } = value;

    // Support both new (fromId/toId) and legacy (facilityId/destinationId) parameters
    const originId = fromId || facilityId;
    const targetId = toId || destinationId;

    // Get facility location
    const facility = await Location.findById(originId);

    if (!facility) {
      throw createError(404, 'Facility not found');
    }

    // Build routes based on facility type
    const routes = [];

    if (facilityType === 'hospital' || facility.type === 'hospital') {
      // Hospital views: pending requests that need fulfillment
      const requests = await BloodRequest.find({
        facilityId,
        status: { $in: [status, 'accepted'] },
      })
        .populate('requesterId', 'name phone geo address')
        .populate('acceptedBy', 'name phone geo')
        .sort({ urgency: -1, createdAt: -1 });

      routes.push(
        ...requests.map((req) => ({
          id: req._id,
          type: 'request_fulfillment',
          origin: {
            id: facility._id,
            name: facility.name,
            coordinates: facility.geo?.coordinates || facility.coordinates?.coordinates,
            address: facility.address,
          },
          destination: {
            id: req.locationId || req.requesterId?._id,
            name: req.locationName || req.requesterName,
            coordinates: req.geo?.coordinates || req.requesterId?.geo?.coordinates,
            address: req.address || req.requesterId?.address,
          },
          donor: req.acceptedBy
            ? {
                id: req.acceptedBy._id,
                name: req.acceptedBy.name,
                coordinates: req.acceptedBy.geo?.coordinates,
              }
            : null,
          bloodType: req.bloodType,
          quantity: req.quantity,
          urgency: req.urgency,
          status: req.status,
          createdAt: req.createdAt,
        })),
      );
    } else if (facilityType === 'blood_bank' || facility.type === 'blood_bank') {
      // Blood bank views: routes to hospitals needing inventory
      const requests = await BloodRequest.find({
        status: 'pending',
        bloodType: { $exists: true },
      })
        .populate('locationId', 'name address coordinates geo')
        .populate('facilityId', 'name address coordinates geo')
        .sort({ urgency: -1, createdAt: -1 })
        .limit(20);

      // Also get hospitals that might need supply
      const hospitals = await Location.find({
        type: 'hospital',
        'availability.inventoryLevel': { $in: ['low', 'medium'] },
      }).limit(10);

      // Combine requests and hospitals
      const destinations = [];

      requests.forEach((req) => {
        if (req.locationId) {
          destinations.push({
            id: req.locationId._id,
            name: req.locationId.name,
            coordinates: req.locationId.geo?.coordinates || req.locationId.coordinates?.coordinates,
            address: req.locationId.address,
            bloodType: req.bloodType,
            quantity: req.quantity,
            urgency: req.urgency,
            type: 'urgent_request',
          });
        }
      });

      hospitals.forEach((hospital) => {
        destinations.push({
          id: hospital._id,
          name: hospital.name,
          coordinates: hospital.geo?.coordinates || hospital.coordinates?.coordinates,
          address: hospital.address,
          bloodType: null,
          quantity: null,
          urgency: 'medium',
          type: 'supply_needed',
        });
      });

      routes.push(
        ...destinations.map((dest) => ({
          id: `${facility._id}_${dest.id}`,
          type: 'supply_delivery',
          origin: {
            id: facility._id,
            name: facility.name,
            coordinates: facility.geo?.coordinates || facility.coordinates?.coordinates,
            address: facility.address,
          },
          destination: dest,
          estimatedDistance: dest.coordinates
            ? calculateDistance(
                facility.geo?.coordinates?.[1] || facility.coordinates?.coordinates?.[1],
                facility.geo?.coordinates?.[0] || facility.coordinates?.coordinates?.[0],
                dest.coordinates[1],
                dest.coordinates[0],
              )
            : null,
          createdAt: new Date(),
        })),
      );
    }

    // Filter by destination if provided
    let filteredRoutes = routes;
    if (targetId) {
      filteredRoutes = routes.filter((r) => r.destination.id.toString() === targetId);
    }

    // Sort by urgency and distance
    filteredRoutes.sort((a, b) => {
      const urgencyOrder = { critical: 0, high: 1, medium: 2, low: 3 };
      const urgencyDiff = (urgencyOrder[a.urgency] || 3) - (urgencyOrder[b.urgency] || 3);
      if (urgencyDiff !== 0) return urgencyDiff;
      return (a.estimatedDistance || 999) - (b.estimatedDistance || 999);
    });

    // If optimize=true and we have fromId/toId, fetch Google Directions
    if (optimize && targetId && originId) {
      const routeToOptimize = filteredRoutes.find((r) => r.destination.id.toString() === targetId);
      if (routeToOptimize && routeToOptimize.origin.coordinates && routeToOptimize.destination.coordinates) {
        try {
          const [originLng, originLat] = routeToOptimize.origin.coordinates;
          const [destLng, destLat] = routeToOptimize.destination.coordinates;

          const directions = await getDirections(originLat, originLng, destLat, destLng, 'driving');

          routeToOptimize.directions = {
            polyline: directions.polyline,
            distance: directions.distance,
            distanceMeters: directions.distanceMeters,
            duration: directions.duration,
            durationSeconds: directions.durationSeconds,
            steps: directions.steps,
          };
        } catch (error) {
          console.error('Failed to fetch directions:', error);
          // Continue without directions - fallback to straight-line distance
        }
      }
    }

    res.json({
      success: true,
      count: filteredRoutes.length,
      data: filteredRoutes,
    });
  } catch (err) {
    next(err);
  }
};

// Helper function to calculate distance (Haversine formula)
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
  return Math.round(R * c * 100) / 100; // Round to 2 decimal places
}

