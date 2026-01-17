import { z } from 'zod';

const dischargeSchema = z.object({
  admission_id: z.string().uuid()
});

export { dischargeSchema };
