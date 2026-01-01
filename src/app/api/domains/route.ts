/**
 * GET /api/domains - List domains in company
 * POST /api/domains - Create a new domain
 */

import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/db';
import { verifyToken } from '@/lib/auth';

// GET: List domains in company
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
    const parentId = searchParams.get('parent_id');
    const domainType = searchParams.get('domain_type');
    const flat = searchParams.get('flat') === 'true';

    // Build where clause
    const where: Record<string, unknown> = {
      company_id: payload.companyId
    };

    if (parentId) {
      where.parent_domain_id = parentId;
    } else if (!flat) {
      // By default, only show top-level domains
      where.parent_domain_id = null;
    }

    if (domainType) {
      where.domain_type = domainType;
    }

    const domains = await prisma.qUAD_domains.findMany({
      where,
      include: {
        sub_domains: {
          select: {
            id: true,
            name: true,
            domain_type: true
          }
        },
        _count: {
          select: {
            members: true,
            resources: true,
            flows: true,
            circles: true
          }
        }
      },
      orderBy: { name: 'asc' }
    });

    return NextResponse.json({ domains });
  } catch (error) {
    console.error('Get domains error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// POST: Create a new domain
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

    // Only admins and managers can create domains
    if (!['ADMIN', 'MANAGER'].includes(payload.role)) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    const body = await request.json();
    const { name, parent_domain_id, domain_type } = body;

    // Validation
    if (!name) {
      return NextResponse.json(
        { error: 'Name is required' },
        { status: 400 }
      );
    }

    // If parent_domain_id provided, verify it exists and belongs to same company
    if (parent_domain_id) {
      const parentDomain = await prisma.qUAD_domains.findUnique({
        where: { id: parent_domain_id }
      });

      if (!parentDomain || parentDomain.company_id !== payload.companyId) {
        return NextResponse.json(
          { error: 'Parent domain not found' },
          { status: 404 }
        );
      }
    }

    // Build path for hierarchical navigation
    let path = `/${name}`;
    if (parent_domain_id) {
      const parentDomain = await prisma.qUAD_domains.findUnique({
        where: { id: parent_domain_id }
      });
      if (parentDomain) {
        path = `${parentDomain.path || ''}/${name}`;
      }
    }

    // Create domain
    const domain = await prisma.qUAD_domains.create({
      data: {
        company_id: payload.companyId,
        name,
        parent_domain_id,
        domain_type,
        path
      },
      include: {
        parent_domain: {
          select: { id: true, name: true }
        }
      }
    });

    return NextResponse.json(domain, { status: 201 });
  } catch (error) {
    console.error('Create domain error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
