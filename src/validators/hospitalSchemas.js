import { z } from 'zod';

const createHospitalSchema = z.object({
  name: z.string().min(2),
  region: z.string().min(2).optional(),
  district: z.string().min(2).optional()
});

const updateHospitalSchema = z.object({
  name: z.string().min(2).optional(),
  region: z.string().min(2).optional(),
  district: z.string().min(2).optional()
}).refine((data) => Object.keys(data).length > 0, {
  message: 'At least one field is required'
});

export { createHospitalSchema, updateHospitalSchema };
