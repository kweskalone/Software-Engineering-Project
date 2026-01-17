import { z } from 'zod';

const totalBedsSchema = z.preprocess((val) => {
  if (typeof val === 'string' && val.trim() !== '') return Number(val);
  return val;
}, z.number().int().min(0));

const createWardSchema = z.object({
  name: z.string().min(2),
  type: z.string().min(2),
  total_beds: totalBedsSchema,
  hospital_id: z.string().uuid().optional()
});

const updateWardCapacitySchema = z.object({
  total_beds: totalBedsSchema
});

export { createWardSchema, updateWardCapacitySchema };
