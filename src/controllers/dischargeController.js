import { discharge } from '../services/dischargeService.js';

async function dischargePatient(req, res, next) {
  try {
    const { admission_id } = req.body;

    const result = await discharge({
      actor: req.auth,
      admissionId: admission_id
    });

    return res.status(200).json(result);
  } catch (err) {
    return next(err);
  }
}

export { dischargePatient };
