/**
 * GET /api/roles - List roles in company
 * POST /api/roles - Create a new role
 */

import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/db';
import { verifyToken } from '@/lib/auth';

// GET: List all roles in company
export async function GET(request: NextRequest) {
  try {
    // Verify authentication
    const authHeader = request.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const token = authHeader.substring(7);
    const payload = verifyToken(token);
    if (!payload) {
      return NextResponse.json({ error: 'Invalid token' }, { status: 401 });
    }

    // Get query parameters
    const { searchParams } = new URL(request.url);
    const includeInactive = searchParams.get('include_inactive') === 'true';

    // Build where clause
    const where: Record<string, unknown> = {
      company_id: payload.companyId
    };

    if (!includeInactive) {
      where.is_active = true;
    }

    const roles = await prisma.qUAD_roles.findMany({
      where,
      include: {
        _count: {
          select: { users: true }
        }
      },
      orderBy: [
        { display_order: 'asc' },
        { hierarchy_level: 'desc' }
      ]
    });

    return NextResponse.json({ roles });
  } catch (error) {
    console.error('Get roles error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// POST: Create a new role
export async function POST(request: NextRequest) {
  try {
    // Verify authentication
    const authHeader = request.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const token = authHeader.substring(7);
    const payload = verifyToken(token);
    if (!payload) {
      return NextResponse.json({ error: 'Invalid token' }, { status: 401 });
    }

    // Only admins can create roles
    if (payload.role !== 'ADMIN') {
      return NextResponse.json({ error: 'Forbidden - Admin access required' }, { status: 403 });
    }

    const body = await request.json();
    const {
      role_code,
      role_name,
      description,
      can_manage_company,
      can_manage_users,
      can_manage_domains,
      can_manage_flows,
      can_view_all_metrics,
      can_manage_circles,
      can_manage_resources,
      q_participation,
      u_participation,
      a_participation,
      d_participation,
      color_code,
      icon_name,
      display_order,
      hierarchy_level
    } = body;

    // Validation
    if (!role_code || !role_name) {
      return NextResponse.json(
        { error: 'role_code and role_name are required' },
        { status: 400 }
      );
    }

    // Validate role_code format (uppercase, underscores allowed)
    if (!/^[A-Z][A-Z0-9_]*$/.test(role_code)) {
      return NextResponse.json(
        { error: 'role_code must be uppercase letters, numbers, and underscores' },
        { status: 400 }
      );
    }

    // Check if role code already exists in this company
    const existing = await prisma.qUAD_roles.findUnique({
      where: {
        company_id_role_code: {
          company_id: payload.companyId,
          role_code
        }
      }
    });

    if (existing) {
      return NextResponse.json(
        { error: `Role code '${role_code}' already exists` },
        { status: 409 }
      );
    }

    // Validate participation values if provided
    const validParticipation = ['PRIMARY', 'SUPPORT', 'REVIEW', 'INFORM'];
    if (q_participation && !validParticipation.includes(q_participation)) {
      return NextResponse.json({ error: 'Invalid q_participation value' }, { status: 400 });
    }
    if (u_participation && !validParticipation.includes(u_participation)) {
      return NextResponse.json({ error: 'Invalid u_participation value' }, { status: 400 });
    }
    if (a_participation && !validParticipation.includes(a_participation)) {
      return NextResponse.json({ error: 'Invalid a_participation value' }, { status: 400 });
    }
    if (d_participation && !validParticipation.includes(d_participation)) {
      return NextResponse.json({ error: 'Invalid d_participation value' }, { status: 400 });
    }

    // Create role
    const role = await prisma.qUAD_roles.create({
      data: {
        company_id: payload.companyId,
        role_code,
        role_name,
        description,
        can_manage_company: can_manage_company || false,
        can_manage_users: can_manage_users || false,
        can_manage_domains: can_manage_domains || false,
        can_manage_flows: can_manage_flows || false,
        can_view_all_metrics: can_view_all_metrics || false,
        can_manage_circles: can_manage_circles || false,
        can_manage_resources: can_manage_resources || false,
        q_participation,
        u_participation,
        a_participation,
        d_participation,
        color_code,
        icon_name,
        display_order: display_order || 0,
        hierarchy_level: hierarchy_level || 0,
        is_system_role: false
      }
    });

    return NextResponse.json(role, { status: 201 });
  } catch (error) {
    console.error('Create role error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
