import { Router, Response } from 'express';
import { authenticate, AuthRequest } from '../middleware/auth';
import db from '../db/connection';

const router = Router();

// GET /api/records/:id - Full record detail
router.get('/:id', authenticate, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const record = await db('cdr_records')
      .where({ id: req.params.id })
      .first();

    if (!record) {
      res.status(404).json({ error: 'Record not found' });
      return;
    }

    res.json(record);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch record' });
  }
});

export default router;
