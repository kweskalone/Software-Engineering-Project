import { z } from 'zod';

const createUserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  role: z.enum(['admin', 'doctor', 'nurse']),
  hospital_id: z.string().uuid(),
  staff_id: z.string().min(2)
});

export { createUserSchema };
