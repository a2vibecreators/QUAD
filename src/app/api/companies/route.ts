/**
 * GET /api/companies - List all companies
 * POST /api/companies - Create a new company
 */

import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/db';
import { verifyToken } from '@/lib/auth';

// GET: List all companies (admin only)
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

    // Check if user is admin
    if (payload.role !== 'ADMIN') {
      // Non-admins can only see their own company
      const company = await prisma.qUAD_companies.findUnique({
        where: { id: payload.companyId },
        include: {
          _count: {
            select: { users: true, domains: true }
          }
        }
      });

      return NextResponse.json({ companies: company ? [company] : [] });
    }

    // Admins can see all companies
    const companies = await prisma.qUAD_companies.findMany({
      include: {
        _count: {
          select: { users: true, domains: true }
        }
      },
      orderBy: { created_at: 'desc' }
    });

    return NextResponse.json({ companies });
  } catch (error) {
    console.error('Get companies error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// POST: Create a new company
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { name, admin_email, size } = body;

    // Validation
    if (!name || !admin_email) {
      return NextResponse.json(
        { error: 'Name and admin_email are required' },
        { status: 400 }
      );
    }

    // Check if company with same admin email exists
    const existing = await prisma.qUAD_companies.findUnique({
      where: { admin_email }
    });

    if (existing) {
      return NextResponse.json(
        { error: 'Company with this admin email already exists' },
        { status: 409 }
      );
    }

    // Create company
    const company = await prisma.qUAD_companies.create({
      data: {
        name,
        admin_email,
        size: size || 'medium'
      }
    });

    return NextResponse.json(company, { status: 201 });
  } catch (error) {
    console.error('Create company error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
