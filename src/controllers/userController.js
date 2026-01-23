import { createUserWithProfile, listUsers, getUserById, updateUser, deleteUser } from '../services/userService.js';

/**
 * List all users (admin only)
 */
async function getUsers(req, res, next) {
  try {
    const { page = 1, limit = 20, role, hospital_id } = req.query;

    const result = await listUsers({
      actor: req.auth,
      page: parseInt(page, 10),
      limit: parseInt(limit, 10),
      role,
      hospitalId: hospital_id,
    });

    return res.status(200).json(result);
  } catch (err) {
    return next(err);
  }
}

/**
 * Get a single user by ID (admin only)
 */
async function getUser(req, res, next) {
  try {
    const { id } = req.params;

    const user = await getUserById({
      actor: req.auth,
      userId: id,
    });

    return res.status(200).json(user);
  } catch (err) {
    return next(err);
  }
}

/**
 * Create a new user (admin only)
 */
async function createUser(req, res, next) {
  try {
    const { email, password, role, hospital_id, staff_id, first_name, last_name } = req.body;

    const result = await createUserWithProfile({
      actor: req.auth,
      email,
      password,
      role,
      hospitalId: hospital_id,
      staffId: staff_id,
      firstName: first_name,
      lastName: last_name,
    });

    return res.status(201).json(result);
  } catch (err) {
    return next(err);
  }
}

/**
 * Update a user (admin only)
 */
async function patchUser(req, res, next) {
  try {
    const { id } = req.params;
    const updates = req.body;

    const result = await updateUser({
      actor: req.auth,
      userId: id,
      updates,
    });

    return res.status(200).json(result);
  } catch (err) {
    return next(err);
  }
}

/**
 * Delete a user (admin only)
 */
async function removeUser(req, res, next) {
  try {
    const { id } = req.params;

    const result = await deleteUser({
      actor: req.auth,
      userId: id,
    });

    return res.status(200).json(result);
  } catch (err) {
    return next(err);
  }
}

export { createUser, getUsers, getUser, patchUser, removeUser };
