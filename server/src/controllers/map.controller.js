import createError from 'http-errors';
import Facility from '../models/facility.model.js';
import { nearbyQuerySchema } from '../utils/validators.js';

export const getNearbyFacilities = async (req, res, next) => {
  try {
    const { lat, lng, radius } = await nearbyQuerySchema.validateAsync(req.query, { abortEarly: false });
    const meters = radius * 1000;

    const facilities = await Facility.aggregate([
      {
        $geoNear: {
          near: { type: 'Point', coordinates: [lng, lat] },
          distanceField: 'distance',
          maxDistance: meters,
          spherical: true,
          query: { type: { $in: ['hospital', 'blood_bank'] } },
        },
      },
      {
        $project: {
          _id: 1,
          name: 1,
          type: 1,
          lat: 1,
          lng: 1,
          address: 1,
          contact: 1,
          services: 1,
          distance: { $round: ['$distance', 2] },
        },
      },
      { $sort: { distance: 1 } },
    ]);

    res.json({
      success: true,
      count: facilities.length,
      data: facilities,
    });
  } catch (error) {
    if (error.isJoi) {
      next(createError(400, error.details[0].message));
    } else {
      next(error);
    }
  }
};
