import test from 'node:test';
import assert from 'node:assert/strict';

import { createAdmissionSchema } from '../src/validators/admissionSchemas.js';
import { createUserSchema } from '../src/validators/userSchemas.js';

// Basic validation sanity checks (no DB)

test('createAdmissionSchema rejects missing fields', () => {
  const result = createAdmissionSchema.safeParse({});
  assert.equal(result.success, false);
});

test('createAdmissionSchema accepts valid payload', () => {
  const result = createAdmissionSchema.safeParse({
    ward_id: '00000000-0000-0000-0000-000000000000',
    patient: {
      full_name: 'Ama Mensah',
      sex: 'F'
    }
  });
  assert.equal(result.success, true);
});

test('createUserSchema rejects invalid role', () => {
  const result = createUserSchema.safeParse({
    email: 'test@example.com',
    password: 'secret123',
    role: 'clerk',
    hospital_id: '00000000-0000-0000-0000-000000000000',
    staff_id: 'KBTH-001'
  });
  assert.equal(result.success, false);
});
