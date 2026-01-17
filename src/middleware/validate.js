function validate(schema, property = 'body') {
  return (req, res, next) => {
    const result = schema.safeParse(req[property]);
    if (!result.success) {
      const err = new Error('Validation failed');
      err.statusCode = 400;
      err.publicMessage = 'Validation error';
      err.details = result.error.flatten();
      return next(err);
    }

    req[property] = result.data;
    return next();
  };
}

export { validate };
