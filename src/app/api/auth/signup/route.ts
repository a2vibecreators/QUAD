/**
 * POST /api/auth/signup
 * Create new company and QUAD_ADMIN user
 */

import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { hashPassword, generateToken, createSession } from '@/lib/auth';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { companyName, adminEmail, password, fullName, size } = body;

    // Validation
    if (!companyName || !adminEmail || !password) {
      return NextResponse.json(
        { error: 'Company name, email, and password are required' },
        { status: 400 }
      );
    }

    // Check if email already exists
    const existingUser = await query(
      'SELECT id FROM quad_users WHERE email = $1',
      [adminEmail]
    );

    if (existingUser.rows.length > 0) {
      return NextResponse.json(
        { error: 'Email already registered' },
        { status: 409 }
      );
    }

    // Hash password
    const passwordHash = await hashPassword(password);

    // Create company
    const companyResult = await query(
      `INSERT INTO quad_companies (name, admin_email, size)
       VALUES ($1, $2, $3)
       RETURNING id, name, admin_email, size`,
      [companyName, adminEmail, size || 'medium']
    );

    interface CompanyRow { id: string; name: string; admin_email: string; size: string; }
    const company = companyResult.rows[0] as CompanyRow;

    // Create QUAD_ADMIN user
    const userResult = await query(
      `INSERT INTO quad_users (company_id, email, password_hash, role, full_name, is_active, email_verified)
       VALUES ($1, $2, $3, 'QUAD_ADMIN', $4, true, true)
       RETURNING id, company_id, email, role, full_name, is_active`,
      [company.id, adminEmail, passwordHash, fullName || 'Admin']
    );

    interface UserRow { id: string; company_id: string; email: string; role: string; full_name: string; is_active: boolean; }
    const user = userResult.rows[0] as UserRow;

    // Generate JWT token
    const token = generateToken(user);

    // Create session
    const ipAddress = request.headers.get('x-forwarded-for') || request.headers.get('x-real-ip') || null;
    const userAgent = request.headers.get('user-agent') || null;
    await createSession(user.id, token, ipAddress, userAgent);

    return NextResponse.json({
      success: true,
      message: 'Company and admin user created successfully',
      data: {
        company: {
          id: company.id,
          name: company.name,
          size: company.size,
        },
        user: {
          id: user.id,
          email: user.email,
          role: user.role,
          fullName: user.full_name,
        },
        token,
      },
    }, { status: 201 });

  } catch (error) {
    console.error('Signup error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
