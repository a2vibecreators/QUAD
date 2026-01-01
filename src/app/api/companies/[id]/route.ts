/**
 * GET /api/companies/[id] - Get company by ID
 * PUT /api/companies/[id] - Update company
 * DELETE /api/companies/[id] - Delete company
 */

import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/db';
import { verifyToken } from '@/lib/auth';

interface RouteParams {
  params: Promise<{ id: string }>;
}

// GET: Get company by ID
export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const { id } = await params;

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

    // Non-admins can only view their own company
    if (payload.role !== 'ADMIN' && payload.companyId !== id) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    const company = await prisma.qUAD_companies.findUnique({
      where: { id },
      include: {
        users: {
          select: {
            id: true,
            email: true,
            full_name: true,
            role: true,
            is_active: true
          }
        },
        domains: {
          select: {
            id: true,
            name: true,
            domain_type: true
          }
        },
        _count: {
          select: { users: true, domains: true }
        }
      }
    });

    if (!company) {
      return NextResponse.json({ error: 'Company not found' }, { status: 404 });
    }

    return NextResponse.json(company);
  } catch (error) {
    console.error('Get company error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// PUT: Update company
export async function PUT(request: NextRequest, { params }: RouteParams) {
  try {
    const { id } = await params;

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

    // Only admins can update companies
    if (payload.role !== 'ADMIN' && payload.companyId !== id) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    const body = await request.json();
    const { name, size } = body;

    // Check if company exists
    const existing = await prisma.qUAD_companies.findUnique({
      where: { id }
    });

    if (!existing) {
      return NextResponse.json({ error: 'Company not found' }, { status: 404 });
    }

    // Update company
    const company = await prisma.qUAD_companies.update({
      where: { id },
      data: {
        ...(name && { name }),
        ...(size && { size })
      }
    });

    return NextResponse.json(company);
  } catch (error) {
    console.error('Update company error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// DELETE: Delete company
export async function DELETE(request: NextRequest, { params }: RouteParams) {
  try {
    const { id } = await params;

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

    // Only admins can delete companies
    if (payload.role !== 'ADMIN') {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    // Check if company exists
    const existing = await prisma.qUAD_companies.findUnique({
      where: { id }
    });

    if (!existing) {
      return NextResponse.json({ error: 'Company not found' }, { status: 404 });
    }

    // Delete company (cascade will delete users, domains, etc.)
    await prisma.qUAD_companies.delete({
      where: { id }
    });

    return NextResponse.json({ message: 'Company deleted successfully' });
  } catch (error) {
    console.error('Delete company error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
