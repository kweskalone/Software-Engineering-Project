import { createUserWithProfile } from '../services/userService.js';

async function createUser(req, res, next) {
  try {
    const { email, password, role, hospital_id, staff_id } = req.body;

    const result = await createUserWithProfile({
      actor: req.auth,
      email,
      password,
      role,
      hospitalId: hospital_id,
      staffId: staff_id
    });

    return res.status(201).json(result);
  } catch (err) {
    return next(err);
  }
}

export { createUser };
