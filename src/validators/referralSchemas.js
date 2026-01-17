import { z } from 'zod';

const createReferralSchema = z.object({
  patient_id: z.string().uuid(),
  from_ward_id: z.string().uuid(),
  to_hospital_id: z.string().uuid(),
  reason: z.string().min(3).optional()
});

// Schema for completing a referral (admitting the patient)
const completeReferralSchema = z.object({
  ward_id: z.string().uuid({ message: 'Ward ID is required to admit patient' }),
  bed_number: z.string().min(1, 'Bed number is required').optional(),
  notes: z.string().optional()
});

export { createReferralSchema, completeReferralSchema };
