/**
 * Authentication Utilities for QUAD Platform
 * Handles JWT tokens, password hashing, and session management
 */

import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { query } from './db';

// JWT secret (MUST be changed in production!)
const JWT_SECRET = process.env.JWT_SECRET || 'quad-platform-secret-change-in-production';
const JWT_EXPIRES_IN = '24h'; // Token expiration time

/**
 * User interface from database
 */
export interface QuadUser {
  id: string;
  company_id: string;
  email: string;
  role: 'QUAD_ADMIN' | 'PROJECT_MANAGER' | 'DEVELOPER' | 'QA' | 'INFRASTRUCTURE' | 'SOLUTION_ARCHITECT';
  full_name: string | null;
  is_active: boolean;
}

/**
 * JWT payload interface
 */
export interface JWTPayload {
  userId: string;
  companyId: string;
  email: string;
  role: string;
}

/**
 * Hash a password using bcrypt
 * @param password Plain text password
 * @returns Hashed password
 */
export async function hashPassword(password: string): Promise<string> {
  const salt = await bcrypt.genSalt(10);
  return await bcrypt.hash(password, salt);
}

/**
 * Verify a password against a hash
 * @param password Plain text password
 * @param hash Hashed password from database
 * @returns True if password matches
 */
export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return await bcrypt.compare(password, hash);
}

/**
 * Generate a JWT token for a user
 * @param user User object
 * @returns JWT token string
 */
export function generateToken(user: QuadUser): string {
  const payload: JWTPayload = {
    userId: user.id,
    companyId: user.company_id,
    email: user.email,
    role: user.role,
  };

  return jwt.sign(payload, JWT_SECRET, {
    expiresIn: JWT_EXPIRES_IN,
  });
}

/**
 * Verify and decode a JWT token
 * @param token JWT token string
 * @returns Decoded payload or null if invalid
 */
export function verifyToken(token: string): JWTPayload | null {
  try {
    return jwt.verify(token, JWT_SECRET) as JWTPayload;
  } catch (error) {
    console.error('Token verification failed:', error);
    return null;
  }
}

/**
 * Store session in database
 * @param userId User ID
 * @param token JWT token
 * @param ipAddress Client IP address
 * @param userAgent Client user agent
 */
export async function createSession(
  userId: string,
  token: string,
  ipAddress: string | null,
  userAgent: string | null
): Promise<void> {
  await query(
    `INSERT INTO quad_sessions (user_id, token, expires_at, ip_address, user_agent)
     VALUES ($1, $2, NOW() + INTERVAL '24 hours', $3, $4)`,
    [userId, token, ipAddress, userAgent]
  );
}

/**
 * Delete session from database (logout)
 * @param token JWT token
 */
export async function deleteSession(token: string): Promise<void> {
  await query('DELETE FROM quad_sessions WHERE token = $1', [token]);
}

/**
 * Validate session exists and is not expired
 * @param token JWT token
 * @returns True if session is valid
 */
export async function validateSession(token: string): Promise<boolean> {
  const result = await query(
    `SELECT id FROM quad_sessions
     WHERE token = $1 AND expires_at > NOW()`,
    [token]
  );

  return result.rowCount ? result.rowCount > 0 : false;
}

/**
 * Update session last activity timestamp
 * @param token JWT token
 */
export async function updateSessionActivity(token: string): Promise<void> {
  await query(
    'UPDATE quad_sessions SET last_activity_at = NOW() WHERE token = $1',
    [token]
  );
}

/**
 * Get user from database by email
 * @param email User email
 * @returns User object or null
 */
export async function getUserByEmail(email: string): Promise<QuadUser | null> {
  const result = await query(
    `SELECT id, company_id, email, role, full_name, is_active
     FROM quad_users
     WHERE email = $1`,
    [email]
  );

  return result.rows[0] || null;
}

/**
 * Get user from database by ID
 * @param userId User ID
 * @returns User object or null
 */
export async function getUserById(userId: string): Promise<QuadUser | null> {
  const result = await query(
    `SELECT id, company_id, email, role, full_name, is_active
     FROM quad_users
     WHERE id = $1`,
    [userId]
  );

  return result.rows[0] || null;
}
