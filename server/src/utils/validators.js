import Joi from 'joi';

export const nearbyQuerySchema = Joi.object({
  lat: Joi.number().min(-90).max(90).required(),
  lng: Joi.number().min(-180).max(180).required(),
  radius: Joi.number().min(0.5).max(50).default(5),
  role: Joi.string().valid('patient', 'donor', 'hospital', 'blood_bank').optional(),
  bloodType: Joi.string().optional(),
  availability: Joi.string().optional(),
  limit: Joi.number().integer().min(1).max(100).default(25),
}).required();

export const createRequestSchema = Joi.object({
  requesterRole: Joi.string()
    .valid('patient', 'donor', 'hospital', 'blood_bank')
    .required(),
  requesterName: Joi.string().min(2).max(120).required(),
  requesterContact: Joi.string().min(5).max(40).required(),
  bloodGroup: Joi.string()
    .regex(/^(A|B|AB|O)[+-]$/i)
    .required(),
  units: Joi.number().integer().min(1).max(10).required(),
  lat: Joi.number().min(-90).max(90).required(),
  lng: Joi.number().min(-180).max(180).required(),
  notes: Joi.string().allow('', null).max(500),
}).required();

export const respondRequestSchema = Joi.object({
  requestId: Joi.string().required(),
  responderRole: Joi.string()
    .valid('patient', 'donor', 'hospital', 'blood_bank')
    .required(),
  responderName: Joi.string().min(2).max(120).required(),
  responderContact: Joi.string().min(5).max(40).optional(),
  notes: Joi.string().allow('', null).max(500),
}).required();

export const supplyRoutesQuerySchema = Joi.object({
  facilityId: Joi.string(),
  fromId: Joi.string(),
  toId: Joi.string(),
  facilityType: Joi.string().valid('hospital', 'blood_bank'),
  destinationId: Joi.string(),
  status: Joi.string().valid('pending', 'accepted', 'responded', 'completed').default('pending'),
  optimize: Joi.boolean().default(false),
})
  .or('facilityId', 'fromId')
  .with('fromId', 'facilityType');
