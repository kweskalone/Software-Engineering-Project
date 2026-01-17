import { z } from 'zod';

const patientSchema = z.object({
  full_name: z.string().min(2),
  sex: z.enum(['M', 'F', 'Other']),
  date_of_birth: z.string().optional(),
  phone: z.string().optional(),
  national_id: z.string().optional()
});

const createAdmissionSchema = z.object({
  ward_id: z.string().uuid(),
  patient: patientSchema
});

export { createAdmissionSchema };
