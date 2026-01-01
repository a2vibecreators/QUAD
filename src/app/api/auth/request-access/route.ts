import { NextResponse } from 'next/server';
import { query } from '@/lib/db';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { companyName, adminEmail, companySize, ssoProvider, message } = body;

    // Validation
    if (!companyName || !adminEmail || !companySize || !ssoProvider) {
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      );
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(adminEmail)) {
      return NextResponse.json(
        { error: 'Invalid email address' },
        { status: 400 }
      );
    }

    // Check if company/email already exists
    const existingCompany = await query(
      'SELECT id FROM QUAD_companies WHERE admin_email = $1',
      [adminEmail]
    );

    if (existingCompany.rows.length > 0) {
      return NextResponse.json(
        { error: 'An account with this email already exists' },
        { status: 409 }
      );
    }

    // Create pending company (admin must approve via email)
    const result = await query(
      `INSERT INTO QUAD_companies (
        name,
        admin_email,
        size,
        adoption_level,
        estimation_preset,
        refresh_interval
      ) VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id`,
      [
        companyName,
        adminEmail,
        companySize,
        'hyperspace', // Default adoption level
        'platonic', // Default estimation preset
        30, // Default 30s refresh
      ]
    );

    const companyId = result.rows[0].id;

    // Store access request metadata (for admin review)
    await query(
      `INSERT INTO QUAD_company_integrations (
        company_id,
        integration_id,
        enabled,
        config
      ) VALUES ($1, $2, $3, $4)`,
      [
        companyId,
        'access_request',
        false, // Not enabled until admin approves
        JSON.stringify({
          ssoProvider,
          message,
          requestedAt: new Date().toISOString(),
          status: 'pending',
        }),
      ]
    );

    // TODO: Send email notification to QUAD support team
    // TODO: Send confirmation email to user
    console.log('Access request submitted:', {
      companyId,
      companyName,
      adminEmail,
      ssoProvider,
    });

    return NextResponse.json(
      {
        success: true,
        message: 'Access request submitted successfully',
        companyId,
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error('Access request error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
