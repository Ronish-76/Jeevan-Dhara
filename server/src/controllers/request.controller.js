import createError from 'http-errors';
import BloodRequest from '../models/bloodRequest.model.js';
import { createRequestSchema, respondRequestSchema } from '../utils/validators.js';
import { emitRequestCreated, emitRequestResponded } from '../services/socket.service.js';

const ACTIVE_STATUSES = ['pending', 'responded'];

const serializeRequest = (request) => ({
  id: request._id.toString(),
  requesterRole: request.requesterRole,
  bloodGroup: request.bloodGroup,
  units: request.units,
  lat: request.lat,
  lng: request.lng,
  notes: request.notes,
  status: request.status,
  requesterName: request.requesterName,
  requesterContact: request.requesterContact,
  responderRole: request.responderRole,
  responderName: request.responderName,
  responderContact: request.responderContact,
  responseNote: request.responseNote,
  respondedAt: request.respondedAt,
  timestamp: request.createdAt,
});

export const getActiveRequests = async (req, res, next) => {
  try {
    const requests = await BloodRequest.find({ status: { $in: ACTIVE_STATUSES } }).sort({ createdAt: -1 });

    res.json({
      success: true,
      count: requests.length,
      data: requests.map(serializeRequest),
    });
  } catch (error) {
    next(error);
  }
};

export const createRequest = async (req, res, next) => {
  try {
    const payload = await createRequestSchema.validateAsync(req.body, { abortEarly: false });

    const request = await BloodRequest.create({
      ...payload,
      bloodGroup: payload.bloodGroup.toUpperCase(),
      units: payload.units,
    });

    const responsePayload = serializeRequest(request);
    emitRequestCreated(responsePayload);

    res.status(201).json({
      success: true,
      message: 'Blood request created',
      data: responsePayload,
    });
  } catch (error) {
    if (error.isJoi) {
      next(createError(400, error.details[0].message));
    } else {
      next(error);
    }
  }
};

export const respondToRequest = async (req, res, next) => {
  try {
    const payload = await respondRequestSchema.validateAsync(req.body, { abortEarly: false });

    const request = await BloodRequest.findById(payload.requestId);
    if (!request) {
      throw createError(404, 'Blood request not found');
    }

    if (request.status !== 'pending') {
      throw createError(400, `Cannot respond to a ${request.status} request`);
    }

    request.status = 'responded';
    request.responderRole = payload.responderRole;
    request.responderName = payload.responderName;
    request.responderContact = payload.responderContact;
    request.responseNote = payload.notes;
    request.respondedAt = new Date();

    await request.save();

    const responsePayload = serializeRequest(request);
    emitRequestResponded(responsePayload);

    res.json({
      success: true,
      message: 'Response recorded',
      data: responsePayload,
    });
  } catch (error) {
    if (error.isJoi) {
      next(createError(400, error.details[0].message));
    } else {
      next(error);
    }
  }
};
