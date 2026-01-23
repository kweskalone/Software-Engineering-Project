// Pagination helper utilities

const DEFAULT_PAGE = 1;
const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 100;

// Parse pagination parameters from request query
function parsePagination(query) {
  let page = parseInt(query.page, 10) || DEFAULT_PAGE;
  let limit = parseInt(query.limit, 10) || DEFAULT_LIMIT;

  // Enforce bounds
  if (page < 1) page = 1;
  if (limit < 1) limit = 1;
  if (limit > MAX_LIMIT) limit = MAX_LIMIT;

  const offset = (page - 1) * limit;

  return { page, limit, offset };
}

// Build pagination metadata for response
function buildPaginationMeta({ page, limit, totalCount }) {
  const totalPages = Math.ceil(totalCount / limit);
  
  return {
    page,
    limit,
    total_count: totalCount,
    total_pages: totalPages,
    has_next: page < totalPages,
    has_prev: page > 1
  };
}

export { parsePagination, buildPaginationMeta, DEFAULT_LIMIT, MAX_LIMIT };
