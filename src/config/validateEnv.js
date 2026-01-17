/**
 * Validates required environment variables at startup.
 * Fails fast with a clear message if any required variables are missing.
 */
function validateEnv() {
  const required = [
    'SUPABASE_URL',
    'SUPABASE_ANON_KEY'
  ];

  const optional = [
    'SUPABASE_SERVICE_ROLE_KEY',
    'PORT',
    'CORS_ORIGIN',
    'SENTRY_DSN'
  ];

  const missing = required.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    console.error('❌ Missing required environment variables:');
    missing.forEach((key) => console.error(`   - ${key}`));
    console.error('\nPlease set these in your .env file or environment.');
    process.exit(1);
  }

  // Warn about optional but recommended variables
  const missingOptional = optional.filter((key) => !process.env[key]);
  if (missingOptional.length > 0) {
    console.warn('⚠️  Optional environment variables not set (using defaults):');
    missingOptional.forEach((key) => {
      const defaults = {
        PORT: '3000',
        CORS_ORIGIN: '*',
        SUPABASE_SERVICE_ROLE_KEY: '(not set - using anon key only)',
        SENTRY_DSN: '(not set - error tracking disabled)'
      };
      console.warn(`   - ${key}: ${defaults[key] || 'not set'}`);
    });
  }

  console.log('✅ Environment validation passed');
}

export { validateEnv };
