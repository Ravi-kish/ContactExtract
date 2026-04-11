import type { Knex } from 'knex';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';

export async function seed(knex: Knex): Promise<void> {
  await knex('users').del();

  await knex('users').insert([
    {
      id: uuidv4(),
      email: 'admin@cdr-system.local',
      password_hash: await bcrypt.hash('Admin@123', 12),
      name: 'System Administrator',
      role: 'admin',
    },
    {
      id: uuidv4(),
      email: 'analyst@cdr-system.local',
      password_hash: await bcrypt.hash('Analyst@123', 12),
      name: 'CDR Analyst',
      role: 'analyst',
    },
  ]);

  console.log('✅ Users seeded: admin@cdr-system.local / Admin@123');
}
