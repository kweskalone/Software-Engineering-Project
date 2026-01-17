import { getSupabaseClients } from '../config/supabaseClient.js';
import { parsePagination, buildPaginationMeta } from '../utils/pagination.js';

/**
 * Search for available beds across ALL hospitals.
 * This is the core feature that solves No Bed Syndrome.
 * 
 * Query params:
 * - region: Filter by hospital region
 * - district: Filter by hospital district
 * - ward_type: Filter by ward type (icu, maternity, general, etc.)
 * - min_beds: Minimum available beds (default: 1)
 * - page, limit: Pagination
 */
async function searchBeds(req, res, next) {
  try {
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;
    const { page, limit, offset } = parsePagination(req.query);
    const { region, district, ward_type, min_beds } = req.query;

    const minBeds = parseInt(min_beds, 10) || 1;

    // Build query for wards with available beds, joined with hospital info
    let query = db
      .from('wards')
      .select(`
        id,
        name,
        type,
        total_beds,
        available_beds,
        hospital_id,
        hospitals (
          id,
          name,
          region,
          district
        )
      `)
      .gte('available_beds', minBeds)
      .order('available_beds', { ascending: false });

    // We need to filter by hospital fields, so we'll filter after fetch
    // or use a more complex approach. For simplicity, fetch and filter.

    const { data: allWards, error } = await query;

    if (error) {
      error.statusCode = 500;
      error.publicMessage = 'Failed to search beds';
      throw error;
    }

    // Filter by region/district/ward_type
    let filtered = allWards || [];

    if (region) {
      filtered = filtered.filter(w => 
        w.hospitals?.region?.toLowerCase() === region.toLowerCase()
      );
    }

    if (district) {
      filtered = filtered.filter(w => 
        w.hospitals?.district?.toLowerCase() === district.toLowerCase()
      );
    }

    if (ward_type) {
      filtered = filtered.filter(w => 
        w.type?.toLowerCase() === ward_type.toLowerCase()
      );
    }

    // Calculate totals before pagination
    const totalCount = filtered.length;
    const totalAvailableBeds = filtered.reduce((sum, w) => sum + (w.available_beds || 0), 0);

    // Apply pagination
    const paginated = filtered.slice(offset, offset + limit);

    // Transform response for cleaner output
    const results = paginated.map(w => ({
      ward_id: w.id,
      ward_name: w.name,
      ward_type: w.type,
      total_beds: w.total_beds,
      available_beds: w.available_beds,
      hospital: {
        id: w.hospitals?.id,
        name: w.hospitals?.name,
        region: w.hospitals?.region,
        district: w.hospitals?.district
      }
    }));

    return res.status(200).json({
      results,
      summary: {
        total_wards_with_beds: totalCount,
        total_available_beds: totalAvailableBeds
      },
      filters: {
        region: region || null,
        district: district || null,
        ward_type: ward_type || null,
        min_beds: minBeds
      },
      pagination: buildPaginationMeta({ page, limit, totalCount })
    });
  } catch (err) {
    return next(err);
  }
}

export { searchBeds };
