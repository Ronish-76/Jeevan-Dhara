/**
 * Google Maps API utility functions
 * Requires GOOGLE_MAPS_API_KEY in environment variables
 */

/**
 * Geocode an address to coordinates
 * @param {string} address - Address to geocode
 * @returns {Promise<{lat: number, lng: number, formatted: string}>}
 */
export async function geocodeAddress(address) {
  const apiKey = process.env.GOOGLE_MAPS_API_KEY;

  if (!apiKey) {
    throw new Error('GOOGLE_MAPS_API_KEY not set in environment variables');
  }

  try {
    const encodedAddress = encodeURIComponent(address);
    const url = `https://maps.googleapis.com/maps/api/geocode/json?address=${encodedAddress}&key=${apiKey}`;

    const response = await fetch(url);
    const data = await response.json();

    if (data.status !== 'OK' || !data.results || data.results.length === 0) {
      throw new Error(`Geocoding failed: ${data.status}`);
    }

    const result = data.results[0];
    const location = result.geometry.location;

    return {
      lat: location.lat,
      lng: location.lng,
      formatted: result.formatted_address,
      placeId: result.place_id,
    };
  } catch (error) {
    console.error('Geocoding error:', error);
    throw error;
  }
}

/**
 * Get directions between two points
 * @param {number} originLat - Origin latitude
 * @param {number} originLng - Origin longitude
 * @param {number} destLat - Destination latitude
 * @param {number} destLng - Destination longitude
 * @param {string} mode - Travel mode: driving, walking, bicycling, transit
 * @returns {Promise<{distance: string, duration: string, polyline: string, steps: Array}>}
 */
export async function getDirections(originLat, originLng, destLat, destLng, mode = 'driving') {
  const apiKey = process.env.GOOGLE_MAPS_API_KEY;

  if (!apiKey) {
    throw new Error('GOOGLE_MAPS_API_KEY not set in environment variables');
  }

  try {
    const origin = `${originLat},${originLng}`;
    const destination = `${destLat},${destLng}`;
    const url = `https://maps.googleapis.com/maps/api/directions/json?origin=${origin}&destination=${destination}&mode=${mode}&key=${apiKey}`;

    const response = await fetch(url);
    const data = await response.json();

    if (data.status !== 'OK' || !data.routes || data.routes.length === 0) {
      throw new Error(`Directions failed: ${data.status}`);
    }

    const route = data.routes[0];
    const leg = route.legs[0];

    return {
      distance: leg.distance.text,
      distanceMeters: leg.distance.value,
      duration: leg.duration.text,
      durationSeconds: leg.duration.value,
      polyline: route.overview_polyline.points,
      steps: leg.steps.map((step) => ({
        instruction: step.html_instructions.replace(/<[^>]*>/g, ''),
        distance: step.distance.text,
        duration: step.duration.text,
        polyline: step.polyline.points,
      })),
    };
  } catch (error) {
    console.error('Directions error:', error);
    throw error;
  }
}

/**
 * Reverse geocode coordinates to address
 * @param {number} lat - Latitude
 * @param {number} lng - Longitude
 * @returns {Promise<{address: string, components: Object}>}
 */
export async function reverseGeocode(lat, lng) {
  const apiKey = process.env.GOOGLE_MAPS_API_KEY;

  if (!apiKey) {
    throw new Error('GOOGLE_MAPS_API_KEY not set in environment variables');
  }

  try {
    const url = `https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lng}&key=${apiKey}`;

    const response = await fetch(url);
    const data = await response.json();

    if (data.status !== 'OK' || !data.results || data.results.length === 0) {
      throw new Error(`Reverse geocoding failed: ${data.status}`);
    }

    const result = data.results[0];

    return {
      address: result.formatted_address,
      placeId: result.place_id,
      components: result.address_components.reduce((acc, comp) => {
        acc[comp.types[0]] = comp.long_name;
        return acc;
      }, {}),
    };
  } catch (error) {
    console.error('Reverse geocoding error:', error);
    throw error;
  }
}

