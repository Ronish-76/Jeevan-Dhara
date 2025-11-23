import createError from 'http-errors';
import Location from '../models/location.model.js';
import Hospital from '../models/hospital.model.js';
import BloodBank from '../models/bloodBank.model.js';
import { nearbyQuerySchema } from '../utils/validators.js';

// Seed locations from JSON data
export const seedLocations = async (req, res, next) => {
  try {
    const fs = await import('fs');
    const path = await import('path');
    const { fileURLToPath } = await import('url');
    const __filename = fileURLToPath(import.meta.url);
    const __dirname = path.dirname(__filename);

    const dataPath = path.join(__dirname, '../seed/locations.json');
    const raw = fs.readFileSync(dataPath, 'utf-8');
    const locations = JSON.parse(raw);

    // Ensure geo field is set from coordinates
    const processedLocations = locations.map((loc) => {
      if (loc.coordinates && !loc.geo) {
        loc.geo = loc.coordinates;
      }
      // Ensure inventory exists if bloodTypesAvailable is provided
      if (loc.bloodTypesAvailable && !loc.inventory) {
        const inv = {};
        loc.bloodTypesAvailable.forEach((bt) => {
          inv[bt] = Math.floor(Math.random() * 50) + 10; // Random inventory 10-60 units
        });
        loc.inventory = inv;
      }
      return loc;
    });

    // Delete existing locations
    await Location.deleteMany({});

    const hospitals = processedLocations.filter((loc) => loc.type === 'hospital');
    const bloodBanks = processedLocations.filter((loc) => loc.type === 'blood_bank');
    const others = processedLocations.filter(
      (loc) => !['hospital', 'blood_bank'].includes(loc.type),
    );

    if (hospitals.length) {
      await Hospital.insertMany(hospitals);
    }
    if (bloodBanks.length) {
      await BloodBank.insertMany(bloodBanks);
    }
    if (others.length) {
      await Location.insertMany(others);
    }

    res.json({
      success: true,
      message: `Seeded ${processedLocations.length} locations`,
      count: processedLocations.length,
    });
  } catch (err) {
    next(err);
  }
};

// Get nearby locations (enhanced version)
export const getNearbyLocations = async (req, res, next) => {
  try {
    // Validate query parameters
    const { error, value } = nearbyQuerySchema.validate(req.query);
    if (error) {
      throw createError(400, error.details[0].message);
    }

    const { lat, lng, radius = 10, role, bloodType, availability, limit = 25 } = value;

    if (!lat || !lng) {
      throw createError(400, 'Latitude and longitude are required');
    }

    const latNum = parseFloat(lat);
    const lngNum = parseFloat(lng);
    const radiusNum = parseFloat(radius) * 1000; // Convert km to meters

    if (isNaN(latNum) || isNaN(lngNum) || latNum < -90 || latNum > 90 || lngNum < -180 || lngNum > 180) {
      throw createError(400, 'Invalid coordinates');
    }

    // Build query
    const query = {};

    // Role-based filtering
    if (role === 'patient' || role === 'donor') {
      query.type = { $in: ['hospital', 'blood_bank'] };
    } else if (role === 'hospital') {
      query.type = 'blood_bank';
    } else if (role === 'bloodBank' || role === 'blood_bank') {
      query.type = 'hospital';
    }

    // Blood type filter
    if (bloodType) {
      query.$or = [
        { [`inventory.${bloodType}`]: { $gt: 0 } },
        { bloodTypesAvailable: { $regex: new RegExp(`^${bloodType}$`, 'i') } },
      ];
    }

    // Availability filter
    if (availability) {
      query['availability.inventoryLevel'] = availability;
    }

    // Use $geoNear aggregation
    const pipeline = [
      {
        $geoNear: {
          near: { type: 'Point', coordinates: [lngNum, latNum] },
          distanceField: 'distance',
          maxDistance: radiusNum,
          spherical: true,
          distanceMultiplier: 0.001, // Convert to km
          query: query,
        },
      },
      {
        $project: {
          name: 1,
          type: 1,
          address: 1,
          contactNumber: 1,
          email: 1,
          bloodTypesAvailable: 1,
          services: 1,
          availability: 1,
          inventory: 1,
          distance: { $round: ['$distance', 2] },
          geo: {
            $cond: {
              if: { $ne: ['$geo', null] },
              then: '$geo',
              else: '$coordinates',
            },
          },
          coordinates: {
            $cond: {
              if: { $ne: ['$geo.coordinates', null] },
              then: '$geo.coordinates',
              else: '$coordinates.coordinates',
            },
          },
        },
      },
      { $sort: { distance: 1 } },
      { $limit: parseInt(limit, 10) },
    ];

    const locations = await Location.aggregate(pipeline);

    res.json({
      success: true,
      count: locations.length,
      data: locations,
    });
  } catch (err) {
    next(err);
  }
};

// Get blood bank inventory
export const getBloodBankInventory = async (req, res, next) => {
  try {
    const { id } = req.params;

    const location = await BloodBank.findById(id);

    if (!location) {
      throw createError(404, 'Blood bank not found');
    }

    res.json({
      success: true,
      data: {
        id: location._id,
        name: location.name,
        inventory: location.inventory || {},
        bloodTypesAvailable: location.bloodTypesAvailable || [],
        availability: location.availability || {},
        contactNumber: location.contactNumber,
        address: location.address,
      },
    });
  } catch (err) {
    next(err);
  }
};

