import { supabase } from '../config/supabaseClient.js';
import { AppError } from '../middleware/errorHandlers.js';

/**
 * Get dashboard statistics for a hospital
 * GET /dashboard/stats
 * 
 * Returns key metrics:
 * - Total beds, occupied beds, available beds
 * - Occupancy rate percentage
 * - Today's admissions and discharges
 * - Pending incoming/outgoing referrals
 * - Ward breakdown
 */
export const getDashboardStats = async (req, res, next) => {
  try {
    const hospitalId = req.auth.hospitalId;
    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD

    // Run all queries in parallel for performance
    const [
      wardsResult,
      todayAdmissionsResult,
      todayDischargesResult,
      incomingReferralsResult,
      outgoingReferralsResult
    ] = await Promise.all([
      // Get ward stats (beds and occupancy)
      supabase
        .from('wards')
        .select('id, name, ward_type, total_beds, occupied_beds')
        .eq('hospital_id', hospitalId),

      // Today's admissions count
      supabase
        .from('admissions')
        .select('id', { count: 'exact', head: true })
        .eq('hospital_id', hospitalId)
        .gte('admitted_at', `${today}T00:00:00`)
        .lt('admitted_at', `${today}T23:59:59`),

      // Today's discharges count
      supabase
        .from('discharges')
        .select('id', { count: 'exact', head: true })
        .gte('discharged_at', `${today}T00:00:00`)
        .lt('discharged_at', `${today}T23:59:59`),

      // Pending incoming referrals (to this hospital)
      supabase
        .from('referrals')
        .select('id', { count: 'exact', head: true })
        .eq('to_hospital_id', hospitalId)
        .eq('status', 'pending'),

      // Pending outgoing referrals (from this hospital)
      supabase
        .from('referrals')
        .select('id', { count: 'exact', head: true })
        .eq('from_hospital_id', hospitalId)
        .eq('status', 'pending')
    ]);

    // Check for errors
    if (wardsResult.error) throw wardsResult.error;
    if (todayAdmissionsResult.error) throw todayAdmissionsResult.error;
    if (todayDischargesResult.error) throw todayDischargesResult.error;
    if (incomingReferralsResult.error) throw incomingReferralsResult.error;
    if (outgoingReferralsResult.error) throw outgoingReferralsResult.error;

    const wards = wardsResult.data || [];

    // Calculate totals from ward data
    const totalBeds = wards.reduce((sum, ward) => sum + (ward.total_beds || 0), 0);
    const occupiedBeds = wards.reduce((sum, ward) => sum + (ward.occupied_beds || 0), 0);
    const availableBeds = totalBeds - occupiedBeds;
    const occupancyRate = totalBeds > 0 
      ? Math.round((occupiedBeds / totalBeds) * 100 * 10) / 10  // One decimal place
      : 0;

    // Ward breakdown with availability
    const wardBreakdown = wards.map(ward => ({
      id: ward.id,
      name: ward.name,
      ward_type: ward.ward_type,
      total_beds: ward.total_beds || 0,
      occupied_beds: ward.occupied_beds || 0,
      available_beds: (ward.total_beds || 0) - (ward.occupied_beds || 0),
      occupancy_rate: ward.total_beds > 0 
        ? Math.round(((ward.occupied_beds || 0) / ward.total_beds) * 100)
        : 0
    }));

    // Sort wards by availability (most available first)
    wardBreakdown.sort((a, b) => b.available_beds - a.available_beds);

    res.json({
      success: true,
      data: {
        summary: {
          total_beds: totalBeds,
          occupied_beds: occupiedBeds,
          available_beds: availableBeds,
          occupancy_rate: occupancyRate
        },
        today: {
          admissions: todayAdmissionsResult.count || 0,
          discharges: todayDischargesResult.count || 0,
          net_change: (todayAdmissionsResult.count || 0) - (todayDischargesResult.count || 0)
        },
        referrals: {
          pending_incoming: incomingReferralsResult.count || 0,
          pending_outgoing: outgoingReferralsResult.count || 0
        },
        wards: wardBreakdown,
        generated_at: new Date().toISOString()
      }
    });
  } catch (error) {
    next(new AppError(error.message || 'Failed to fetch dashboard stats', 500));
  }
};

/**
 * Get system-wide statistics (for admin users or regional coordinators)
 * GET /dashboard/system-stats
 * 
 * Returns aggregate stats across all hospitals (if user has permission)
 */
export const getSystemStats = async (req, res, next) => {
  try {
    // Only allow admin users
    if (req.auth.role !== 'admin') {
      return next(new AppError('Only administrators can view system-wide stats', 403));
    }

    const today = new Date().toISOString().split('T')[0];

    const [
      hospitalsResult,
      totalBedsResult,
      todayAdmissionsResult,
      pendingReferralsResult
    ] = await Promise.all([
      // Total hospitals count
      supabase
        .from('hospitals')
        .select('id', { count: 'exact', head: true }),

      // Total beds across all hospitals
      supabase
        .from('wards')
        .select('total_beds, occupied_beds'),

      // Today's admissions system-wide
      supabase
        .from('admissions')
        .select('id', { count: 'exact', head: true })
        .gte('admitted_at', `${today}T00:00:00`)
        .lt('admitted_at', `${today}T23:59:59`),

      // All pending referrals
      supabase
        .from('referrals')
        .select('id', { count: 'exact', head: true })
        .eq('status', 'pending')
    ]);

    if (hospitalsResult.error) throw hospitalsResult.error;
    if (totalBedsResult.error) throw totalBedsResult.error;
    if (todayAdmissionsResult.error) throw todayAdmissionsResult.error;
    if (pendingReferralsResult.error) throw pendingReferralsResult.error;

    const allWards = totalBedsResult.data || [];
    const totalBeds = allWards.reduce((sum, w) => sum + (w.total_beds || 0), 0);
    const occupiedBeds = allWards.reduce((sum, w) => sum + (w.occupied_beds || 0), 0);

    res.json({
      success: true,
      data: {
        hospitals: hospitalsResult.count || 0,
        beds: {
          total: totalBeds,
          occupied: occupiedBeds,
          available: totalBeds - occupiedBeds,
          occupancy_rate: totalBeds > 0 
            ? Math.round((occupiedBeds / totalBeds) * 100 * 10) / 10
            : 0
        },
        today_admissions: todayAdmissionsResult.count || 0,
        pending_referrals: pendingReferralsResult.count || 0,
        generated_at: new Date().toISOString()
      }
    });
  } catch (error) {
    next(new AppError(error.message || 'Failed to fetch system stats', 500));
  }
};
