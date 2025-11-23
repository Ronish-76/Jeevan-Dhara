# Jeevan Dhara Backend

Express + MongoDB service powering the map module for Jeevan Dhara.

## Setup

1. Install dependencies  
   `npm install`

2. Copy env template  
   `cp env.example .env` (set `MONGO_URI`)

3. Seed Kathmandu Valley locations  
   `npm run seed:locations`

4. Start API  
   `npm run dev`

## API

- `GET /api/map/nearby`
  - Query params: `lat`, `lng`, `role`, optional `radius` (km), `bloodType`, `availability`, `limit`
  - Returns geospatially sorted hospitals/blood banks with distance (km)

