import { getSupabaseClients } from '../config/supabaseClient.js';

async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'email and password are required' });
    }

    const { supabaseAnon, supabaseService } = getSupabaseClients();

    const { data, error } = await supabaseAnon.auth.signInWithPassword({ email, password });
    if (error) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Fetch user profile (role, staff_id, hospital) from users table
    const db = supabaseService || supabaseAnon;
    const { data: profile } = await db
      .from('users')
      .select('first_name, last_name, role, staff_id, hospital_id, hospitals(name)')
      .eq('auth_user_id', data.user.id)
      .maybeSingle();

    return res.status(200).json({
      access_token: data.session?.access_token,
      refresh_token: data.session?.refresh_token,
      token_type: data.session?.token_type,
      expires_in: data.session?.expires_in,
      user: {
        ...data.user,
        profile: profile || null
      }
    });
  } catch (err) {
    return next(err);
  }
}

/**
 * Refresh access token using a refresh token.
 * Allows clients to get a new access token without re-entering credentials.
 */
async function refreshToken(req, res, next) {
  try {
    const { refresh_token } = req.body;
    if (!refresh_token) {
      return res.status(400).json({ error: 'refresh_token is required' });
    }

    const { supabaseAnon } = getSupabaseClients();

    const { data, error } = await supabaseAnon.auth.refreshSession({ refresh_token });
    if (error) {
      return res.status(401).json({ error: 'Invalid or expired refresh token' });
    }

    return res.status(200).json({
      access_token: data.session?.access_token,
      refresh_token: data.session?.refresh_token,
      token_type: data.session?.token_type,
      expires_in: data.session?.expires_in,
      user: data.user
    });
  } catch (err) {
    return next(err);
  }
}

/**
 * Logout - invalidates the current session.
 * Requires the user to be authenticated.
 */
async function logout(req, res, next) {
  try {
    const { supabaseAnon } = getSupabaseClients();

    // Use the token from the auth middleware to sign out
    const { error } = await supabaseAnon.auth.signOut();
    if (error) {
      // Log but don't fail - client should still clear local tokens
      console.warn('Logout warning:', error.message);
    }

    return res.status(200).json({ message: 'Logged out successfully' });
  } catch (err) {
    return next(err);
  }
}

/**
 * Request password reset - sends a reset email to the user.
 * No authentication required.
 */
async function forgotPassword(req, res, next) {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ error: 'email is required' });
    }

    const { supabaseAnon } = getSupabaseClients();

    // The redirect URL should point to your frontend's password reset page
    const redirectTo = process.env.PASSWORD_RESET_REDIRECT_URL || 'http://localhost:3000/reset-password';

    const { error } = await supabaseAnon.auth.resetPasswordForEmail(email, {
      redirectTo
    });

    if (error) {
      // Don't reveal if email exists or not (security best practice)
      console.warn('Password reset request error:', error.message);
    }

    // Always return success to prevent email enumeration attacks
    return res.status(200).json({
      message: 'If an account with that email exists, a password reset link has been sent'
    });
  } catch (err) {
    return next(err);
  }
}

/**
 * Reset password - sets a new password using the token from the reset email.
 * The user will have a valid session after clicking the reset link.
 */
async function resetPassword(req, res, next) {
  try {
    const { new_password } = req.body;
    if (!new_password) {
      return res.status(400).json({ error: 'new_password is required' });
    }

    if (new_password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    const { supabaseAnon } = getSupabaseClients();

    const { error } = await supabaseAnon.auth.updateUser({
      password: new_password
    });

    if (error) {
      return res.status(400).json({ error: 'Failed to reset password. Link may have expired.' });
    }

    return res.status(200).json({ message: 'Password reset successfully' });
  } catch (err) {
    return next(err);
  }
}

export { login, refreshToken, logout, forgotPassword, resetPassword };
