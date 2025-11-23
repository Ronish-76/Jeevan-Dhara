
const Location = require('../models/location.model');

exports.getNearbyLocations = async (req, res) => {
  const { latitude, longitude, role, radiusKm, bloodType, availability } = req.query;

  if (!latitude || !longitude || !role) {
    return res.status(400).json({ message: 'Latitude, longitude, and role are required.' });
  }

  const maxDistance = (radiusKm || 10) * 1000; // Convert km to meters

  let query = {
    location: {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: [parseFloat(longitude), parseFloat(latitude)],
        },
        $maxDistance: maxDistance,
      },
    },
  };

  // Role-based filtering
  switch (role) {
    case 'patient':
      query.type = { $in: ['hospital', 'bloodBank'] };
      break;
    case 'donor':
      query.type = { $in: ['hospital', 'bloodBank'] }; // Donors see places to donate
      break;
    case 'hospital':
      query.type = 'bloodBank'; // Hospitals see blood banks
      break;
    case 'bloodBank':
      query.type = 'hospital'; // Blood banks see hospitals
      break;
  }

  // Optional filtering
  if (bloodType) {
    query[`bloodInventory.${bloodType}`] = { $exists: true, $gt: 0 };
  }
  if (availability) {
    query.isAvailable = availability === 'true';
  }

  try {
    const locations = await Location.find(query);
    res.json(locations);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching locations', error: error.message });
  }
};
