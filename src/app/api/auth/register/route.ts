/**
 * POST /api/auth/register
 * Register a new user
 */

import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/db';
import { createUser, generateToken, createSession } from '@/lib/auth';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { email, password, fullName, companyName, companyId } = body;

    // Validate input
    if (!email || !password) {
      return NextResponse.json(
        { error: 'Email and password are required' },
        { status: 400 }
      );
    }

    // Check if email already exists
    const existingUser = await prisma.qUAD_users.findUnique({
      where: { email },
    });

    if (existingUser) {
      return NextResponse.json(
        { error: 'Email already registered' },
        { status: 409 }
      );
    }

    // Get or create company
    let targetCompanyId = companyId;

    if (!targetCompanyId && companyName) {
      // Create new company
      const company = await prisma.qUAD_companies.create({
        data: {
          name: companyName,
          admin_email: email,
        },
      });
      targetCompanyId = company.id;
    }

    if (!targetCompanyId) {
      return NextResponse.json(
        { error: 'Company ID or company name is required' },
        { status: 400 }
      );
    }

    // Create user
    const user = await createUser({
      companyId: targetCompanyId,
      email,
      password,
      fullName,
      role: companyId ? 'DEVELOPER' : 'QUAD_ADMIN', // Admin if creating company
    });

    // Generate JWT token
    const token = generateToken(user);

    // Create session
    const ipAddress = request.headers.get('x-forwarded-for') || request.headers.get('x-real-ip');
    const userAgent = request.headers.get('user-agent');
    await createSession(user.id, token, ipAddress, userAgent);

    // Return token and user info
    return NextResponse.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        full_name: user.full_name,
        role: user.role,
        company_id: user.company_id,
      },
    }, { status: 201 });
  } catch (error) {
    console.error('Registration error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
