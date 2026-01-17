import { z } from 'zod';

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6)
});

const refreshTokenSchema = z.object({
  refresh_token: z.string().min(1, 'refresh_token is required')
});

const forgotPasswordSchema = z.object({
  email: z.string().email()
});

const resetPasswordSchema = z.object({
  new_password: z.string().min(6, 'Password must be at least 6 characters')
});

export { loginSchema, refreshTokenSchema, forgotPasswordSchema, resetPasswordSchema };
