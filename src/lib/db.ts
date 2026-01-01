/**
 * Database Connection for QUAD Platform
 * Uses PostgreSQL connection pool
 * Connects to NutriNine database (shared with QUAD_ prefixed tables)
 */

import { Pool } from 'pg';

// Singleton pool instance
let pool: Pool | null = null;

/**
 * Get database connection pool
 * Uses environment variable DATABASE_URL or default local connection
 */
export function getPool(): Pool {
  if (!pool) {
    // Build connection string from environment variables
    const host = process.env.DB_HOST || 'localhost';
    const port = process.env.DB_PORT || '5432';
    const database = process.env.DB_NAME || 'quad_dev_db';
    const user = process.env.DB_USER || 'quad_user';
    const password = process.env.DB_PASSWORD || 'quad_dev_pass';

    const connectionString = process.env.DATABASE_URL ||
      `postgresql://${user}:${password}@${host}:${port}/${database}`;

    pool = new Pool({
      connectionString,
      max: 20, // Maximum number of clients in the pool
      idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
      connectionTimeoutMillis: 2000, // Return an error after 2 seconds if connection could not be established
    });

    // Log connection errors
    pool.on('error', (err) => {
      console.error('Unexpected error on idle database client', err);
      process.exit(-1);
    });
  }

  return pool;
}

/**
 * Execute a SQL query
 * @param text SQL query string
 * @param params Query parameters
 */
export async function query(text: string, params?: any[]) {
  const pool = getPool();
  const start = Date.now();

  try {
    const result = await pool.query(text, params);
    const duration = Date.now() - start;

    // Log slow queries (> 1 second)
    if (duration > 1000) {
      console.warn('Slow query detected:', { text, duration, rows: result.rowCount });
    }

    return result;
  } catch (error) {
    console.error('Database query error:', { text, error });
    throw error;
  }
}

/**
 * Get a client from the pool for transactions
 * Remember to release the client after use!
 */
export async function getClient() {
  const pool = getPool();
  return await pool.connect();
}

/**
 * Close the database pool (for graceful shutdown)
 */
export async function closePool() {
  if (pool) {
    await pool.end();
    pool = null;
  }
}
