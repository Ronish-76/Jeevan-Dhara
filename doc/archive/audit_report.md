# Phase A Audit Report

## Summary
- Backend implemented under server/ with Express + Mongoose; legacy duplicate map stack exists (map.controller vs location.controller).
- Flutter app contains both legacy and newly added map screens, causing inconsistent architecture and lint errors (193 issues from lutter analyze).
- Environment handling is incomplete (.env.example missing required keys beyond MONGO_URI/PORT).
- Dataset/seed scripts exist but are not canonical (no scripts/seedLocations.js, no 20+20 dataset outside server/src/seed).

## Findings

### Critical
1. **Flutter analyzer errors** (lutter analyze returned 193 issues, including undefined classes and null-safety violations). This blocks builds.
2. **Duplicate nearby endpoints** (/api/map/nearby vs /api/locations/nearby) returning different payload shapes; clients can desynchronize.
3. **Legacy/broken widgets** (lib/widgets/map/custom_marker_icon.dart missing dart:ui import -> PictureRecorder undefined) breaks new map screens at runtime.

### High
1. **Naming mismatch** (lood_bank vs loodBank) requires conversion hacks in Flutter models; risk of future regressions.
2. **Map controllers duplicated** (patient_map_screen vs patient_request_map_screen) with diverging logic.
3. **No lint/test scripts** in backend; 
pm run lint fails (script missing) preventing automated QA.
4. **Environment coverage incomplete** (only MONGO_URI, PORT, GOOGLE_MAPS_API_KEY, NODE_ENV currently referenced; Directions key, seeding key missing).

### Medium
1. **Overlapping seed/route logic** (server/src/controllers/location.controller.js seeds and queries; map.controller.js duplicates logic but lacks polygon filtering).
2. **Missing automation** for geo indexes (scripts/createIndexes.js absent).
3. **Flutter services** still reference old endpoints (e.g., map_service.dart still expects /map/nearby semantics in some code paths).
4. **Outdated Flutter APIs** (mass use of deprecated withOpacity, ctiveColor, describeEnum).

### Low
1. **Unused files/imports** flagged (legacy map_screen, unused _selected* fields in new screens).
2. **Console prints** left in production widgets (print in map screens).
3. **No Postman/OpenAPI spec**; manual testing only.

## Runtime Checks
- 
pm run lint: ❌ fails (script not defined).
- lutter analyze: ❌ fails with 193 issues (see console log in Phase A output).
- Jest/unit tests: none configured.

## Canonical Folder Structure (Proposed)
`
server/
  src/
    config/
    models/
    controllers/
    services/
    routes/
    middlewares/
    utils/
    tests/
  scripts/
    seedLocations.js
    createIndexes.js
lib/
  models/
  services/
  providers/
  screens/
    map/
      patient/
      donor/
      blood_bank/
      hospital/
  widgets/
    map/
  utils/
  tests/
`

## Required Fixes Before Phase B
1. Remove/merge duplicate Express routes + controllers; keep single /locations/nearby pipeline.
2. Create canonical Mongo schemas (Hospital, BloodBank, User, BloodRequest, Donation) with shared geo subdocument + indexes.
3. Provide new dataset + seeding scripts under data/ + scripts/.
4. Introduce lint/test scripts (
pm run lint, 
pm run test) and fix Flutter analyzer errors.
5. Finish Flutter map refactor: remove legacy screens, wire new role-specific screens with consistent services/widgets.
6. Expand .env.example with all required keys (MONGODB_URI, GOOGLE_MAPS_API_KEY, GOOGLE_DIRECTIONS_KEY, PORT, SEEDING_KEY).

---
Generated on 2025-11-19 16:25:48
